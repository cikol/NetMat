% Function searches for sets of links which may operate simultaneously
%
% Input parameters:
% Structure Net. with the following fields:
%   Net.G - antenna array gain; 1 for omni-directional network
%   Net.size - total number of nodes
%   Net.gains - 2D matrix of channel gains between nodes
%   Net.type - carrier sense mode: "omni" or "array"
% con - list of connections forming the paths
% P_tx - transmission power
% P_cst - physical carrier sense threshold
% noise - ambient noise
%
function [mode_all,counts,summa]=find_schemes(Net, con, P_tx, P_cst, noise)
%rng('shuffle')
%rng(1);
if P_cst~=Inf;
    type=Net.type;
else
    type='ideal';
end
G_antenna=Net.G;
mode_all={};

%% Konfliktu grafs pçc protokola modeïa
size_L=size(con,1);
CS_graph=ones(size(con,1));
for i=1:size_L
    for j=1:size_L
        s1=con(i,1);
        r1=con(i,2);
        s2=con(j,1);
        r2=con(j,2);
        if  max(con(i,1:2)==s2)==0 & max(con(i,1:2)==r2)==0
            
            if strcmp(type,'array')
                Net=weights(Net,[con(i,:);con(j,:)]);
                R=antenna_response_matrix2(Net,[s1 s2; s2 s1]);
            elseif strcmp(type,'ideal')
                R=zeros(Net.size);
            elseif strcmp(type,'omni')
                R=ones(Net.size);
            end
            
            R_tx1=R(s1,s2);
            R_tx2=R(s2,s1);
            G_1=Net.gains(s1,s2);
            P_s_tx=R_tx1*R_tx2*G_1*P_tx*G_antenna;
            
            
            if (P_s_tx)<P_cst %| P_rx2>P_cst
                
                %mode_temp=[mode_temp;con_temp(j,:)];
                %[~,r]=ismember(con_temp(j,:),con,'rows');
                CS_graph(j,i)=P_s_tx;
            end
            
        end
        
    end
end

%[con CS_graph]

%% 
counts=0;
counts1=0;
counts2=0;
tries=50;
z_c=0;
P=CS_graph;
end_counter=[];
while z_c<tries*size_L
    counts=counts+1;
    mode=[];
    i_mode=[];
    con_temp=con;
    P_mode=ones(size(con,1),1)*noise;
    val= true(size(con,1),1); % logical vektors
    while ~isempty(con_temp)
        size_L_temp=size(con_temp,1);
        i=ceil(rand()*size_L_temp);
       % [~,r]=ismember(con_temp(i,:),con,'rows');
        r=find(sum(abs(con-(ones(size(con,1),1)*con_temp(i,:))),2)==0);%find selected link index in con
        if ~isempty(mode)
            P_rc=P_mode(i_mode)+P(r,i_mode)'; %links in schema
            P_cr=P_mode(r)+sum(P(i_mode,r)); %link under test
        else
            P_rc=noise;
            P_cr=noise;
        end
        
        if (P_rc<P_cst & P_cr<P_cst) | isempty(mode)
            P_mode(i_mode)=P_rc;
            P_mode(r)=P_cr;
            mode=[mode; con_temp(i,:)];
            i_mode=[i_mode; r];
            val=(CS_graph(:,r)<1) & val;
        else
            val(r)=0;
        end
        %Nosakam atlikuðos iespçjamos linkus
        con_temp=con(val,:);
    end
    if isempty(mode_all)
        mode_all{1}=mode;
        fp=sum(sum(mode(:,1:3)));
        fp_all=fp;
        z_c=0;
    else
        test=0;
%         for n=1:size(mode_all,2);
%                 counts1=counts1+1;
%                 if isempty(setxor(mode_all{n},mode,'rows'))
%                     test=1;
%                     break
%                 end
%         end
        fp=sum(sum(mode(:,1:3).^2));
        if max(fp_all==fp)==1;
            %parbaudam tikai tos, kuriem fingerprints ir vienâds. Ja
            %summa ir daþâda, shemas nevar bût vienâdas pat ja linku
            %izkârtojums cits.
            kurs=find(fp_all==fp);
            for nn=1:length(kurs)
                n=kurs(nn);
                if size(mode_all{n},1)==size(mode,1)
                       counts1=counts1+1;
                       % following lines replace function isempty(setxor(mode_all{n},mode,'rows'))
                       test=1;
                       for t=1:size(mode,1)
                           out=find(sum(abs(mode_all{n}-(ones(size(mode_all{n},1),1)*mode(t,:))),2)==0,1);
                           if isempty(out)
                               test=0;
                               break
                           end
                       end
                       if test==1;
                           break
                       end
                        
%                     if isempty(setxor(mode_all{n},mode,'rows'))
%                         test=1;
%                         break
%                     end
                end
            end
        end
        
        
        
        if test==0
            mode_all{size(mode_all,2)+1}=sortrows(mode);
            fp_all=[fp_all fp];
            end_counter=[end_counter 1];
            z_c=0;
        else
            end_counter=[end_counter 0];
            z_c=z_c+1;
        end
    end
end
summa=[];
for x=1:100:length(end_counter)-99;
    summa=[summa sum(end_counter(x:x+99))];
end

end

