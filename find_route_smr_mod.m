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
            if ~ismember(nb_id,new_route)
                test=0;
                if ~isempty(Net.node(nb_id).route{1}) 
                    num_nb_routes=size(Net.node(nb_id).route,2); % kaimi�a routu skaits
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
                    if nb_id~=d_id % dest nep�rs�ta t�l�k
                        Net.rreq(nb_id)=Net.rreq(nb_id)+1; %rreq bufera skait�t�js
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