% function display_network(N,fig,s_id,d_id);
%
% Stavros Toumpis, July '01.
% FILE #4.
%
% This function displays the properties of a network specified in the
% structure N.
%
% Input Parameters
% ================
% N: A network structure, possibly created with the routine 'new_network'.
% fig: The figure in which the network positions will be displayed.
%
% Output Parameters
% =================
% None.

function display_network(N,fig,s_id,d_id);

% We plot the positions of the nodes 
% ==================================
figure(fig);
hold off;
clf;
hold on;
sizes=100*ones(length(N.positions(:,1)),1);
%colors=zeros(length(N.positions(:,1)),1);
scatter(N.positions(:,1),N.positions(:,2),sizes,'k','filled');
scatter(N.positions(s_id,1),N.positions(s_id,2),100,'k','filled','MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 1]);
scatter(N.positions(d_id,1),N.positions(d_id,2),100,'k','filled','MarkerFaceColor',[0 0 1],'MarkerEdgeColor',[0 0 1]);
axis equal;
len=N.topology_parameters(2);
if strcmp(N.topology,'random') | strcmp(N.topology,'regular');
  margin=1.2*len;
  axis([-1 1 -1 1]*margin);
  offset=margin/30;
elseif strcmp(N.topology,'ring'),
  margin=1.2*len;
  x1=len*cos(2*pi*[0:0.005:1]);
  x2=len*sin(2*pi*[0:0.005:1]);
  h=plot(x1,x2,'k:');
  set(h,'linewidth',0.5);
  axis([-1 1 -1 1]*margin);
  offset=margin/30;
elseif strcmp(N.topology,'linear'),
  margin=1.2*len;
  axis([-1 1 -0.3 0.3]*margin);
  offset=margin/30;
elseif strcmp(N.topology,'optimal_CS'),
  margin=1.1*len;
  axis([-1 1 -0.1 0.1]*margin);
  offset=margin/30;
end;
for i=1:N.size,
  text(N.positions(i,1)-offset,N.positions(i,2)-offset,num2str(i));
end;
%xlabel('x (m)');
%ylabel('y (m)');
grid on
% We display the network parameters
% =================================
% disp(' ');
% disp(['Topology type: ' N.topology]);
% disp(['Fading type: ' N.fading]);
% disp(['Transceivers type: ' N.transceivers]);
% disp(['Topology parameters: ' num2str(N.topology_parameters)]);
% disp(['Fading parameters: ' num2str(N.fading_parameters)]);
% disp(['Transceiver parameters: ' num2str(N.transceiver_parameters)]);
% disp(['Number of nodes: ' num2str(N.size)]);
% disp(['Bandwidth: ' num2str(N.bandwidth)]);
% disp('The node positions (transposed):');
% disp(N.positions');
% disp('The maximum power vector (transposed):');
% disp(N.max_power_vector');
% disp('The thermal noise power vector (transposed):');
% disp(N.thermal_noise_vector');
% disp('The power gains matrix: ');
% disp(N.gains);

