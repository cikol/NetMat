function [sets]=select_path_sets(path_sets,sel_p,character,lim_sets)
paths=size(path_sets,2)-1;
if sel_p==1
    criterion='min_max_distance';
elseif sel_p==2
    criterion='max_distance';
    elseif sel_p==3
    criterion='min_hops_first';
elseif sel_p==4
    criterion='';
elseif sel_p==5
    criterion='smr_selection';
end

if paths==1
    hops=character(:,2);
    [sets]=find(hops==min(hops))';
elseif paths~=1
    if strcmp(criterion,'min_max_distance')
        huls=character(:,10); %set dist max
        [~,sets(1)]=min(huls);
        [~,sets(2)]=max(huls);
        if min(huls)==max(huls)
            sets=sets(1);
        end
    elseif strcmp(criterion,'max_distance')
        huls=character(:,10); %set dist max
        [~,sets]=max(huls);
    elseif strcmp(criterion,'min_hops_first')
        avg_hops=character(:,2);
        sets_1=find(avg_hops==min(avg_hops))';
        sets=find(character(:,10)==max(character(sets_1,10)));
    else
        sets=find(path_sets(:,1))';
    end
    %if strcmp(criterion,'lim_sets')
    
end
%% samazinâm analizçjamo ceïu komplektu skaitu
if length(sets)>lim_sets
    sets=sets(unique(ceil(rand(1,lim_sets)*length(sets))));
end