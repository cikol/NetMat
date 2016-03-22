function copy_to_cluster(cluster,localdir,jobdir,input_files)
for i=1:size(input_files,2)
    

   system(sprintf('pscp -i d:/ui-rtu.ppk %s/%s ciko@%s:%s',localdir,input_files{i},cluster,jobdir));
   system(sprintf('plink -i d:/ui-rtu.ppk ciko@%s "dos2unix %s/%s > /dev/null"',cluster,jobdir,input_files{i}));
  
end
end