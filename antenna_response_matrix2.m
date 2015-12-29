function R=antenna_response_matrix2(Net,mode)

%if strcmp(type,'array'),
    R=zeros(Net.size);
    active=length(mode(:,1));
    fc=Net.node(1).fc;
    
    
    for i=1:active
        for j=1:active
            % [i j]
            %release(Net.node(mode(i,1)).array_response);
            %release(Net.node(mode(j,2)).array_response);
            
            %[mode(i,1) mode(j,2)]
            % lenkis raiditajs > uztverejs
            tx_ang=Net.angles{mode(i,1),mode(j,2)};
            % uztverejs1 > uztverejs2
            % tx_tx_ang=Net.angles{mode(i,1),mode(j,1)};
            %[mode(j,2) mode(i,1)]
            % lenkis uztverejs > raiditajs
            rx_ang=Net.angles{mode(j,2),mode(i,1)};
            % antenna response raiditajam_i
            
            % R_tx=step(Net.node(mode(i,1)).array_response,fc,[tx_ang], Net.node(mode(i,1)).weights);
            N=Net.node(mode(i,1)).directivity.N;
            w_tx=Net.node(mode(i,1)).directivity.weights;
            AF_tx=gen_AF(N,tx_ang(1));
            
            R_tx=w_tx'*AF_tx;
            
            %   release(Net.node(mode(i,1)).array_response);
            % R_tx_tx=step(Net.node(mode(i,1)).array_response,fc,[tx_tx_ang], Net.node(mode(i,1)).weights);
            % antenna response uztverejam_j
            %  R_rx=step(Net.node(mode(j,2)).array_response,fc,[rx_ang], Net.node(mode(j,2)).weights);
            N=Net.node(mode(j,2)).directivity.N;
            w_rx=Net.node(mode(j,2)).directivity.weights;
            AF_rx=gen_AF(N,rx_ang(1));
            R_rx=w_rx'*AF_rx;
            
            %forme tabulu ar mezglu savstarpejiem antenna responses
            %formats R=[      0       node_1>node_2 node_1>node_3 ... node_1>node_j
            %           node_2>node_1       0       node_2>node_3 ... node_2>node_j
            %           node_3>node_1 node_1>node_2       0       ... node_1>node_j
            %                                  ...........
            %           node_i>node_1 node_i>node_2 node_i>node_3 ...       0       ]
            
            
            R(mode(i,1),mode(j,2))=abs(R_tx);
            R(mode(j,2),mode(i,1))=abs(R_rx);
            
        end
    end
    
    %plotResponse(Net.node(4).array,fc,physconst('LightSpeed'),'weights',w_rx(:,2),'RespCut','Az','Format','line', 'Unit','mag','NormalizeResponse',false)
%else
%    R=ones(Net.size);
%end
end

