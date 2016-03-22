function [path_sets]=path_selection(Net,s_id,paths,max_com_nodes,max_intersects)
%path_sets=[];



n_of_my_routes=size(Net.node(s_id).route,2);
if n_of_my_routes~=0
    %pievienojam ari source_id routei
    
    
    
    if paths==1
        lim=100;
    elseif paths==2
        lim=1000;
    elseif paths==3
        lim=220;
    elseif paths==4
        lim=70;
    end
    for ui=1:n_of_my_routes
        hops(ui)=length(Net.node(s_id).route{ui});
    end
    pl=0;
    longest=max(hops);
    short=min(hops);
    shortest=find(hops==short);
    %size(shortest,2);
    
    while size(shortest,2)<=lim && pl<=longest-short;
        pl=pl+1;
        shortest=find(hops>=short & hops<=min(hops)+pl);
        
        %size(shortest,2)
    end
    shortest=find(hops>=short & hops<=min(hops)+pl-1);
    %  size(shortest,2)
    if length(shortest)<paths
        %shortest
        Net.node(s_id).route{:}
        path_sets=[];
    return
    end
    %   [size(shortest,2) n_of_my_routes]
    %%
    if  paths==1
        kkk=(1:n_of_my_routes)';
        com_nodes=zeros(size(kkk,1),1);
        for k=1:size(kkk,1)
            r1=kkk(k,1);
            com_nodes(k)=length(Net.node(s_id).route{r1})-1;
        end
        %select shortest
        po=find(com_nodes<=min(com_nodes)+3);
        %po=find(com_nodes<=max(com_nodes));
        %select longest
        %po=find(com_nodes==max(com_nodes));
        
    elseif paths==2
        kkk=combnk(shortest,2);
        kkk=check_path_intersects(Net,s_id,kkk,max_intersects);
        com_nodes=zeros(size(kkk,1),1);
        for k=1:size(kkk,1)
            r1=kkk(k,1);
            r2=kkk(k,2);
            
            for rr=1:length(Net.node(s_id).route{r2})
                
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r2}(rr));
            end
            com_nodes(k)=com_nodes(k)-2;
            
            
        end
        po=find(com_nodes<=max_com_nodes);
       % po=find(com_nodes<=max(com_nodes));
        %po=find(com_nodes==min(com_nodes));
        %po=find(com_nodes==1);
        %%
    elseif paths==3
        kkk=combnk(shortest,3);
        kkk=check_path_intersects(Net,s_id,kkk,max_intersects);
        com_nodes=zeros(size(kkk,1),1);
        for k=1:size(kkk,1)
            r1=kkk(k,1);
            r2=kkk(k,2);
            r3=kkk(k,3);
            for rr=1:length(Net.node(s_id).route{r2})
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r2}(rr));
            end
            for rrr=1:length(Net.node(s_id).route{r3})
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r3}(rrr));
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r2}==Net.node(s_id).route{r3}(rrr));
            end
            com_nodes(k)=com_nodes(k)-6;
        end
        po=find(com_nodes<=max_com_nodes);
        %po=find(com_nodes==min(com_nodes));
        %po=find(com_nodes<=max(com_nodes));
        % po=find(com_nodes==0);
    elseif paths==4
        kkk=combnk(shortest,4);
        kkk=check_path_intersects(Net,s_id,kkk,max_intersects);
        com_nodes=zeros(size(kkk,1),1);
        for k=1:size(kkk,1)
            r1=kkk(k,1);
            r2=kkk(k,2);
            r3=kkk(k,3);
            r4=kkk(k,4);
            for rr1=1:length(Net.node(s_id).route{r2})
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r2}(rr1));
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r3}==Net.node(s_id).route{r2}(rr1));
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r4}==Net.node(s_id).route{r2}(rr1));
            end
            for rr2=1:length(Net.node(s_id).route{r3})
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r3}(rr2));
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r4}==Net.node(s_id).route{r3}(rr2));
            end
            for rr3=1:length(Net.node(s_id).route{r4})
                com_nodes(k)=com_nodes(k)+sum(Net.node(s_id).route{r1}==Net.node(s_id).route{r4}(rr3));
            end
            
            com_nodes(k)=com_nodes(k)-12;
        end
        
        %po=find(com_nodes==min(com_nodes));
        
        %po=find(com_nodes==0);
        po=find(com_nodes<=max_com_nodes);
        %po=find(com_nodes<=max(com_nodes));
        if ~isempty(po) & paths==4
        po=po(ceil(rand()*size(po,1)));
        end
    end
    
    path_sets=[kkk(po,:) com_nodes(po,:)];
    
else
    path_sets=[];
end