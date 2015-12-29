function [s,r] = runCmdOnClusterAndReturnOutput(command,cluster)
%RUNCMDONCLUSTER Runs a command on a remote host.

% Copyright 2006 The MathWorks, Inc.

% Use plink (PuTTY Link) to run a command on the remote host. We assume 
% that the user has created a Putty session with the same name as 
% clusterHost.

%clusterHost='ciko@ui.grid.etf.rtu.lv';
cmdForCluster = sprintf('plink -i d:/ui-rtu.ppk ciko@%s "%s"', cluster, command);

for i=1:5
    [s, r] = system(cmdForCluster);
    if s == 0
        break;
    else
        pause(2);
    end
end
if s ~= 0
    error('distcomp:scheduler:FailedRemoteOperation', ...
        ['Failed to run the command\n' ...
        '"%s"\n"' ...
        'on the host "%s".\n' ...
        'Command Output:\n' ...
        '"%s"\n' ...
        ], command, cluster, r);
end
