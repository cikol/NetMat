clear task_in
comment='';
%aplha_v=ones(1,20)*4;
%aplha_v=[2 3 4 5];
%aplha_v=ones(1,5)*4;
aplha_v=[4];
%paths_v=[1 2 3 4];
paths_v=[2];
%N_v=[2 4 6 8 10 12 14 16 32 64];
%N_v=[4 8 16];
N_v=[1];
%N_v=ones(1,40);
%N_v=[25 36 49 64 81];
system='hpc';
%name='dof_randN2';
name='find_route_test_intersects';
%name='dof_vs_vector';
%name='smart_rand_N';
%name='interpath_metrics_ns2_allmetrics'; % optimal paths+ marðrutu izvçles stratçìija
%name='regular';
%name='mimo_new_paths'; %tests ar citu ic strategiju
%name='interpath_random';
%name='interpath_new_metrics_optimal';
%name='interpath_allmetrics';
%name='interpath_allmetrics_smart';
%name='interpath_smart_random_gain';
%name='interpath_smart_random_new';

cluster=parcluster('rtuhpc');
  %  tag=sprintf('%s field=%d-%d paths=%d',comment,min(aplha_v),max(aplha_v),paths_v(n1));
    
%    job.Tag=tag;

for n1=1:length(paths_v)
    k=1;
    for n2=1:length(aplha_v)
        for n3=1:length(N_v)
            task_in{1,k}={aplha_v(n2),paths_v(n1),N_v(n3),system,name};
            %    [aplha_v(n2) paths_v(n1)]
            k=k+1;
        end
    end
    job=createJob(cluster);
    %createTask(job, @main_tool, 1, task_in)
    createTask(job, @run_komandu_izpilde_test_routing, 1, task_in)
    submit(job)
end

    
    


% addpath('D:\Dropbox\Phd\matlab\2013_smart_antenna','D:\Dropbox\Phd\matlab\lpsolve','D:\Dropbox\Phd\matlab\wireless_capacity');
% cluster=parcluster('rtuhpc');
% job1=createJob(cluster);
% tasks1=createTask(job1, @run_komandu_izpilde5_cluster, 1, task_in);
% submit(job1);
% res=fetchOutputs(job1);