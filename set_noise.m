 function Net=set_noise(Net,scale)
        
        Net.thermal_noise_vector=physconst('Boltzmann')*systemp(0,Net.node(1).reciever.ReferenceTemperature)*Net.node(1).NoiseBandwidth*ones(Net.size,1)*scale;
    end