% function set_gains=set_gains(N);
%
% Stavros Toumpis, July '01.
% FILE #3.
%
% This function accepts as input a network structure, and returns another
% network structure identical to the input in every respect but the power
% gains, which are calculated for the first time or anew, according to the
% information stored in the fields of the original network.
%
% Input Parameters
% ================
% N: A network structure, possibly created by the 'new_network' routine.
%
% Output Parameters
% =================
% set_gains: A network that is identical to N in every respect, except
%   from the gains (NOT the gain statistics).

function set_gains=set_gains_1(Net);

% the new network is identical to the original one, except from the gains
set_gains=Net;
fc=Net.node(1).fc;
lambda = physconst('LightSpeed')/fc; %jo lamda=v*T
% 
% 
% 
% if strcmp(Net.fading,'fading1'),
%     
%     % we calculate the new power gains
%     for i=1:Net.size,
%         for j=1:Net.size,
%             if (i==j),
%                 set_gains.gains(i,j)=0;
%                 set_gains.angles{i,j}=0;
%             elseif (i>j),
%                 tx_pos=Net.node(i).position.InitialPosition;
%                 rx_pos=Net.node(j).position.InitialPosition;
%                 %[x,y]=rangeangle(rx_pos,tx_pos)
%                 [set_gains.distances(i,j),set_gains.angles{i,j}] = rangeangle(rx_pos,tx_pos);
%                 [set_gains.distances(j,i),set_gains.angles{j,i}] = rangeangle(tx_pos,rx_pos);
%                 L(i,j)=1/db2pow(fspl(set_gains.distances(i,j),lambda));
%                 
%                 
%                 set_gains.gains(i,j)=1/db2pow(fspl(set_gains.distances(i,j),lambda));
%                 set_gains.gains(j,i)=set_gains.gains(i,j);
%             end;
%         end;
%     end;
%     
% end
%if strcmp(Net.fading,'fading2'),
    
    % we set the parameters
    d0=Net.fading_parameters(1);
    alpha=Net.fading_parameters(2);
    sigma=Net.fading_parameters(3);
    
    % No Andrea Goldsmith
    K=(lambda^2)/(4*pi*d0)^2;
    
    % we calculate the new power gains
    if (sigma==0),
        RM=ones(Net.size,Net.size);
    else
        RM=10.^(normrnd(0,sigma,Net.size,Net.size)/10);
    end;
    for i=1:Net.size,
        for j=1:Net.size,
            if (i==j),
                set_gains.gains(i,j)=0;
                set_gains.angles{i,j}=0;
            elseif (i>j),
                tx_pos=Net.node(i).position.InitialPosition;
                rx_pos=Net.node(j).position.InitialPosition;
                %[x,y]=rangeangle(rx_pos,tx_pos)
                [set_gains.distances(i,j),set_gains.angles{i,j}] = rangeangle(rx_pos,tx_pos);
                [set_gains.distances(j,i),set_gains.angles{j,i}] = rangeangle(tx_pos,rx_pos);
                
                
                set_gains.gains(i,j)=K*RM(i,j)/((set_gains.distances(i,j)/d0)^(alpha));
                set_gains.gains(j,i)=set_gains.gains(i,j);
            end;
        end;
    end;
    
%end;
end