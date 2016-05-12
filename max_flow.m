function [obj,flows]=max_flow(nodes,con,R,paths,method,solver)
[mm,kk]=size(R);
Aeq=zeros(mm,mm+kk);
%Kura con pçc kârtas ir katra R rinda sâkot no 1.
inx=find_con_indx(nodes,con,3);
inx=full(inx(inx~=0));
k=1;
if strcmp(method,'flows')
for p=1:paths
    index=find(con(:,3)==p);
    x1=find(inx(:,1)==index(1));
    for n=2:length(index)
        i=index(n);
        x2=find(inx(:,1)==i);
        Aeq(k,[x1,x2])=[1,-1];
        k=k+1;
    end
end
elseif strcmp(method,'uniform')
    index=find(con(:,3));
    x1=find(inx(:,1)==index(1));
    for n=2:length(index)
        i=index(n);
        x2=find(inx(:,1)==i);
        Aeq(k,[x1,x2])=[1,-1];
        k=k+1;
    end
end
%% konstrueju nevienadibas 
A=zeros(mm);
k=1;
for n=1:length(inx)
        x2=find(inx(:,1)==n);
        A(k,x2)=1;
        k=k+1;
end

A=[A -full(R)];
%% konstrueju x1+x2+...+x_n < 1
Aeq2=zeros(1,mm+kk);
Aeq2(mm+1:end)=1;
%% konstrueju, ka visam plusmam jâbût >0
Aeq3=zeros(mm,mm+kk);
k=1;
for n=1:length(inx)
        x2=find(inx(:,1)==n);
        Aeq3(k,x2)=1;
        k=k+1;
end
a=[A;Aeq;Aeq2;Aeq3];

%% b
bA=zeros(size(A,1),1);
bAeq=zeros(size(Aeq,1),1);
bAeq2=ones(size(Aeq2,1),1);
bAeq3=ones(size(Aeq3,1),1)*0;
b=[bA;bAeq;bAeq2;bAeq3];
%% e
eA=ones(size(A,1),1)*-1; %Less Than
eAeq=zeros(size(Aeq,1),1); % Equals
eAeq2=ones(size(Aeq2,1),1)*-1; % Less Than
eAeq3=ones(size(Aeq3,1),1)*1; %Greater Than
e=[eA;eAeq;eAeq2;eAeq3];

%% atrast optimizejamos lielumu f
f=zeros(size(a,2),1);

for p=1:paths
    index=find(con(:,3)==p);
    x1=find(inx(:,1)==index(1));
    f(x1)=1;
end

vlb=zeros(size(a,2),1);
vub=ones(size(a,2),1);
vub(1:mm)=inf;
if strcmp(solver,'lp_solve')
[obj,x] = lp_solve(f,a,b,e,vlb,vub);
else
[x,fval]  = linprog(-f,[A;Aeq2;-Aeq3],[bA;bAeq2;bAeq3],Aeq,bAeq,vlb,vub);
obj=-fval;
end
flows=zeros(1,4);
flows(1:paths)=x(f~=0);

if sum(x(mm+1:end))<0.99
    error('Kïûda max flow algoritmâ')
end

function K=find_con_indx(n,mode,paths)
k=1; active=length(mode(:,1));K=sparse(paths*n*(n-1),1);
for i=1:active,
    if (mode(i,2)>mode(i,1)),
        K((mode(i,3)-1)*n*(n-1)+((n-1)*(mode(i,2)-1)+mode(i,1)),1)=k; %#ok
        k=k+1;
    elseif (mode(i,2)<mode(i,1)),
        K(((mode(i,3)-1)*n*(n-1))+((n-1)*(mode(i,2)-1)+mode(i,1)-1),1)=k; %#ok
          
        k=k+1;
    end;
end
