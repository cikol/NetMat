function [R]=smart4(Net,mode,type,ic_s,w,ic_strat)
R=ones(Net.size);
size_S=length(mode(:,1));
num_nodes=size_S*2;
a=zeros(num_nodes,7);
k=1;
for i=1:size_S
    a(k,1:3)=[mode(i,1) mode(i,2)  1];
    a(k+1,1:3)=[mode(i,2) mode(i,1) 2];
    a(k,10)=mode(i,3);
    a(k+1,10)=mode(i,3);
    k=k+2;
end

for n=1:size(a)
    a(n,9)=Net.node(a(n,1)).directivity.N;
end

if strcmp(ic_s,'obic')
    a=sortrows(a,9);%pçc N
end

a(:,4)=(1:num_nodes)'; 
a(:,5)=1; % viena SM
a(:,7)=inf;

for n=1:size(a)
    n1=a(n,1);
   % [a,intend]=ic_scheme2(a,n,ic_s);
    [a,intend]=ic_scheme3(a,n,ic_s,ic_strat);
    if strcmp(type,'array')
        n2=a(n,2);
        if w==1
            Net=weights_zero_full_2(Net,n1,n2,intend(:,1),'steer');
        elseif w==3
            if a(n,3)==1
                %ja raiditajs
                Net=weights_zero_full_2(Net,n1,n2,intend(:,1),'steer');
            else
                Net=weights_zero_full_2(Net,n1,n2,intend(:,1),'zfbf');
            end
        elseif w==10
            Net=weights_zero_full_2(Net,n1,n2,intend(:,1),'zfbf');
        end
        R=antenna_response(Net,R,n1,intend(:,1));%pret traucetajiem
        R=antenna_response(Net,R,n1,n2);%paredzçtais Tx/rx
        
    elseif strcmp(type,'dof')
        over=a(n,7);
        while ~isempty(intend)
            n2=intend(end,1);
            if over>=0 %tiek segts
                R(n1,n2)=0;
            end
            intend=intend(1:end-1,:);
            over=over+1;
        end
    end
end
sortrows(a,4);