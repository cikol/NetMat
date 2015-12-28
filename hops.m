function [min_hops,max_hops,avg_hops]=hops(Net,path_sets)

paths=size(path_sets,2)-1;
s_id=Net.s_d_id(1);
%d_id=Net.s_d_id(2);

for set=1:size(path_sets,1)
    for n=1:paths
        hops(n)=length(Net.node(s_id).route{path_sets(set,n)})-1;
    end
    min_hops(set,1)=min(hops);
    max_hops(set,1)=max(hops);
    avg_hops(set,1)=mean(hops);
end
end