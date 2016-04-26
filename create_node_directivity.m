function directivity=create_node_directivity(Net,N)
d=Net.node.d;
fc=Net.node.fc;
directivity.N=N;
%% array object definitions
directivity.antenna= phased.IsotropicAntennaElement('FrequencyRange',[2.4e9 2.5e9]);
directivity.array = phased.ULA('Element',directivity.antenna,'NumElements',N,'ElementSpacing',d);
directivity.beamformer = phased.PhaseShiftBeamformer('SensorArray',directivity.array,...
    'OperatingFrequency',fc,'DirectionSource','Input Port',...
    'WeightsOutputPort',true);
directivity.adaptivebeamformer = phased.LCMVBeamformer('DesiredResponse',1,...
    'TrainingInputPort',false,'WeightsOutputPort',true);
%beamoforming weigth = no bf

directivity.radiator = phased.Radiator('Sensor',directivity.array,'OperatingFrequency',fc);
directivity.collector = phased.Collector('Sensor',directivity.array,'OperatingFrequency',fc);

directivity.array_response = phased.ArrayResponse('SensorArray',directivity.array,'WeightsInputPort', true);
[~,directivity.weights]=step(directivity.beamformer,ones(1,N),[0;0]);
end