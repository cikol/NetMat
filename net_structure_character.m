function [character]=net_structure_character(Net,path_sets)
paths=size(path_sets,2)-1;
s_id=Net.s_d_id(1);
d_id=Net.s_d_id(2);
size_path_sets=size(path_sets,1);

%% attalums starp sutitaju sanjemeju
s_d_dist=Net.distances(s_id,d_id);
s_d_dist=ones(size_path_sets,1).*s_d_dist;

%% videjais lecienu skaits
[min_hops,max_hops,avg_hops]=hops(Net,path_sets);

%% marsrutu garums (metros)
[path_length]=path_metric_length(Net,path_sets);

%% attalums starp marsrutiem (convex)
%[~, convex_hull, area]=path_convex(Net,path_sets);

%% attalums starp marsrutiem (videjais metros)
[set_dist_min,set_dist_max]=distance_m2_new(Net,path_sets);

%% Pirma hopa lenkis
[set_angle]=angle(Net,path_sets);


%% linku skaits
[num_shared_links,num_of_links,~,num_of_nodes]=shared_links_new(Net,path_sets);

%% average neighbour distance
avg_dist_sum=0;
for n=1:Net.size
    avg_dist_sum=avg_dist_sum+Net.node(n).avg_neighbour_distance;
end
avg_neighbour_dist=avg_dist_sum/Net.size;

%% Isakais marsruts starp s_d
        num_routes=size(Net.node(s_id).route,2);
        s_d_hops=zeros(1,num_routes);
        for ui=1:num_routes
            s_d_hops(ui)=length(Net.node(s_id).route{ui})-1;
        end
        s_d_hops_min=min(s_d_hops);

%%
character(:,1)=round(s_d_dist);
character(:,2)=avg_hops;
character(:,3)=min_hops;
character(:,4)=max_hops;
character(:,5)=num_of_nodes;
character(:,6)=num_of_links;
character(:,7)=num_shared_links;
character(:,8)=path_length;
character(:,9)=set_dist_min;
character(:,10)=set_dist_max;
%character(:,11)=round(convex_hull./s_d_dist);
character(:,11)=NaN;
%character(:,12)=area./s_d_dist;
character(:,12)=NaN;
character(:,13)=set_angle;
character(:,14)=s_d_hops_min;
% [path_sets avg_l' min_hops' max_hops' n_pairs' set_dist' path_length' convex_V' angle']
end