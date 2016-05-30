% starts NS-2 simulation on remote (HPC) system
function [res]=ns2_cluster_4(field,s_ids,d_ids,pow,fc,paths,P_cst,nr,noise,co,res)
tic
whos
rate_max_sum=0;
last_delay_sum=0;
max_tries=1;
tr=0;
delay=zeros(1,paths);
%delay_sum=zeros(1,paths);
dev=zeros(1,paths);
last_delay=zeros(1,paths);
kr=zeros(1,paths);
f_id=round(rand()*100000);

% system('export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/exp_soft/balticgrid/APPS/NETW/NS2/ns-2.33/lib/');
% system('export PATH=$PATH:/opt/exp_soft/balticgrid/APPS/NETW/NS2/ns-2.33/ns-2.33/');
system('cp ~/matlab/*.tcl .')
for rep=1:max_tries
    log_filename='/dev/null';
    rate1=100000;
    rate_max=rate1;    
    %set initial step
    if paths==4
        rate_step=25000;
    elseif paths==3
        rate_step=50000;
    elseif paths==2
        rate_step=75000;
    elseif paths==1
        rate_step=100000;
    end
    
    for tries=1:6
        %create settings file
        co_s=num2str(co);
  settings_ns2(field,pow,fc,P_cst,noise,rate1,rate_step,co_s);
                
        %% udp
        system(sprintf('ns wireless_c2.tcl >> %s',log_filename));
        system('cat /proc/loadavg')
            sent=zeros(19,paths);
            rate=zeros(19,paths);
            D=ones(19,paths);
        for n=1:paths
            
%             c1=sprintf('./through_D.sh %d %d %s; cat graph2.dat', ...
%             s_ids(n),d_ids(n),'cbr');
%             [foo,thr]=system(c1);
%             thr_num=str2num(thr);
%             sent(:,n)=thr_num(:,2);
%             rate(:,n)=thr_num(:,3);
              %D(:,n)=thr_num(:,2)-thr_num(:,3);
             [sent(:,n),rate(:,n)]=zudumi(s_ids(n),d_ids(n));
             if min(sent(:,n))==0
             D(:,n)=D(:,n)*inf;
             else
             D(:,n)=sent(:,n)-rate(:,n);
             end
        end
        sent_sum=sum(sent,2);
        D_sum=sum(D,2);
        rate_sum=sum(rate,2);
        losses=D_sum./sent_sum;
        disp([int32(sent) int32(rate) int32(losses*100)])

        if max(rate_sum)==0
           disp('No route!!!!');
           rate_max=NaN;
           rate_max_avg=NaN;
           delay_avg=NaN;
           dev_avg=NaN;
           last_delay_avg=NaN;
           t_ns2=toc;
            mat_filename=sprintf('out%d.mat',nr);
            save(mat_filename, 'rate_max_avg','delay_avg','dev_avg','last_delay_avg','t_ns2');
           return
        end
        opt=0;
        size_losses=size(losses,1);
        for nn=2:size_losses
            if losses(nn)<0.0011
                opt=opt+1;
            else
                break
            end
        end
        if tries~=6
           % rate
            % ja nav pçdçjais cikls
            
            if opt==0
                % ja nav pçdçjais cikls, bet ir 0
                if tries==1
                    % ja ir pirmais cikls un ir 0
                    
                    rate1=rate1/2;
                    rate_max=NaN;
                else
                    % ja ir 0 kaut kur pa vidu
                      %cbr_max(:,tries)=rate_max;
                      rate_max=rate_max;
                    break
                    
                end
            else
                %izpildas normala gadijuma
                opt=opt+1; % jo losses tiek mekletas no 2. ieraksta
                rate_max=rate1+rate_step*(opt-1);
                rate1=rate1+rate_step*(opt/1.8);
                for dd=1:paths
                  [del_,dev_,last_delay(dd)]=delays(s_ids(dd),d_ids(dd),opt+1);
                  delay(dd)=delay(dd)+del_;
                  dev(dd)=dev(dd)+dev_;
                  if del_~=0
                     kr(dd)=kr(dd)+1;      
                  end
                end
                
            end
            
            if opt~=size(losses,1)
                %izpildas normala gadijuma
                rate_step=rate_step/2;
                
            end
            
        else
            if opt~=0
                opt=opt+1; % jo losses tiek mekletas no 2. ieraksta
                rate_max=rate1+rate_step*(opt-1);
                
                
            end
        end
        
        
        [int32(tries) int32(opt) int32(rate1) int32(rate_max)]
%         [del_ dev_]
%                 [kr]
%         
%         [delay./kr]
%         [dev./kr]
%         
        %  cbr_max(:,tries)=co(v,:)'*round(rate_max)
        
    end
    if ~isnan(rate_max)
        rate_max_sum=rate_max_sum+rate_max;
        last_delay_sum=last_delay_sum+last_delay;
%         for dd=1:paths
%             delay_sum(:,dd)=delay_sum(:,dd)+delay(dd);
%             dev_sum(:,dd)=dev_sum(dd)+dev(dd);
%         end
        tr=tr+1;
    end
end

rate_max
rate_max_avg=rate_max_sum/tr
last_delay_avg=last_delay_sum/tr
% delay_avg=delay_sum./tr
% dev_avg=dev_sum./tr

delay_avg=delay./kr
dev_avg=dev./kr

t_ns2=toc;
mat_filename=sprintf('out%d.mat',nr);
save(mat_filename, 'rate_max_avg','delay_avg','dev_avg','last_delay_avg','t_ns2');
res(nr,1)=f_id;
res(nr,2)=size(co,1);

function [avg_delay,dev,last_delay]=delays(s_id,d_id,m_r)
[a,s_t]=system(sprintf('cat out.tr | /bin/grep AGT | /bin/grep _%d_ | cut -f2,7 -d '' ''',s_id));
[a,r_t]=system(sprintf('cat out.tr | /bin/grep AGT | /bin/grep _%d_ | cut -f2,7 -d '' ''',d_id));
s_t=str2num(s_t);
r_t=str2num(r_t);
n_records=size(s_t,1);
t2=zeros(n_records,1);

for n=1:n_records
    t1=s_t(n,1);
    id_s=s_t(n,2);
    if max(r_t(:,2)==id_s)==1
        r_t(r_t(:,2)==id_s,1);
        t2(n)=mean(r_t(r_t(:,2)==id_s,1)-t1);
    else
        t2(n)=0;
    end
end
times=[s_t(:,1) t2];

avg_delay=mean(times(times(:,1)>2 & times(:,1)<m_r-1 & times(:,2)~=0,2));
dev=std(times(times(:,1)>2 & times(:,1)<m_r-1 & times(:,2)~=0,2));
if isnan(avg_delay)
    avg_delay=0;
    dev=0;
end
last_delay=mean(times(times(:,1)>m_r-1 & times(:,1)<m_r & times(:,2)~=0,2));

function [s,r]=zudumi(s_id,d_id)
string1=sprintf('cat out.tr | /bin/grep AGT | /bin/grep ^s| /bin/grep -F "[%d:" | /bin/grep "%d:" | /usr/bin/cut -f2,7 -d\\ ',s_id,d_id);
[a,s_t]=system(string1);
[a,r_t]=system(sprintf('cat out.tr | /bin/grep AGT | /bin/grep ^r| /bin/grep -F "[%d:" | /bin/grep "%d:" | /usr/bin/cut -f2,7 -d\\ ',s_id,d_id));
%[a,s_t]=runCmdOnClusterAndReturnOutput('cd wireless_c/job42173/144777.torks/;cat out.tr | /bin/grep AGT | /bin/grep _0_ | cut -f2,7 -d '' ''','85.254.226.77');
%[a,r_t]=runCmdOnClusterAndReturnOutput('cd wireless_c/job42173/144777.torks/;cat out.tr | /bin/grep AGT | /bin/grep _5_ | cut -f2,7 -d '' ''','85.254.226.77');

size(s_t);
size(r_t);
s_t=str2num(s_t);
r_t=str2num(r_t);
s=zeros(19,1);
r=zeros(19,1);

if size(r_t,1)<1
      return
end


for sec=1:19
    sent=s_t(s_t(:,1)>sec & s_t(:,1)<sec+1,:);
    resv=r_t(r_t(:,1)>sec & r_t(:,1)<sec+1.2,:);
    s(sec)=size(sent,1);
    for packet=1:size(sent,1)
        %sent(packet,:)
        
        if max(resv(:,2)==sent(packet,2))==1
            
            r(sec)=r(sec)+1;
            %sent(packet,:)
            %resv(resv(:,2)==sent(packet,2),:)
        end
    end
    
end
s=s*512*8;
r=r*512*8;
