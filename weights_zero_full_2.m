function Net=weights_zero_full_2(Net,node1,node2,intr,type)
% aprçíinât beamforming svara koeficientus vçrðot galveno staru pret mezglu
% ar kuru notiek pârraide. Netiek vçrstas nulles pret traucçtâjiem
N=Net.node(node1).directivity.N;
Net.node(node1).directivity.weights=[];
ang=Net.angles{node1,node2};
if strcmp(type,'steer')
    [~,w] = step(Net.node(node1).directivity.beamformer,ones(1,N),ang);
    %plotResponse(hula,fc,physconst('LightSpeed'),'weights',w,'RespCut','Az','Format','polar','Unit','mag');
    Net.node(node1).directivity.weights=w;
elseif strcmp(type,'zfbf')
    A(:,1)=gen_AF(N,ang(1));
    for n=1:length(intr)
        intr_ang=Net.angles{node1,intr(n)};
        A(:,n+1)=gen_AF(N,intr_ang(1));
    end
    u=[1 zeros(1,length(intr))];
    noise=eye(N)*0.001^2;
    Net.node(node1).directivity.weights=[];
    Net.node(node1).directivity.weights=(u*A'*inv(A*A'+noise))';
end
end