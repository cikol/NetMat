function [rates, rate_matrix]=rate_matrix3(Net,mode,receiver_type,type,paths,output,ic_scheme,w,ic_strat)

% INITIALIZATION
% ==============

% The number of nodes
n=Net.size;
k=1;
G_antenna=Net.G;
% The number of active transmissions
active=length(mode(:,1));
%rate_matrix=zeros(paths*n*(n-1),1);
rate_matrix=sparse(paths*n*(n-1),1);
interference=zeros(active,1);
% if Net.node(1).N==1 && ~strcmp(antenna_type,'ideal')
% type='omni';
%     else
% type=antenna_type;
% end
for i=1:active,
    interference(i)=Net.thermal_noise_vector(mode(i,2));
    %interference(i)=0;
end;

% if strcmp(type,'dof_mimo')
%     [R,z]=dof(Net,mode,type);
% elseif strcmp(type,'dof_dir')
%     [R,z]=dof_v2(Net,mode,type);
% elseif strcmp(type,'dof_vector')
%     [R,z]=dof_v2(Net,mode,type);
% elseif strcmp(type,'array')
%     R=smart(Net,mode,w);
%     z=ones(active,1);
if strcmp(type,'array') || strcmp(type,'dof')
     [R]=smart4(Net,mode,type,ic_scheme,w,ic_strat);
     z=ones(active,1);
% elseif strcmp(type,'new')
%      [R]=smart4(Net,mode,'array',ic_scheme,w);
%      z=ones(active,1);
elseif strcmp(type,'mimo')
     [R,z]=dof_mimo(Net,mode);
elseif strcmp(type,'ideal')
    R=zeros(Net.size);
    for i=1:active,
        R(mode(i,1),mode(i,2))=1;
        R(mode(i,2),mode(i,1))=1;
    end
    z=ones(active,1);
elseif strcmp(type,'omni')
    R=ones(Net.size);
    z=ones(active,1);
end

% WE CALCULATE THE RATE MATRIX
% ============================

for i=1:active,
    
    % we calculate interference
    for j=1:active,
        if (i~=j),
            % [i j]
            aa=interference(i);
            Rtx=R(mode(j,1),mode(i,2));
              
            Rrx=R(mode(i,2),mode(j,1));
            %  mode(i,2),mode(j,1)
            G=Net.gains(mode(j,1),mode(i,2));
            %        mode(j,1),mode(i,2)
            pow_tx=Net.node(mode(j,1)).transmit_pow;
            %pow_tx=0.1;
            pow_i=Rtx*Rrx*G*pow_tx*G_antenna;
            interference(i)= aa+pow_i;
            if output
                disp(sprintf('interferece:  %g>>%g  P_rx=%g W (R_%g=%1.2f, R_%g=%1.2f, G=%g, P_%g=%g W)',mode(j,1),mode(i,2),pow_i,mode(j,1),Rtx,mode(i,2),Rrx,G, mode(j,1),pow_tx));
            end
        end;
    end;
    
    % we calculate the rate of communication
    Rtx=R(mode(i,1),mode(i,2));
    Rrx=R(mode(i,2),mode(i,1));
    G=Net.gains(mode(i,1),mode(i,2));
    pow_tx=Net.node(mode(i,1)).transmit_pow;
    %pow_tx=0.1;
    pow_rx=Rtx*Rrx*G*pow_tx*G_antenna;
    
    SINR=Net.gains(mode(i,1),mode(i,2))*pow_tx/interference(i);
    SINR(i)=pow_rx/interference(i);
    SINR_db=10*log10(SINR);
    
    
    
    if strcmp(receiver_type,'perfect'),
        % we dont call the function 'achievable_rate' because of speed
        % considerations.
        
        %rate=log2(1+SINR)
        %modified_by_ciko
        rate=Net.node(1).bw*z(i)*log2(1+(SINR(i)/z(i)))/1024/1024;
    elseif strcmp(receiver_type,'real')
        if SINR(i)<2.5
            rate=0;
            % break;
            disp('SIRN error')
            %shis ir error state
        elseif SINR(i)>=2.5 && SINR(i)<5
            rate=6;
        elseif SINR(i)>=5 && SINR(i)<15.8
            rate=12;
        elseif SINR(i)>=15.8 && SINR(i)<100
            rate=24;
        elseif SINR(i)>=100
            rate=54;
        end
        %rate=achievable_rate(SINR,receiver_type);
    elseif strcmp(receiver_type,'one')
        rate=z(i);
        
    end;
    if output
        fprintf('transmission: %g>>%g  P_rx=%g W (R_%g=%1.1f,  R_%g=%1.1f,  G=%g, P_%g=%g W) noise=%g W  I_N=%g W \n   SINR=%1.1f (%1.1f db), bitrate=%1.1f Mbps \n',mode(i,1),mode(i,2),pow_rx,mode(i,1),Rtx,mode(i,2),Rrx,G,mode(i,1),pow_tx, Net.thermal_noise_vector(1) ,interference(i),SINR(i),SINR_db,rate);
        
    end
    % we fill in the rate matrix (in vector form)
    if (mode(i,2)>mode(i,1)),
        %     disp('1');
        %rate_matrix((n-1)*(mode(i,2)-1)+mode(i,3),1)=rate;
        nr=(mode(i,3)-1)*n*(n-1)+((n-1)*(mode(i,2)-1)+mode(i,1));
        rate_matrix(nr,1)=rate;
    elseif (mode(i,2)<mode(i,1)),
        %    disp('2');
        %   rate_matrix((n-1)*(mode(i,2)-1)+mode(i,3)-1,1)=rate;
        nr=((mode(i,3)-1)*n*(n-1))+((n-1)*(mode(i,2)-1)+mode(i,1)-1);
        rate_matrix(nr,1)=rate;
        
    end;
    
    %     if (mode(i,1)>mode(i,1)),
    %        % disp('3');
    %         %rate_matrix((n-1)*(mode(i,1)-1)+mode(i,4),1)=-rate;
    %         rate_matrix((mode(i,3)-1)*n*(n-1)+((n-1)*(mode(i,1)-1)+mode(i,1)),1)=-rate;
    %
    %     elseif (mode(i,1)<mode(i,1)),
    %       %  disp('4');
    %        % rate_matrix((n-1)*(mode(i,1)-1)+mode(i,3),1)=-rate
    %        rate_matrix(((mode(i,3)-1)*n*(n-1))+((n-1)*(mode(i,1)-1)+mode(i,1)-1),1)=-rate;
    %     end;
    %mode
    rates(k,:)=[mode(i,1) mode(i,2) mode(i,3) nr z(i) rate SINR(i)];
    k=k+1;
end;


% if (mode(i,2)>mode(i,3)),
%rate_matrix((n-1)*(mode(i,2)-1)+mode(i,3),1)=rate;
%elseif (mode(i,2)<mode(i,3)),
%   rate_matrix((n-1)*(mode(i,2)-1)+mode(i,3)-1,1)=rate;
%end;

