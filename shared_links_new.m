function [num_shared_links,num_of_links,link_disjointness,num_of_nodes]=shared_links_new(Net,path_sets)
s_id=Net.s_d_id(1);
    %d_id=Net.s_d_id(2);
paths=size(path_sets,2)-1;
if paths==1
    num_shared_links=zeros(size(path_sets,1),1);
    link_disjointness=zeros(size(path_sets,1),1);
    for set=1:size(path_sets,1)
        con=connection_list2(Net,s_id,path_sets,set);
        num_of_nodes(set,1)=length(unique(con(:,1:2)));
        num_of_links(set,1)=size(con,1);
    end
else
    
    for set=1:size(path_sets,1)
        con=connection_list2(Net,s_id,path_sets,set);
        num_of_nodes(set,1)=length(unique(con(:,1:2)));
        num_of_links(set,1)=size(con,1);
        
        [~,b]=unique(con(:,1:2),'rows');
        s_l=setdiff(con,con(b,:),'rows');
        
        
        count_s_l_u=size(unique(s_l(:,1:2),'rows'),1);
        num_shared_links(set,1)=size(s_l,1)+count_s_l_u;
        link_disjointness(set,1)=1-(num_shared_links(set,1)/num_of_links(set,1));
    end
end
end