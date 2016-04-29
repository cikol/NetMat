function result_all=run_komandu_izpilde_test_routing(alpha,paths,N,system,name)
%% environment
if strcmp(system,'local')
    addpath('d:/ownCloud/matlab/lpsolve');
    laiks=clock;
    folderName=sprintf('results_%d_%d_%d_%d_%d_%d',laiks(1),laiks(2),laiks(3),laiks(4),laiks(5),round(laiks(6)));
    mkdir(folderName);
elseif strcmp(system,'hpc')
    addpath('/opt/exp_soft/lp_solve');
    %setenv('LD_LIBRARY_PATH', [getenv('LD_LIBRARY_PATH') ';/opt/exp_soft/lp_solve/lib']);
    folderName=sprintf('%s/%s',getenv('MDCE_STORAGE_LOCATION'),getenv('MDCE_TASK_LOCATION'));
    mkdir(folderName);
    cd(folderName)
end

%% Ievades parametri
p=1;
lim_sets=2;
gain=1;

ns2='no';
matlab='yes';

% N=4;
% alpha=4;
% paths=2;


% antena_type='array';gain='yes';cs_type='array';w=1;
% antena_type='omni'; gain='no'; cs_type='omni'; w=0;
% antena_type='array';gain='no'; cs_type='omni'; w=1;
% antena_type='array';gain='no'; cs_type='array'; w=1;
% antena_type='array';gain='no'; cs_type='array'; w=3;
% antena_type='dof_smart';gain='no'; cs_type='omni'; w=0;
% antena_type='dof_mimo';gain='no'; cs_type='omni'; w=0;



fading='fading2';
max_com_nodes=0;
max_intersects=100;
if N>1
    if strcmp(gain,'yes')
        G=N^2; %Lai d_tx bûtu reiz 2, N ir 16
        antenna_in={ 'array',G,'array',1,10,'full',''};
    else
        G=1;
        %format: antenna_type, gain, PCS_type, nr,ic_scheme,ic_strategy
        antenna_in={
            % 'omni',1,'omni',0,1,'','';
            'array',1,'omni',1,2,'full','';
            'array',1,'array',1,3,'full','';
            'array',1,'omni',3,4,'full','';
            'array',1,'array',3,5,'full','';
            'array',1,'omni',10,6,'full','';
            %   'array',1,'omni',10,7,'obic','';
            'dof',1,'omni',0,8,'full','';
            %  'dof',1,'omni',0,9,'obic','';
            'mimo',1,'omni',0,11,'','';
            %  'dof',1,'omni',0,12,'full','path';
            %  'dof',1,'omni',0,13,'obic','path';
            %'mimo',1,'omni',0,14,'','';
            };
    end
elseif N==1;
    G=1;
    antenna_in={'omni',G,'omni',0,1,'',''};
end

if strcmp(fading,'fading1')
    tx_d=250; % sâkotnçjie aprçíini veikti pie ðîs jutîbas
else
    P_tx=0.1;
    fc=2.45e9;
    lambda = physconst('LightSpeed')/fc;
    d0=1; K=(lambda^2)/(4*pi*d0)^2;
    tx_d=(P_tx*G*K/3.1623e-11)^(1/alpha);
    tx_d_no_gain=(P_tx*K/3.1623e-11)^(1/alpha);
end
Cs_vector=[2*tx_d]; % for interpath
%Cs_vector=[1:0.1:3]*tx_d; %optimal CS
%Cs_vector=[0 2*tx_d]; % for directionl
%Cs_vector=[0]; % for directionl
%Cs_vector=[1.5*tx_d 1.75*tx_d 2*tx_d 2.25*tx_d 2.5*tx_d]; %for correlation
%noise_scale_vector=[10 1 0.1];% noise floor=1.6016e-013 W;
noise_scale_vector=[1];% noise floor=1.6016e-013 W;
%topology='regular';
%topology='linear';
topology='random';

%%
[field,nodes]=gen_field(topology,tx_d_no_gain);


%% Atkartojumi
k=1;
positions=[];
time1=clock;
while k<=100
    [result]=method(system,folderName,time1,positions,topology,nodes,field,tx_d,N,antenna_in,paths,max_com_nodes,max_intersects,lim_sets,fading,alpha,Cs_vector,noise_scale_vector,ns2,matlab,name);
    disp(sprintf('%g-%g-%g-%g-%g-%g:k=%d,alpha=%d,field=%d,paths=%d,N=%d,nodes=%d',clock,k,alpha,field,paths,N,nodes));
    if  max(max(result))~=0 || nodes>=180
        result_all(p:p+(size(result,1))-1,:)=result;
        p=p+size(result,1);
        k=k+1;
        [field,nodes]=gen_field(topology,tx_d_no_gain);
        time1=clock;
    else
        nodes=nodes+1;
        
    end
    
end
%cd ..
end

function [field,nodes]=gen_field(topology,tx_d_no_gain)
rng('shuffle');
if strcmp(topology,'random')
    field=round(tx_d_no_gain*4+rand()*tx_d_no_gain*4);
    %field=round(tx_d_no_gain*4);
    nodes=ceil((field/(tx_d_no_gain*0.6))^2);
    %nodes=ceil((field/(tx_d_no_gain*0.3))^2);
elseif strcmp(topology,'regular')
    nodes=49;
    %field=tx_d_no_gain*(sqrt(nodes)-1);
    field=tx_d_no_gain/sqrt(2)*(sqrt(nodes)-1);
end
end


function [result]=method(system,folderName,time1,positions,topology,nodes,field,tx_d,N,antenna_in,paths,max_com_nodes,max_intersects,lim_sets,fading,alpha,Cs_vector,noise_scale_vector,ns2,matlab,name);
%rng(1);
rng('shuffle');
tic
nr=0;
tx_pow=0.1;
P_tx=tx_pow;
fc=2.45e9;
lambda = physconst('LightSpeed')/fc;
d0=1; K=(lambda^2)/(4*pi*d0)^2;
new_net=1;
%% create nodes
if new_net~=0
    for n=1:nodes
        
        Net.node(n)=create_node(n,tx_pow);
        
    end
end
if N~=1
    for n=1:nodes
        
        N_temp=ceil(rand().*(N-1)+1);
        N_temp=N;
        Net.node(n).directivity=create_node_directivity(Net,N_temp);
    end
end


%% Create network
no_connectivity=1;
tries=0;
while no_connectivity==1 & tries<100
    tries=tries+1;
    %set node posstiontions
    Net=new_network(Net,topology,positions,fading,'transceivers1','array','perfect',[nodes field/2 tx_d],[tx_pow 1e6],[1 alpha 0]);
    %% find neighbours
    [Net,no_connectivity]=find_neighbours(Net,tx_d);
end
if no_connectivity==1;
    result=zeros(1,15);
    return
end

Net.id=round(rand()*1000000);

proto={ 
        'route6_dsr';
         %'flood_dsr'
        % 'smr_dsr';
        'pure_smr';
         %'aodvm';
        'aodvm1'
        'find_route10_t'
        'find_route10_t1'
        'find_route10_t2'
        };
r=1;
for n1=1:100
    path_sets=[];
    
    limit1=0;
    
    %while isempty(path_sets) & new_net~=0 & limit1<20
    d=0;
    while d<2*tx_d
        s_id=ceil(rand()*nodes);
        d_id=ceil(rand()*nodes);
        d=Net.distances(s_id,d_id);
    end
    Net.s_d_id=[s_id d_id];
    
    
   % for n=1:size(proto,1)
     for n=[2 3 6];
        route=0;
        time1=clock;
        
        if strcmp(proto(n),'aodvm1')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route_aodvm(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'route6_dsr')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route6(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'aodvm')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route_aodvm(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'flood_dsr')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route10(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'smr_dsr')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route_smr(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'pure_smr')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route_smr(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'find_route10_t')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route10_t(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'find_route10_t1')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route10_t1(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        elseif strcmp(proto(n),'find_route10_t2')
            disp(sprintf('%.2g: routing %s... %d',toc,proto{n},limit1))
            [Net,route]=find_route_smr_mod(Net,s_id,d_id);
            disp(sprintf('%.2g: found %d routes\n', toc,route));
        end
        time2=clock;
        %% nosaka isako marsrutu
        num_routes=size(Net.node(s_id).route,2);
        for ui=1:num_routes
            hops(ui)=length(Net.node(s_id).route{ui})-1;
        end
        shortest=min(hops);
        
        %% find path sets
        for paths=2:3
            time3=clock;
            if route>=paths
                disp(sprintf('%.2g: finding path sets...',toc))
                path_sets=path_selection(Net,s_id,paths,max_com_nodes,max_intersects);
                num_path_sets=size(path_sets,1);
                disp(sprintf('%.2g: found %d sets for %d paths\n', toc,size(path_sets,1),paths));
                
            else
                num_path_sets=0;
            end
            if num_path_sets~=0
                [character]=net_structure_character(Net,path_sets);
                %min_max_distance
                huls=character(:,10); %set dist max
                min_dist=min(huls);
                max_dist=max(huls);
                hops=character(:,2); %set avg hops
                min_hops=min(hops);
                max_hops=max(hops);
            else
                min_dist=0;
                max_dist=0;
                min_hops=0;
                max_hops=0;
            end
            time4=clock;
            t1=etime(time2,time1);
            t2=etime(time4,time3);
            result(r,1)=Net.id;
            result(r,2)=nodes;
            result(r,3)=field;
            %     result(r,4)=s_id;
            %    result(r,5)=d_id;
            result(r,4)=paths;
            result(r,5)=n;
            result(r,6)=route;
            result(r,7)=num_path_sets;
            result(r,8)=min_dist;
            result(r,9)=max_dist;
            result(r,10)=(max_dist-min_dist)/d; %set distance diversity
            result(r,11)=min_hops;
            result(r,12)=max_hops;
            result(r,13)=(max_hops-min_hops)/shortest; %hops diversity
            result(r,14)=t1;
            result(r,15)=shortest;
            result(r,16)=t2;
            
            r=r+1;
        end
    end
end
%% rezulati uz texta failu
if strcmp(system,'hpc')
    txtfilename=sprintf('/home/ciko/matlab/%s_%s',date,name);
    try
        save(txtfilename,'result','-ascii', '-tabs' ,'-append')
        %    break;
    catch
        fprintf('error to put in file, retry...')
    end
end
end
