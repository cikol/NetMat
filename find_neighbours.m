function [Net,no_route,avg_neighbour_distance]=find_neighbours(Net,P_0)
%P_0=50;
no_route=0;
n=Net.size;
for i=1:n
    Net.node(i).neighbours=find(Net.distances(i,:)<=P_0 & Net.distances(i,:)~=0);
    Net.node(i).avg_neighbour_distance=sum(Net.distances(i,Net.node(i).neighbours))/length(Net.node(i).neighbours);
    if isempty(Net.node(i).neighbours)
       % fprintf('Node %g: no neighbours\n',i)
        no_route=1;
        return
    end
       
end

end
