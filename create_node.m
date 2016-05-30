% The function creates a node object and sets the basic properties
% id - node identifier
% tx_pow - transmission power
% fc - carrier frequency
function node=create_node(id, tx_pow,fc)
lambda = physconst('LightSpeed')/fc; %jo lamda=v*T
d=lambda/2;
node.id=id;
node.antenna_element='isotropic';
node.fc=fc;
node.d=d;
node.bw=20e6;
node.transmit_pow=tx_pow;
node.transmitter = phased.Transmitter('PeakPower',tx_pow,'Gain',0,...
    'LossFactor',0,'InUseOutputPort',true);
node.reciever = phased.ReceiverPreamp('Gain',0,...
    'NoiseFigure',0,'ReferenceTemperature',290,'SampleRate',1e6,...
    'SeedSource','Property','Seed',1e3);
node.NoiseBandwidth=20e6;
end
