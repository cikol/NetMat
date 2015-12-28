function [set_dist_min,set_dist_max]=distance_m2_new(Net,path_sets)
paths=size(path_sets,2)-1;
s_id=Net.s_d_id(1);
d_id=Net.s_d_id(2);
if paths==1
    set_dist_min=zeros(size(path_sets,1),1);
    set_dist_max=zeros(size(path_sets,1),1);
    return
end
comb=nchoosek([1:paths],2);
size_comb=size(comb,1);
for set=1:size(path_sets,1)
    n_pairs(set)=0;
    path_distance(set)=0;
    
    for i=1:size_comb
        
        path_1=Net.node(s_id).route{path_sets(set,comb(i,1))};
        path_2=Net.node(s_id).route{path_sets(set,comb(i,2))};
        %attalums pec disertacija aprakstitas metodes
        min_dist_sum=0;
        for n1=2:length(path_1)-1
            min_dist=inf;
            for n2=2:length(path_2)-1
                node1=path_1(n1);
                node2=path_2(n2);
                dist0=Net.distances(node1,node2);
                if dist0<min_dist
                    min_dist=dist0;
                end
            end
            min_dist_sum=min_dist_sum+min_dist;
            
        end
        min_dist_1=min_dist_sum/(length(path_1)-2);
        min_dist_sum=0;
        for n1=2:length(path_2)-1
            min_dist=inf;
            for n2=2:length(path_1)-1
                
                node1=path_2(n1);
                node2=path_1(n2);
                dist0=Net.distances(node1,node2);
                if dist0<min_dist
                    min_dist=dist0;
                end
            end
            min_dist_sum=min_dist_sum+min_dist;
            
        end
        min_dist_2=min_dist_sum/(length(path_2)-2);
        dist(i,1)=(min_dist_1+min_dist_2)/2;
    end
    dist=sort(dist);
    set_dist_min(set,1)=min(dist);
    set_dist_max(set,1)=max(dist);
end