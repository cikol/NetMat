function [Net, n_of_my_routes]=find_route_smr_mod(Net,s_id,d_id)
active=Net.size;
    Net.rreq=zeros(active,1);
    Net.hops=zeros(active,1);
    if isfield(Net.node, 'route')
        Net.node=rmfield(Net.node,'route');
    end
    for n_id=1:active
        Net.node(n_id).route{1}=[];
        Net.node(n_id).prev=[];
    end
    Net.rreq(s_id)=1;
    while max(Net.rreq)~=0
        n_list=find(Net.rreq); % izfiltreju mezglus ar tockenu (paketi kuru pârraidît)
        min_hop_list=find(Net.hops(n_list)==min(Net.hops(n_list)));%noskaidroju, kuri no ðiem mezlgiem ir vistuvâk source
        n_list=n_list(min_hop_list); %izvelos ar min hopu skaitu;
        rand_n=ceil(rand()*length(n_list));
        n_id=n_list(rand_n); % òemu mezglu no saraksta
        rreq_counter=Net.rreq(n_id); %nepârsûtîtu rreq skaitîtâjs
        route=Net.node(n_id).route{end+1-rreq_counter}; %òemu vecâko nepârsûtîto rreq
        new_route=[route n_id];
        new_route_hops=length(new_route);
        Net.rreq(n_id)=rreq_counter-1;% skaitîtâju samazinu par 1
        nb_list=Net.node(n_id).neighbours; %sarkasts ar mezgla n kaimiòiem
        for nb_id=nb_list % òemu pçc kârtas kaimiòu no saraksta
            if ~ismember(nb_id,new_route)
                test=0;
                if ~isempty(Net.node(nb_id).route{1}) 
                    num_nb_routes=size(Net.node(nb_id).route,2); % kaimiòa routu skaits
                        for n=1:num_nb_routes
                            %if sum(ismember(Net.node(nb_id).route{n},new_route))>(1+max_com_nodes)
                            if sum(ismember(Net.node(nb_id).route{n},new_route))>1
                                test=1;
                                break
                            end
                        end
                else
                    num_nb_routes=0;
                end
                if test==0 | nb_id==d_id
                    Net.node(nb_id).route{num_nb_routes+1}=new_route;
                    Net.node(nb_id).prev=[Net.node(nb_id).prev n_id];
                    Net.hops(nb_id)=new_route_hops;
                    if nb_id~=d_id % dest nepârsûta tâlâk
                        Net.rreq(nb_id)=Net.rreq(nb_id)+1; %rreq bufera skaitîtâjs
                    end
                end
            end
            
        end

    end
n_of_my_routes=size(Net.node(d_id).route,2);
if isempty(Net.node(d_id).route{1})
    disp('No route')
    n_of_my_routes=0;
else
    %pievienojam ari source_id routei
    for add_s_id=1:n_of_my_routes
        Net.node(d_id).route{add_s_id}=[Net.node(d_id).route{add_s_id} d_id];
    end
    Net.node(s_id).route=Net.node(d_id).route;
end
end