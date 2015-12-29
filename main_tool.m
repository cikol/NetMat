function result_all=main_tool(alpha,paths,N,gain,system,name)
%% environment
if strcmp(system,'local')
    addpath('d:/ownCloud/matlab/lpsolve');
    laiks=clock;
    folderName=sprintf('/tmp/results_%d_%d_%d_%d_%d_%d',laiks(1),laiks(2),laiks(3),laiks(4),laiks(5),round(laiks(6)));
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
lim_sets=1;
ns2='no';
matlab='yes';
fading='fading2';
max_com_nodes=0;
max_intersects=0;
if N>1
    if strcmp(gain,'yes')
        G=N^2; %Lai d_tx bûtu reiz 2, N ir 16
        antenna_in={ 'array',G,'array',1,10,'full',''};
    else
        G=1;
        %format: antenna_type, gain, PCS_type, nr,ic_scheme,ic_strategy
        antenna_in={
            % 'omni',1,'omni',0,1,'','';
            %'array',1,'omni',1,2,'full','';
            'array',1,'array',1,3,'full','';
          %  'array',1,'omni',3,4,'full','';
          %  'array',1,'array',3,5,'full','';
            %     'array',1,'omni',10,6,'full','';
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
while k<=1
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
if strcmp(topology,'random')
    field=round(tx_d_no_gain*2+rand()*tx_d_no_gain*6);
    %field=round(tx_d_no_gain*8);
    nodes=ceil((field/(tx_d_no_gain*0.6))^2);
elseif strcmp(topology,'regular')
    nodes=49;
    %field=tx_d_no_gain*(sqrt(nodes)-1);
    field=tx_d_no_gain/sqrt(2)*(sqrt(nodes)-1);
end
end


function [result]=method(system,folderName,time1,positions,topology,nodes,field,tx_d,N,antenna_in,paths,max_com_nodes,max_intersects,lim_sets,fading,alpha,Cs_vector,noise_scale_vector,ns2,matlab,name);
tic
nr=0;
tx_pow=0.1;
P_tx=tx_pow;
fc=2.45e9;
lambda = physconst('LightSpeed')/fc;
d0=1; K=(lambda^2)/(4*pi*d0)^2;
new_net=1;
proto='smr_mod';
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
    result=zeros(1,39);
    return
end
%% select path sets
path_sets=[];
r=1;
limit1=0;
route=0;
while isempty(path_sets) & new_net~=0 & limit1<20
    d=0;
    while d<max(max(Net.distances))/1.5
        s_id=ceil(rand()*nodes);
        d_id=ceil(rand()*nodes);
        d=Net.distances(s_id,d_id);
    end
    
    %routing
    disp(sprintf('%.2g: routing... %d',toc,limit1))
    if strcmp(proto,'smr')
    [Net,route]=find_route_smr(Net,s_id,d_id);
    elseif strcmp(proto,'smr_mod')
    [Net,route]=find_route_smr_mod(Net,s_id,d_id);
    elseif strcmp(proto,'aodvm')
    [Net,route]=find_route_aodvm(Net,s_id,d_id);
    end
    % meg=meg+1;
    %[Net, route]=find_route10(Net,s_id,d_id);
    disp(sprintf('%.2g: found %d routes\n', toc,route));
    
    %find path sets
    if route>=paths
        disp(sprintf('%.2g: finding path sets...',toc))
        path_sets=path_selection(Net,s_id,paths,max_com_nodes,max_intersects);
        
        disp(sprintf('%.2g: found %d sets for %d paths\n', toc,size(path_sets,1),paths));
    end
    limit1=limit1+1;
end
if isempty(path_sets)
    result=zeros(1,39);
    return
end
Net.s_d_id=[s_id d_id];

rng=1;
Net.id=round(rand()*1000000);
positions=Net.positions;
name2=sprintf('%s/positions_%05.f.mat',folderName,Net.id);
%save(name2,'positions');
%meg=0;
%% raksturot izveletos ceïu komplektus
[character]=net_structure_character(Net,path_sets);


time2=clock;
t1=etime(time2,time1);
res=zeros(1,10);
for sel_p=4:4
% if Net.distances<4*tx_d
%     sel_p=3;
% else
%     sel_p=2;
% end
%sel_p=4;
%% Marsrutu komplektu atlase analizei
clear sets
[sets]=select_path_sets(path_sets,sel_p,character,lim_sets);

%% Method
%res=zeros(length(sets),10);

for set=sets
    %CS_opt=character(set,11);
    %Cs_vector=[Cs_vector CS_opt];
    tic
    clear con
    con=connection_list2(Net,s_id,path_sets,set);
    
    %draw rotues
    %fig=figure('Visible','off');
    %draw_routes(Net,con,fig);
    %jpg_name=sprintf('%s/%05.f.jpg',folderName,Net.id);
    %saveas(fig,jpg_name,'jpg');
    %close(fig);
    for an=1:size(antenna_in,1)
        %size(antenna_in,1)
        antena_type=antenna_in{an,1};G_antenna=antenna_in{an,2};cs_type=antenna_in{an,3};w=antenna_in{an,4};a_t=antenna_in{an,5};ic_scheme=antenna_in(an,6);ic_strat=antenna_in(an,7);
        antenna_in(an,:)
        Net.type=cs_type;
        Net.G=G_antenna;
        for scale=1:length(noise_scale_vector)
            %  length(noise_scale_vector)
            Net=set_noise(Net,noise_scale_vector(scale));
            noise=Net.thermal_noise_vector(1);
            
            for Cs_i=1:length(Cs_vector)
                %     length(Cs_vector)
                Cs=Cs_vector(Cs_i);
                %Aprçíina P_cs slieksni
                if strcmp(Net.fading,'fading1')
                    P_cst=(P_tx*G_antenna*lambda^2)/((4*pi*Cs)^2);
                elseif strcmp(Net.fading,'fading2')
                    P_cst=P_tx*G_antenna*K/((Cs/d0)^(alpha));
                end
                
                if strcmp(matlab,'yes')
                    %% tiek mekletas parraides shemas
                    disp(sprintf('%.2g: Finding schemes...',toc));
                    [mode,counts]=find_schemes(Net,con,P_cst);
                    [mode_max_1path]=find_schemes(Net,con(con(:,3)==1,:),Inf);
                    schemes=size(mode,2);
                    disp(sprintf('%.2g: Found %d schemes in %d iterations\n', toc,schemes, counts));
                    
                    %% iegustam rate matricas
                    disp(sprintf('%0.2g: calculate rate vectors...',toc))
                    clear R rates R_max rates_max;
                    p=1;
                    %R=sparse(zeros(paths*Net.size*(Net.size-1),schemes));
                    for k=1:size(mode,2)
                        [rates(p:p+(size(mode{k},1))-1,:), R(:,k)]=rate_vector(Net,mode{k},'perfect',antena_type,paths,[],ic_scheme,w,ic_strat);
                        p=p+size(mode{k},1);
                    end
                    %Pârbaude vai visi linki ir iekïauti shçmâs
                    if min(rates(:,4))==0
                        R=R*0;
                        error('SINR<2.5')
                    end
                    if size(unique(rates(:,1:3),'rows'),1)~=size(con,1)
                        error('Kïûda pârraides shçmu izveidç')
                    end
                    
                    %%calculate Rate matrix of maximum capacity for 1 path
                    p=1;
                    for k_max=1:size(mode_max_1path,2)
                        [rates_max(p:p+(size(mode_max_1path{k_max},1))-1,:), R_max(:,k_max)]=rate_vector(Net,mode_max_1path{k_max},'perfect','ideal',paths,[]);
                        p=p+size(mode_max_1path{k_max},1);
                    end
                    
                    try
                        R_nz=R(~all(R==0,2),:); %non zero rows
                        R_max_nz=R_max(~all(R_max==0,2),:); %non zero rows
                    catch
                        fprintf('Out of memory...')
                        size(R)
                        result=zeros(1,39);
                        return
                    end
                    
                    
                    disp(sprintf('%.2g: finish rate matrix',toc));
                    %% capacity
%                    C=uniform_capacity(R_nz);
                    [C_m_u,~]=max_flow(nodes,con,R_nz,paths,'uniform');
                    [C_m_f,~]=max_flow(nodes,con,R_nz,paths,'flows');
                    %C_max=uniform_capacity(R_max_nz);
                    %                [C.*paths;                 C_m_u;                 C_m_f;                 ones(1,5).*C_max]
                    
                    
                    %avg_hops=distance(set,size(distance,2)-2);
                    %interfering_pairs=distance(set,size(distance,2)-1);
                    %avg_interpath_distance=round(distance(set,size(distance,2)));
                   % C_agr=paths*C;
                 %   C_agr_proc=round(C_agr/C_max*100);
                    nr=nr+1;
                    t2=toc;
                else
                    nr=nr+1;
                    C_max=0; C_agr_proc=0;  C_m_u=0; C_m_f=0;t2=0;
                end
                              
                
                if N==1 && strcmp(ns2,'yes')
                    [ns_nodes,s_ids,d_ids]=routes_ns2(Net,folderName,path_sets,set,s_id,paths);
                    position_ns2(Net,folderName,field,s_id,paths,ns_nodes);
                    
                    if paths~=1
                        %co=npermutek([1 1],paths);
                        co=ones(1,paths);
                    else
                        co=1;
                    end
                    if strcmp(system,'local')
                        res=run_ns2_5(Net,folderName,s_ids,d_ids,paths,P_cst,nr,co,res);
                    elseif strcmp(system,'hpc')
                        res=run_ns2_5_cluster(Net,s_ids,d_ids,paths,P_cst,nr,co,res);
                    end
            end
               
                
                if strcmp(cs_type,'omni');cs_t=1;
                elseif strcmp(cs_type,'array');cs_t=2;
                end
                result(r,1)=Net.id;
                result(r,2)=nodes;
                result(r,3)=field;
                result(r,4)=s_id;
                result(r,5)=d_id;
                result(r,6)=paths;
                result(r,7)=N;
                result(r,8)=w;
                result(r,9)=G_antenna;
                result(r,10)=0;
                result(r,11)=0;%C*paths; %C_agr
                result(r,12)=alpha;
                result(r,13)=sel_p;
                result(r,14)=character(set,5); %num_of_nodes;
                %result(r,15)=character(set,7); %shared_links;
                result(r,15)=size(path_sets,1); % marðrutu komplektu skaits;
                %result(r,16)=character(set,6); %num_of_links;
                result(r,16)=character(set,14); %s_d_hops
                result(r,17)=a_t; %antenna type
                result(r,18)=character(set,2); %avg_hops
                result(r,19)=character(set,4); %max_hops
                result(r,20)=character(set,3); %min_hops;
                result(r,21)=character(set,1); %source_dest_dist
                result(r,22)=character(set,11); %convex
                result(r,23)=character(set,13); %angle
                result(r,24)=character(set,9); %set_dist_min
                result(r,25)=character(set,10); %set_dist_max
                result(r,26)=t1; %laiks
                result(r,27)=cs_t; %cs_type
                result(r,28)=tx_d;
                result(r,29)=Cs;
                result(r,30)=10*log10(P_cst/0.001);
                result(r,31)=10*log10(noise/0.001);
                result(r,32)=C_m_u;
                result(r,33)=C_m_f;
                result(r,34)=t2; %laiks
                result(r,35)=0; % NS-2 cbr
                result(r,36)=0; % NS-2 delay
                result(r,37)=0; % NS-2 delay last
                result(r,38)=0; % NS-2 jitter
                result(r,39)=0; % NS-2 time
                %result(r,:)=[Net.id nodes field s_id d_id paths N tx_d Cs 10*log10(P_cst/0.001) 10*log10(noise/0.001) character(set,:) C*paths C_m_u C_m_f C_max 0 0 0 0 0 0 0];
                r=r+1;
                % toc;
                %[sel_p character(set,2) character(set,10) Cs C_m_u]
            end
        end
    end
    end
end

%%

if N==1 && strcmp(ns2,'yes')
    %co=npermutek([0.5 1],paths);
    if strcmp(system,'local')
        res=NS2_wait_results(res,folderName,co);
    elseif strcmp(system,'hpc')
        res=NS2_wait_results_cluster(res,co);
    end
    
    if max(res(:,5))==0
        % error('Nav rezultâtu no klastera')
    else
        %load(res_file)
        
        for scen=1:size(res,1)
            result_l=size(result,2);
            result(scen,result_l-4:result_l)=res(scen,[3 6 7 8 10]);
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
