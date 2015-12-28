function [conv, v, area]=path_convex(Net,path_sets)
paths=size(path_sets,2)-1;
if paths==1
    conv=zeros(size(path_sets,1),1);
    v=zeros(size(path_sets,1),1); 
    area=zeros(size(path_sets,1),1);
    return
end
s_id=Net.s_d_id(1);
d_id=Net.s_d_id(2);

for set=1:size(path_sets,1)
    active_nodes=[];
    for path=1:paths
        route=Net.node(s_id).route{path_sets(set,path)};
        active_nodes=[active_nodes route];
    end
    active_nodes=unique(active_nodes);
    active_pos=Net.positions(active_nodes,:);
    x=active_pos(:,1);
    y=active_pos(:,2);
    %convex_hull area
    [conv v(set,1)]=convhull(x,y);
    conv_nodes=active_nodes(conv);
    % sarindot poligona virsotnes pulksteòrâdîtâja virzienâ
    
    cx = mean(x);
    cy = mean(y);
    a = atan2(y - cy, x - cx);
    [~, order] = sort(a);
    active_nodes_sorted=active_nodes(order);
    x1=active_pos(order,1);
    y1=active_pos(order,2);
    %poligona area
    area(set,1)=polyarea(x1,y1);
    
%     %   [x1 y1] = poly2cw(x,y);
%     %area=polyarea(x,y);
%     j=1;
%     for node=1:length(conv_nodes)-1
%         
%         con(j,:)=[conv_nodes(node) conv_nodes(node+1)];
%         
%         j=j+1;
%         
%     end
%     
%     j=1;
%     active_nodes_sorted=[active_nodes_sorted active_nodes_sorted(1)];
%     
%     for node=1:length(active_nodes_sorted)-1
%         
%         con2(j,:)=[active_nodes_sorted(node) active_nodes_sorted(node+1)];
%         
%         j=j+1;
%         
%     end
%     
%     
%     draw_routes(Net,con,figure);
end
end