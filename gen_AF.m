function [AFs]=gen_AF(N,etha)
fc = 2.45e9;
lambda = physconst('LightSpeed')/fc; %jo lamda=v*T
delta=0;k=2*pi/lambda;d=lambda/2;
etha=-etha*pi/180;
n=1:N;
AFs=exp(1j*(n-1)*(k*d*sin(etha)+delta))';

%% lai ìenerçtu visas AF
%ethaa=linspace(-pi,pi,361);
% AF=zeros(N,180);
% for nn=1:length(ethaa)
%     AF(:,nn)=exp(1j*(n-1)*(k*d*sin(ethaa(nn))+delta))';
% end
%AFs=AF(:,181+int16(etha));

end