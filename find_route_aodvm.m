function [Net,n_of_my_routes]=find_route_aodvm(Net,s_id,d_id)
rng('shuffle')
%rng(1);
visual='no';
active=Net.size;

tic
%fig=figure('Visible','off');
%Net.node(d_id).route{1}=[];
%route_table={[]};

%test1=1;
% counter=ones(1,10);
% num_d_id_routes_old=0;
% RREQ forwarding
%while test1==1
Net.rreq=zeros(active,1);
Net.rrep=zeros(active,1);
Net.hops=zeros(active,1);
if isfield(Net.node, 'route')
    Net.node=rmfield(Net.node,'route');
end
for n_id=1:active
    Net.node(n_id).route{1}=[];
    Net.node(n_id).rreq=[];
    %Net.node(n_id).hops=0;
    %Net.node(d_id).fp_all=[];
    Net.node(n_id).prev=[];
end
%  Net.node(d_id).route=route_table;


% Initiate route discovery @ source
Net.rreq(s_id)=1;
%Net.hops(s_id)=0;


while max(Net.rreq)~=0
    %     [toc max(Net.rreq)]
    n_list=find(Net.rreq); % izfiltreju mezglus ar tockenu (paketi kuru pârraidît)
    min_hop_list=find(Net.hops(n_list)==min(Net.hops(n_list)));%noskaidroju, kuri no ðiem mezlgiem ir vistuvâk source
    n_list=n_list(min_hop_list); %izvelos ar min hopu skaitu;
    rand_n=ceil(rand()*length(n_list));
    n_id=n_list(rand_n); % òemu mezglu no saraksta
    %rreq_counter=Net.rreq(n_id); %nepârsûtîtu rreq skaitîtâjs
    %route=Net.node(n_id).route{end+1-rreq_counter}; %òemu vecâko nepârsûtîto rreq
    %new_route=[route n_id];
    hops=Net.hops(n_id);
    Net.rreq(n_id)=0;
    % new_route_hops=length(new_route);
    % Net.rreq(n_id)=rreq_counter-1;% skaitîtâju samazinu par 1
    nb_list=Net.node(n_id).neighbours; %sarkasts ar mezgla n kaimiòiem
    for nb_id=nb_list % òemu pçc kârtas kaimiòu no saraksta
        if isempty(Net.node(nb_id).rreq)
            if nb_id~=d_id
                Net.rreq(nb_id)=1;
            end
            Net.hops(nb_id)=hops+1;
            Net.node(nb_id).rreq(1,:)=[s_id,n_id,hops+1];
        else
            Net.node(nb_id).rreq(end+1,:)=[s_id,n_id,hops+1];
        end
    end
    
end


%forward route
%dest nosûta paketi katram last hop mezglam
Net.hops=zeros(active,1);
if isempty(Net.node(d_id).rreq)
    n_of_my_routes=0;
    return
end

for nb_id=Net.node(d_id).rreq(:,2)'
    %nb_id
    if nb_id~=s_id
        Net.rrep(nb_id)=1;
    end
    Net.node(nb_id).route{1}=[d_id];
    Net.hops(nb_id)=1;
end

while max(Net.rrep)~=0
    %     [toc max(Net.rreq)]
    n_list=find(Net.rrep); % izfiltreju mezglus ar tockenu (paketi kuru pârraidît)
    min_hop_list=find(Net.hops(n_list)==min(Net.hops(n_list)));%noskaidroju, kuri no ðiem mezlgiem ir vistuvâk source
    n_list=n_list(min_hop_list); %izvelos ar min hopu skaitu;
    rand_n=ceil(rand()*length(n_list));
    n_id=n_list(rand_n); % òemu mezglu no saraksta
    
    route=Net.node(n_id).route{end}; %òemu vecâko nepârsûtîto rreq
    new_route=[n_id route];
    hops=Net.hops(n_id);
    Net.rrep(n_id)=0;
    
    if isempty(Net.node(n_id).rreq(:,3))
        %ja uz soruce nav routes, paziòoju kaimiòam, kurð sûtîja
        nb_id=Net.node(n_id).prev;
        Net.rrep(nb_id)=1;
        [Net]=delete_from_table(Net,nb_id,n_id);
    else
        %ja ir route uz soruce, atrodu kaimiòu caur kuru ir isâkâ
        ind=find(Net.node(n_id).rreq(:,3)==min(Net.node(n_id).rreq(:,3)));
        nb_id=Net.node(n_id).rreq(ind(1),2);
        
        if nb_id~=s_id
            Net.rrep(nb_id)=1;
        end
        
        %pievienouju jaunu routi
        if ~isempty(Net.node(nb_id).route{1})
            num_nb_routes=size(Net.node(nb_id).route,2); % kaimiòa routu skaits
        else
            num_nb_routes=0;
        end
        
        Net.node(nb_id).route{num_nb_routes+1}=new_route;
        Net.node(n_id).prev=n_id;
        
        %izdedzeðu routi no kaimiòa rreq un visu n_id kaimiòu rreq tabulâm
        nb_list=Net.node(n_id).neighbours; %sarkasts ar mezgla n kaimiòiem
        for nb_id=nb_list % òemu pçc kârtas kaimiòu no saraksta
            
            Net=delete_from_table(Net,nb_id,n_id);
            
        end
    end
    if strcmp(visual,'yes')
        j=1;
        for n=1:active
            if ~isempty(Net.node(n).route{1})
                for r=1:size(Net.node(n).route,2)
                    path=[n Net.node(n).route{r}];
                    
                    for node=1:length(path)-1
                        con(j,:)=[path(node) path(node+1)];
                        j=j+1;
                        
                    end
                end
                
            end
        end
        
        hold on
        draw_routes(Net,con,fig);
    end
end



n_of_my_routes=size(Net.node(s_id).route,2);

if n_of_my_routes==0
    disp('No route')
else
    %pievienojam ari source_id routei
    for add_s_id=1:n_of_my_routes
        Net.node(s_id).route{add_s_id}=[s_id Net.node(s_id).route{add_s_id}];
    end
    %Net.node(s_id).route=Net.node(d_id).route;
end



%k
function [Net]=delete_from_table(Net,nb_id,n_id)
try
    ind=find(Net.node(nb_id).rreq(:,2)==n_id);
    Net.node(nb_id).rreq(ind,:)=[0 0 0];
    Net.node(nb_id).rreq=Net.node(nb_id).rreq(all(Net.node(nb_id).rreq,2),:);
catch
end
