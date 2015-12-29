function copy_to_cluster_2(cluster,localdir,jobdir,input_files)
for i=1:size(input_files,2)
    

   system(sprintf('pscp -i ui-rtu.ppk %s/%s ciko@%s:%s',localdir,input_files{i},cluster,jobdir));
   
  
end
end