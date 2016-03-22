function N=new_network_1(N,topology,positions,fading,transceivers,antenna_type,reciever,t_p,x_p,f_p)
rng('shuffle')
% We set the general parameters =============================
N.topology=topology;
N.fading=fading;
N.type=antenna_type;
%N.transceivers=transceivers;
N.topology_parameters=t_p;
N.fading_parameters=f_p;
N.transceiver_parameters=x_p;
N.reciever=reciever;
check1=strcmp(topology,'linear');
check2=strcmp(topology,'random');
check3=strcmp(topology,'ring');
check4=strcmp(topology,'regular');
check5=strcmp(topology,'optimal_CS');

if (check1 | check2 | check3 | check4 | check5),
    N.size=t_p(1);
end;

check4=strcmp(transceivers,'transceivers1');
if check4,
    N.bandwidth=x_p(2);
end;
%% Mezglu pozîcijas
if isempty(positions)
    if strcmp(topology,'random'),
        length_box=2*t_p(2);
        offset=-[ones(N.size,1)*t_p(2) ones(N.size,1)*t_p(2)];
        rand_part=[rand(N.size,1)*length_box rand(N.size,1)*length_box];
        N.positions=[offset+rand_part];
    elseif strcmp(topology,'linear'),
        N.positions=[linspace(-t_p(2),t_p(2),N.size)' zeros(N.size,1)];
    elseif strcmp(topology,'ring'),
        for i=1:N.size,
            N.positions(i,1)=t_p(2)*cos(2*pi*(i-1)/N.size);
            N.positions(i,2)=t_p(2)*sin(2*pi*(i-1)/N.size);
        end;
    elseif strcmp(topology,'optimal_CS'),
        tx_d=t_p(3);
        N.positions=zeros(N.size,2);
        N.positions(1:(N.size-2)/2,:)=[linspace(-t_p(2)+tx_d/2,t_p(2)-tx_d/2,(N.size-2)/2)' ones((N.size-2)/2,1)*((tx_d/2)+tx_d*0.4)];
        N.positions((N.size-2)/2+1:N.size-2,:)=[linspace(-t_p(2)+tx_d/2,t_p(2)-tx_d/2,(N.size-2)/2)' -ones((N.size-2)/2,1)*((tx_d/2)+tx_d*0.4)];
        N.positions(N.size-1,:)=[-t_p(2)+tx_d/4 0];
        N.positions(N.size,:)=[t_p(2)-tx_d/4 0];
    elseif strcmp(topology,'regular'),
        length_box=2*t_p(2);
        d=length_box/(sqrt(N.size)-1);
        i=1;
        for x=-t_p(2):d:t_p(2)
            for y=t_p(2):-d:-t_p(2)
                N.positions(i,:)=[x y];
                i=i+1;
            end
        end
    end;
else
    N.positions=positions;
end
if ~strcmp(topology,'regular')
    % N.positions(1,:)=[-t_p(2) 0];
    %  N.positions(N.size,:)=[t_p(2) 0];
end

for n=1:N.size
    pos=[N.positions(n,:) 0]';
    N.node(n).position=phased.Platform('InitialPosition',pos,'Velocity', [0;0;0]);
end
%% Thermal noise power
N.max_power_vector=N.node(1).transmitter.PeakPower*ones(N.size,1);
%% Pastiprinâjums starp mezgliem
N=set_gains_1(N);
end