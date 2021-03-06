% Simplified model for Split Multi-path Rotuing protocol (original)
function [Net, n_of_my_routes]=find_route_smr(Net,s_id,d_id)
rng('shuffle')
%rng(1);
active=Net.size;
Net.rreq=zeros(active,1);
Net.hops=zeros(active,1);
visual='no';
if strcmp(visual,'yes')
    fig=figure('Position',[969 49 944 947]);
    display_network(Net,fig,s_id,d_id);
    pause(10);
end
tic
%fig=figure('Visible','off');
% Initiate route discovery @ source
Net.rreq(s_id)=1;
if isfield(Net.node, 'route')
       Net.node=rmfield(Net.node,'route');
end
for n_id=1:active
    Net.node(n_id).route{1}=[];
    Net.node(n_id).hops=0;
   
    Net.node(n_id).prev=NaN;
end

% RREQ forwarding
while max(Net.rreq)~=0
  %  [toc max(Net.rreq)]    
    n_list=find(Net.rreq); % izfiltreju mezglus ar tockenu (paketi kuru p�rraid�t)
    min_hop_list=find(Net.hops(n_list)==min(Net.hops(n_list)));%noskaidroju, kuri no �iem mezlgiem ir vistuv�k source
    n_list=n_list(min_hop_list); %izvelos ar min hopu skaitu;
    rand_n=ceil(rand()*length(n_list));
    n_id=n_list(rand_n); % �emu mezglu no saraksta
    rreq_counter=Net.rreq(n_id); %nep�rs�t�tu rreq skait�t�js
    route=Net.node(n_id).route{end+1-rreq_counter}; %�emu vec�ko nep�rs�t�to rreq
    new_route=[route n_id];
    new_route_hops=length(new_route);
    Net.rreq(n_id)=rreq_counter-1;% skait�t�ju samazinu par 1
    nb_list=Net.node(n_id).neighbours; %sarkasts ar mezgla n kaimi�iem
    for nb_id=nb_list % �emu p�c k�rtas kaimi�u no saraksta
        if (new_route_hops<=Net.node(nb_id).hops || ...%ja nododam� route nav gar�ka k� kaimi�a iepriek� p�rs�t�t�
             Net.node(nb_id).hops==0 ||... %ja kaimi�am �is ir pirmais RREQ             
             nb_id==d_id) &&... % ja kaimi�� ir dest (dest pie�em visas routes)
             max(new_route==nb_id)==0 && ... % ja kaimi�am nododam� route nav caur vi�u (nov�r�u cilpas)
             max(Net.node(nb_id).prev==n_id)==0 %ja iepriek� nav sa�emts no ��s nodes
    %     ~ismember(nb_id,new_route) &... % ja kaimi�am nododam� route nav caur vi�u (nov�r�u cilpas)
     %       ~ismember(n_id,Net.node(nb_id).prev) %ja iepriek� nav sa�emts no ��s nodes
            
            if ~isempty(Net.node(nb_id).route{1})    
                num_nb_routes=size(Net.node(nb_id).route,2); % kaimi�a routu skaits
            else
                num_nb_routes=0;
            end
            
            Net.node(nb_id).route{num_nb_routes+1}=new_route;
            Net.node(nb_id).hops=new_route_hops;
            Net.hops(nb_id)=new_route_hops;            
            Net.node(nb_id).prev=[Net.node(nb_id).prev n_id];
            if nb_id~=d_id % dest nep�rs�ta t�l�k
                Net.rreq(nb_id)=Net.rreq(nb_id)+1; %rreq bufera skait�t�js
            end
        end
    end
    
    if strcmp(visual,'yes')
        j=1;
        for n=nb_list
            if ~isempty(Net.node(n).route{1})
                for r=1:size(Net.node(n).route,2)
                    path=[Net.node(n).route{r} n];
                    
                    % for node=length(path)-1:length(path)
                    con(j,:)=[path(end-1) path(end)];
                    j=j+1;
                    
                    %    end
                end
                
            end
        end
        
        hold on
        draw_routes(Net,con,fig);
    end
end
n_of_my_routes=size(Net.node(d_id).route,2);

if n_of_my_routes==0
    disp('No route')
else
    %pievienojam ari source_id routei
    for add_s_id=1:n_of_my_routes
        Net.node(d_id).route{add_s_id}=[Net.node(d_id).route{add_s_id} d_id];
    end
    Net.node(s_id).route=Net.node(d_id).route;
end
if strcmp(visual,'yes')
    path_sets=path_selection(Net,s_id,2,2,0);
    j=1;
        for n=1:active
            if ~isempty(Net.node(n).route)
                for r=1:size(Net.node(n).route,2)
                    path=[Net.node(n).route{r}];
                    
                    for node=1:length(path)-1
                        con(j,:)=[path(node) path(node+1)];
                        j=j+1;
                        
                    end
                end
                
            end
        end
        
        hold on
        draw_routes(Net,con,fig);
    
    con=connection_list2(Net,s_id,path_sets,1);
    for k=1:size(con)
        x1=Net.node(con(k,1)).position.InitialPosition(1);
        x2=Net.node(con(k,2)).position.InitialPosition(1);
        y1=Net.node(con(k,1)).position.InitialPosition(2);
        y2=Net.node(con(k,2)).position.InitialPosition(2);
        
        myline=line([x1 x2],[y1 y2],'LineStyle','-','Tag','linija','LineWidth',3);
    drawnow
    end
end
