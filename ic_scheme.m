function [a,intend]=ic_scheme(a,n,ic_scheme)
if strcmp(ic_scheme,'obic')
        n_b=(a(:,3)~=a(n,3) & a(:,4)<a(n,4) & a(:,1)~=a(n,2)); %Nodes nodes before current Tx
        intend=a(n_b,[1 4 5]);%Tx/Rx which should be nulled        
        intend=sortrows(intend,[3 2]); %sorted by maxSM, then by priority (low first)
    elseif strcmp(ic_scheme,'full')
        n_b=(a(:,3)~=a(n,3) & a(:,1)~=a(n,2));
        intend=a(n_b,1);
        
end
DoF_sum=sum(n_b.*a(:,5));
a(n,6)=DoF_sum;
a(n,7)=a(n,9)-a(n,5)-DoF_sum;%brivas dof
end