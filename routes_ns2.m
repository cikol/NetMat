function [nodes,temp1,temp2]=routes_ns2(Net,path_sets,set,s_id,paths)
fid1=fopen('routes', 'w');
fid2=fopen('s_d_pair', 'w');
k=Net.size+1;
nodes=[];
for n=1:paths
    route=Net.node(s_id).route{path_sets(set,n)};
    nodes=[nodes route];
    if n~=1
        %pievienojam virtualos mezglus
        nodes=[nodes k]; %#ok
        k=k+1;
    end
end
nodes=unique(nodes);

k=Net.size+1;
for n=1:paths
    route=Net.node(s_id).route{path_sets(set,n)};
    
    s_route=size(route,2);
    %routu apstrade prieks ns2 formâta
%     for kk=1:s_route
%         route(kk)=route(kk)-1;
%     end
    if n~=1
        %pievienojam virtualos mezglus
        route(1)=k;
        
        k=k+1;
        
    end
    temp1(n)=find(nodes==route(1))-1;
    temp2(n)=find(nodes==route(s_route))-1;
    %time1(n)=1;
   % time2(n)=10;
    %route2=Net.node(s_id).route{path_sets(set,2)};
    for ns=1:s_route
        for nd=1:s_route
            if ns~=nd;
                if ns>nd
                    dir=-1;
                else
                    dir=1;
                end
                source=route(ns);
                dest=route(nd);
                next=route(ns+dir);
                hops=abs(nd-ns);
                source=find(nodes==source)-1;
                dest=find(nodes==dest)-1;
                next=find(nodes==next)-1;
                fprintf(fid1,'%d %d %d %d\n',source,dest,next,hops);
               % [source dest next hops]
            end
            
        end
    end
   
end

 
 temp1s=num2str(temp1);
 temp2s=num2str(temp2);
% time1s=num2str(time1);
% time2s=num2str(time2);

%nodes_s=num2str(nodes);
 fprintf(fid2,'set paths %d\n\n',paths);
 
 fprintf(fid2,'set temp1 {%s}\n',temp1s);
 fprintf(fid2,'set temp2 {%s}\n\n',temp2s);
 %fprintf(fid2,'set nodes {%s}\n',nodes_s);
 fprintf(fid2,'set opt(a) %g \n',length(nodes));
 fprintf(fid2,'Propagation/Shadowing set pathlossExp_ %d  ;# path loss exponent',Net.fading_parameters(2));
 
 
 fclose(fid1);
 fclose(fid2);
 
 
end