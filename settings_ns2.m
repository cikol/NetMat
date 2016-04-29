function settings_ns2(field,pow,fc,P_cst,noise,rate1,rate_step,co)
fid2=fopen('settings.txt', 'w'); 

%NS2 model
 fprintf(fid2,'set t1 %s\n','1');
 fprintf(fid2,'set t2 %s\n','2');
 fprintf(fid2,'set temp3 {%s}\n',co);
 fprintf(fid2,'set rate %d\n',rate1);
 fprintf(fid2,'set opt(stop) %d\n',20);
 %fprintf(fid2,'set opt(a) %g \n',nodes+paths-1);
 fprintf(fid2,'set opt(x) %d\n',field);
 fprintf(fid2,'set opt(y) %d\n',field);
 %IEEE802.11a
 fprintf(fid2,'Phy/WirelessPhyExt set CSThresh_ %g \n',P_cst);
 fprintf(fid2,'Phy/WirelessPhyExt set Pt_ %g \n',pow);
 fprintf(fid2,'Phy/WirelessPhyExt set freq_ %g \n',fc);
 % pasha antenas un vides troksni
 fprintf(fid2,'Phy/WirelessPhyExt set noise_floor_ %g \n',noise);
 % Power monitor jutiba. Troksnus zem thresholda nenjem varaa.
 fprintf(fid2,'Phy/WirelessPhyExt set PowerMonitorThresh_ %g \n',noise/3);
%  

 fprintf(fid2,'set rate_step %d\n',rate_step);
fclose(fid2); 
 %system('pscp -i ui-rtu.ppk settings.txt ciko@85.254.226.28:scratch');
 
 end