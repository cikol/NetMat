function [mode_all,counts,summa]=find_schemes(Net,con, P_cst)
rng('shuffle')
if P_cst~=Inf;
    type=Net.type;
else
    type='ideal';
end
G_antenna=Net.G;
mode_all={};
%%Physical Carrier Sense threshold
% lambda = physconst('LightSpeed')/Net.node(1).fc;
% P_tx=Net.node(1).transmit_pow;
% %Nosaka P_cst slieksni
% if strcmp(Net.fading,'fading1')
%     P_cst=(P_tx*lambda^2)/((4*pi*R_cst)^2);
% elseif strcmp(Net.fading,'fading2')
%     d0=Net.fading_parameters(1);
%     alpha=Net.fading_parameters(2);
%     %sigma=Net.fading_parameters(3);
%     %RM=10.^(normrnd(0,sigma,Net.size,Net.size)/10);
%     K=(lambda^2)/((4*pi*d0)^2);
%     P_cst=P_tx*K/((R_cst/d0)^(alpha));
% end
P_tx=Net.node(1).transmit_pow;
noise=Net.thermal_noise_vector(1);

% gadijumam, ja troksnis ir lielaks kaa P_cst
% if P_cst<=noise && P_cst~=0 &&
%     for no=1:size(con,1)
%         mode_all{no}=[con(no,:) con(no,1) Net.node(con(no,1)).transmit_pow 0];
%     end
%     disp('CS  < nosie')
%     return
% end

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
        [~,r]=ismember(con_temp(i,:),con,'rows');
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
        fp=sum(sum(mode(:,1:3)));
        if max(fp_all==fp)==1;
            %parbaudam tikai tos, kuriem fingerprints ir vienâds. Ja
            %summa ir daþâda, shemas nevar bût vienâdas pat ja linku
            %izkârtojums cits.
            kurs=find(fp_all==fp);
            for nn=1:length(kurs)
                n=kurs(nn);
                if size(mode_all{n},1)==size(mode,1)
                       counts1=counts1+1;
                    if isempty(setxor(mode_all{n},mode,'rows'))
                        
                        test=1;
                        break
                    end
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
%summa=[summa zeros(1,30-length(summa))];
%size(summa)
% for k=1:size(mode_all,2)
%     for kk=1:size(mode_all{k},1)
%         mode_all{k}(kk,4:6)=[mode_all{k}(kk,1) Net.node(mode_all{k}(kk,1)).transmit_pow 0];
%        % mode_all{k}(kk,4:5)=[con(1,1) Net.node(mode_all{k}(kk,1)).transmit_pow];
%         
%     end
% end

end

