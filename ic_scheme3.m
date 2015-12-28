function [a,intend]=ic_scheme3(a,n,ic_scheme,ic_strat)
if strcmp(ic_scheme,'obic')
        n_b=(a(:,3)~=a(n,3) & a(:,4)<a(n,4) & a(:,1)~=a(n,2)); %Nodes nodes before current Tx
        %intend=a(n_b,[1 4 10]);%Tx/Rx which should be nulled        
        %intend=sortrows(intend,[3 2]); %sorted by maxSM, then by priority (low first)
    elseif strcmp(ic_scheme,'full')
        n_b=(a(:,3)~=a(n,3) & a(:,1)~=a(n,2));
end
    intend=a(n_b,[1 4 10]);
if strcmp(ic_strat,'path')
    
    intend_intra=intend(intend(:,3)==a(n,10),:);
    intend_inter=intend(intend(:,3)~=a(n,10),:);
    intend=[sortrows(intend_inter,-2);
            sortrows(intend_intra,-2)];
end
 
DoF_sum=sum(n_b.*a(:,5));
a(n,6)=DoF_sum;
a(n,7)=a(n,9)-a(n,5)-DoF_sum;%brivas dof
end