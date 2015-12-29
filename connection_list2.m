function con=connection_list2(Net,s_id,path_sets,set)
j=1;
%id=s_id;

for p=1:size(path_sets,2)-1
    
    path=Net.node(s_id).route{path_sets(set,p)}
    
    for node=1:length(path)-1
        % path(node)
        % path(node+1)
    %    if path(node)~=s_id & path(node+1)~=Net.size
            con(j,:)=[path(node) path(node+1) p];
         %   con(j+1,:)=[path(node+1) path(node) p];
            j=j+1;
      %  end
    end
end
end