function [path_sets,intersects]=check_path_intersects(Net,s_id,path_sets,max_intersects)

intersects=zeros(size(path_sets,1),1);
for set=1:size(path_sets,1)
    j=1;
    for p=1:size(path_sets,2)
        path=Net.node(s_id).route{path_sets(set,p)};
        for node=1:length(path)-1
            con(j,:)=[path(node) path(node+1) p];
            j=j+1;
        end
    end
    x1=Net.positions(con(:,1),1);
    x2=Net.positions(con(:,2),1);
    y1=Net.positions(con(:,1),2);
    y2=Net.positions(con(:,2),2);
    %% veicu nogrieþòu saîsinâðanu, jo citâdi savienojumi arî ir krustpunkti.
    %%visus sasinu no abiem galiem par 0.1
    max_x1=find(x1==max(x1,x2));
    min_x1=find(x1==min(x1,x2));
    
    
    xy_alfa=atan(abs(y1-y2)./abs(x1-x2));
    dx=0.1*cos(xy_alfa);
    dy=0.1*sin(xy_alfa);
    
    x1(max_x1)=x1(max_x1)-dx(max_x1);
    x2(max_x1)=x2(max_x1)+dx(max_x1);
    
    x1(min_x1)=x1(min_x1)+dx(min_x1);
    x2(min_x1)=x2(min_x1)-dx(min_x1);
    
    
    max_y1=find(y1==max(y1,y2));
    min_y1=find(y1==min(y1,y2));
    
    
    
    y1(max_y1)=y1(max_y1)-dy(max_y1);
    y2(max_y1)=y2(max_y1)+dy(max_y1);
    y1(min_y1)=y1(min_y1)+dy(min_y1);
    y2(min_y1)=y2(min_y1)-dy(min_y1);
    %% meklçju savienojumus
    
    out = lineSegmentIntersect([x1 y1 x2 y2],[x1 y1 x2 y2]);
    
    intersects(set,1)=sum(sum(out.intAdjacencyMatrix))/2;
end
path_sets=path_sets(intersects<=max_intersects,:);

end