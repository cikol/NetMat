function [res]=run_ns2_5(Net,s_ids,d_ids,paths,P_cst,nr,co,res)
cluster='85.254.226.77';
if P_cst==Inf
    P_cst=1; %bez cst
end
tic
nodes=Net.size;
pow=Net.max_power_vector(1);
fc=Net.node(1).fc;
noise=Net.thermal_noise_vector(1);
field=Net.topology_parameters(2)*2;
%max_tries=3;
f_id=round(rand()*100000);

jobdir=sprintf('wireless_c/job%g',f_id);
localdir=sprintf('job%g',f_id);
system(sprintf('plink -i ui-rtu.ppk ciko@%s mkdir %s',cluster,jobdir));
mkdir(localdir);
%input_files={'wireless_c2.tcl' 'IEEE802-11a.tcl' 'through_D.sh' 'ns2_cluster_4.m' 'settings_ns2.m' 'pos2.txt' 'routes' 's_d_pair'};
input_files={'pos2.txt' 'routes' 's_d_pair'};
zip('input_files.zip',input_files);
copy_to_cluster_2(cluster,pwd,jobdir,{'input_files.zip'});
system(sprintf('plink -i ui-rtu.ppk ciko@%s cd %s; unzip input_files.zip;i_files=`ls`;dos2unix $i_files',cluster,jobdir));
%dos_2_unix(cluster,jobdir,input_files)

for v=1:size(co,1)
    co_s=num2str(co(v,:));
 %   for tries=1:max_tries
        %% create wrapper
        
        filename=sprintf('submit%g.sh',v);
        path=sprintf('%s/%s',localdir,filename);
        fid2=fopen(path, 'w');
        fprintf(fid2,'#!/bin/bash\n');
        fprintf(fid2,'/bin/hostname\n');
        fprintf(fid2,'cat /proc/loadavg\n');
        fprintf(fid2,'cd $PBS_O_WORKDIR; mkdir $PBS_JOBID; cd $PBS_JOBID; cp ~/matlab/*.m ../pos2.txt ../routes ../s_d_pair  ~/matlab/*.tcl . \n');
        %fprintf(fid2,'chmod +x through_D.sh \n');
        fprintf(fid2,'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/exp_soft/balticgrid/APPS/NETW/NS2/ns-2.33/lib/;\n');
        fprintf(fid2,'export PATH=$PATH:/opt/exp_soft/balticgrid/APPS/NETW/NS2/ns-2.33/ns-2.33/\n');
        %fprintf(fid2,'/opt/exp_soft/balticgrid/MATLAB-2009A/bin/matlab -nodisplay -nojvm -r "ns2_cluster_4(%d,%d,[%s],[%s],%g,%g,%g,%g,%g,''%s'',%d)" \n',nodes,field,num2str(s_ids),num2str(d_ids),pow,fc,paths,P_cst,noise,co_s,v);
        fprintf(fid2,'/opt/exp_soft/MATLAB/bin/matlab -nodisplay -nojvm -r "ns2_cluster_4(%d,%d,[%s],[%s],%g,%g,%g,%g,%g,''%s'',%d)" \n',nodes,field,num2str(s_ids),num2str(d_ids),pow,fc,paths,P_cst,noise,co_s,v);
        fprintf(fid2,'cp *.mat $PBS_O_WORKDIR; cd ..; #rm -rf $PBS_JOBID \n');
        fclose(fid2);
        
        copy_to_cluster(cluster,localdir,jobdir,{filename});
               
        %% job submit
        disp(sprintf('submit job %g: %s',v, filename))
        runCmdOnClusterAndReturnOutput(sprintf('cd %s; qsub -q inf %s',jobdir,filename),cluster);
    
end

res(nr,1)=f_id;
res(nr,2)=size(co,1);


end