function res=NS2_wait_results_cluster(res,co)
%% check job to finish
%load(res_file)
scen_count=sum(res(:,1)~=0);
sleep_time=20;
count_jobs=0;
paths=size(co,2);
timeout=0;
%tries=zeros(1,size(res,1));
st=toc;
scen=find(res(:,1)~=0)';
while sum(res(:,5)~=0)~=scen_count;
    disp('--------------------')
    
    for nr=scen
        
        if res(nr,5)==0 && res(nr,1)~=0
            
            f_id=res(nr,1);
            jobs=res(nr,2);
            
            
           
       %     jobdir=sprintf('%s/%s',getenv('MDCE_STORAGE_LOCATION'),getenv('MDCE_TASK_LOCATION'));
       %     localdir=sprintf('%s/job%g',jobdir,f_id);
            
          %  [~,count]=system(sprintf('ls %s/*.mat | wc -l',localdir));
           
            %count=str2double(count);
            count=size(co,1);
            
            disp(sprintf('Scen:%d   Jobs finished: %d from %d',nr,count,jobs))
            
            if count==jobs || timeout>=2500
              %  system(sprintf('scp ciko@%s:%s/*.mat %s',cluster,jobdir,localdir));
              %  system(sprintf('scp ciko@%s:%s/*.mat %s',cluster,jobdir,localdir));
                %cbr_max_=zeros(paths,size(co,1));
                cbr_max_agr_=zeros(1,size(co,1));
                dev_avg_=zeros(1,size(co,1));
                delay_spread_=zeros(1,size(co,1));
                delay_avg_=zeros(1,size(co,1));
                last_delay_avg_=zeros(1,size(co,1));
                for count2=1:jobs
                    rate_max_avg=0;
                    delay_avg=NaN;
                    last_delay_avg=NaN;
                    dev_avg=NaN;
                    t_ns2=NaN;
                   % file_to_load=sprintf('%s/out%d.mat',localdir,count2);
                  
                  file_to_load=sprintf('out%d.mat',nr);
                    
                    [~,b]=system(sprintf('if [ -f %s ]; then echo 0; fi',file_to_load));
                    b=str2num(b);
                    if b==0
                        try
                        load(file_to_load);
                        catch
                        fprintf('NS2 wait results: error loading NS2 results')
                        end
                    end
                    %      cbr_max_(:,count2)=co(count2,:)'*rate_max_avg;
                    cbr_max_agr_(count2)=sum(co(count2,:)'*rate_max_avg)';
                    dev_avg_(count2)=mean(dev_avg);
                    delay_spread_(count2)=max(delay_avg)-min(delay_avg);
                    delay_avg_(count2)=mean(delay_avg);
                    last_delay_avg_(count2)=mean(last_delay_avg);
                end
                %rate
                [ns2_cbr_max,indx]=max(cbr_max_agr_);
                ns2_cbr=cbr_max_agr_(size(co,1))/1024/1024;
                ns2_cbr_max=ns2_cbr_max/1024/1024;
                %delay and deviation
                dev_avg=dev_avg_(size(co,1));
                delay_spread=delay_spread_(size(co,1));
                delay_avg=delay_avg_(size(co,1));
                last_delay_avg=last_delay_avg_(size(co,1));
                
                
                res(nr,3:10)=[ns2_cbr ns2_cbr_max indx delay_avg last_delay_avg dev_avg delay_spread t_ns2];
                count_jobs=count_jobs+1;
               try
                   delete('*');
               catch
                   fprintf('NS2 wait results: error deleting files...')
               end
              % system(sprintf('plink -i ui-rtu.ppk ciko@%s "rm -r %s"',cluster,jobdir));
                
                %             else
                %                 tries(nr)=tries(nr)+1;
                %                 timeout(nr)=tries(nr)*sleep_time;
            end
            
        end
    end
    if sum(res(:,5)~=0)~=scen_count;
        pause(sleep_time)
    end
    ed=toc;
    timeout=ed-st;
end


end
