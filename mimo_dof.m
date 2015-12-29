function [R,z]=mimo_dof(Net,mode)
R=ones(Net.size);
size_S=length(mode(:,1));
num_nodes=size_S*2;
a=zeros(num_nodes,10);
k=1;
for i=1:size_S
    a(k,1:3)=[mode(i,1) mode(i,2) 1];
    a(k+1,1:3)=[mode(i,2) mode(i,1) 2];
    k=k+2;
end
for n=1:size(a)
    a(n,9)=Net.node(a(n,1)).directivity.N;
end
a=sortrows(a,9);%pçc N skaita
a(:,4)=(1:num_nodes)';
a(:,5)=1; % viena SM
a(:,7)=inf;
a(:,8)=1;
for n=1:size(a)
    [a,intend]=ic_scheme(a,n,'obic');
    n1=a(n,1);
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

while 1
    %parbauda vai palielinasana rada dof iztrukumu tiem kas saraksta
    %aiz.
    for n=1:size(a)
        n_b=(a(:,3)~=a(n,3) & a(:,4)>a(n,4) & a(:,1)~=a(n,2));
        if min(a(n_b,7)>0)==0
            a(n,8)=0;
            op=find(a(:,1)==a(n,2));
            a(op,8)=0;
        end
        %ja kadam mezgalm nav DoF, tad ari vina otrai pusei nedrikst
        %palielinat
        if a(n,7)==0
            op=find(a(:,1)==a(n,2));
            a(op,8)=0;
        end
    end
    list_0=a(a(:,8)~=0,:); %SM palielinasana ir atlauta Tx un Rx abi suporte
    list_1=list_0(list_0(:,7)>0,:); %brivas DoF >0
    list_2=list_1(list_1(:,5)==min(list_1(:,5)),:); %Mazaks SM
    list_3=list_2(list_2(:,4)==(list_2(:,4)),:); % Aukstaka prioritate
    if isempty(list_3)
        break
    end
    b=find(a(:,1)==list_3(1));
    c=find(a(:,1)==list_3(2));
    if ~isempty(c)
        a(b,5)=a(b,5)+1;
        a(c,5)=a(c,5)+1;
        a(b,7)=a(b,7)-1;
        a(c,7)=a(c,7)-1;
    else
        a(b,8)=0;
    end
    %brivu DoF aprekinasana
    for n=1:size(a)
        [a,~]=ic_scheme(a,n,'obic');
    end
end
for i=1:size_S
    z(i,1)=a(a(:,1)==mode(i,1),5);
end
sortrows(a,4);