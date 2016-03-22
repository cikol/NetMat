function Net=weights(Net,mode)
% aprçíinât beamforming svara koeficientus vçrðot galveno staru pret
% mezglu ar kuru notiek pârraide. Netiek vçrstas nulles pret
% traucçtâjiem
active=length(mode(:,1));

for i=1:active
    
    %lenkis aktivais raidîtâjs > uztvçrçjs
    %formats Net.angles(rx_id,TX_id)
    tx_ang=Net.angles{mode(i,1),mode(i,2)};
    %lenkis aktivais  uztvçrçjs > raiditajs
    %formats Net.angles(tx_id,RX_id)
    rx_ang=Net.angles{mode(i,2),mode(i,1)};
    
    
    %calculate beamforming weights
    % tabula ar aktivo raiditaju beamforming svara koeficientiem
    % formats: w_tx=[w_tx_1) w_tx_2... w_tx_n]
    N=Net.node(mode(i,1)).directivity.N;
    [~,Net.node(mode(i,1)).directivity.weights] = step(Net.node(mode(i,1)).directivity.beamformer,ones(1,N),tx_ang);
    Net.node(mode(i,2)).directivity.weights=[];
    N=Net.node(mode(i,2)).directivity.N;
    % formats: w_tx=[w_rx_1) w_rx_2... w_rx_n]
    [~,Net.node(mode(i,2)).directivity.weights] = step(Net.node(mode(i,2)).directivity.beamformer,ones(1,N),rx_ang);
end
end