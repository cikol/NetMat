function position_ns2(Net,folderName,field,s_id,paths,nodes)
positions=Net.positions;
fileName=sprintf('%s/pos2.txt',folderName);
fid=fopen(fileName, 'w');
s_pos=size(positions,1);
for n=1:length(nodes)-paths+1
    %[n nodes(n)]
    linex=fprintf(fid,'$node_(%d) set X_ %.2f\n',n-1,positions(nodes(n),1)+field/2);
    liney=fprintf(fid,'$node_(%d) set Y_ %.2f\n',n-1,positions(nodes(n),2)+field/2);
end
if path~=1
    for n=2:paths
        linex=fprintf(fid,'$node_(%d) set X_ %.2f\n',length(nodes)-n+1,positions(s_id,1)+field/2);
        liney=fprintf(fid,'$node_(%d) set Y_ %.2f\n',length(nodes)-n+1,positions(s_id,2)+field/2);
    end
end
fclose(fid);

end