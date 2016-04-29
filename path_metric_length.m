function [path_length]=path_metric_length(Net,path_sets)
paths=size(path_sets,2)-1;
s_id=Net.s_d_id(1);
d_id=Net.s_d_id(2);
size(path_sets,2)
for set=1:size(path_sets,1)
    path_length(set,1)=0;
        
        clear con
        con=connection_list2(Net,s_id,path_sets,set);
        for c=1:size(con,1)
            path_length(set,1)=path_length(set,1)+Net.distances(con(c,1),con(c,2));
        end
    
    
    
end