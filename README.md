# NetMat
Network modelling tool

The main function is main_tool.m

## Toolbox requirements

MATLAB (tested with version 2015a)

Control System Toolbox

Phased Array System Toolbox

Signal Processing Toolbox

Statistics and Machine Learning Toolbox

(optional) lpsolve - Mixed Integer Linear Programming solver. External solver from http://lpsolve.sourceforge.net/


## Input Parameters

Execution format is:

[output]=main_tool(alpha,paths,N,system,name)

alpha - path loss exponent in radio propagation model;

paths - number of simultaneous paths;

N - number of antenna array elements, 1 is for Omni-directional transmission;

system - valid values ar 'local' or 'hpc';

name - name of the task;

Additional parameters can be changed inside M-file.

Example:

[output]=main_tool(4,2,1,'local','testrun')



## Understanding Output

output(:,1) - network id

output(:,2) - number of nodes

output(:,3) - size of edge of 2- dimensional square field

output(:,4) - source id

output(:,5) - destination id

output(:,6) - number of paths

output(:,7) - number of array elements

output(:,8) - id of beamforming method

output(:,9) - antenna gain

output(:,10) - not used

output(:,11) - not used

output(:,12) - path loss exponent

output(:,13) - id for path selection criteria

output(:,14) - number of nodes in paths

output(:,15) - number of path sets found

output(:,16) - distance between source and destination (hops)

output(:,17) - id of antenna type

output(:,18) - average number of hops in paths

output(:,19) - maximal number of hops in paths

output(:,20) - minimal number of hops in paths

output(:,21) - distance between source and destination (meters)

output(:,22) - not used

output(:,23) - first hop angle

output(:,24) - distance between the closest paths

output(:,25) - distance between maximally disjoint paths

output(:,26) - simulation time (scenario generation)

output(:,27) - carrier sense type

output(:,28) - transmission distance

output(:,29) - Phy carrier sense distance

output(:,30) - Phy carrier sense threshold (power)

output(:,31) - ambient noise

output(:,32) - aggregated capacity (uniform)

output(:,33) - aggregated capacity

output(:,34) - simulation time (capacity)
