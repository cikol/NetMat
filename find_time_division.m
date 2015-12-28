% function find_time_division=find_time_division(A,b);
%
% Stavros Toumpis, July '01.
% FILE #15.
%
% This function accepts as input a matrix A containing a set of matrices, 
% and a vector b containing a rate matrix, and checks if the rate matrix
% belongs in the capacity region created from the rate matrices in A.
% If yes, it prints out a time division that will achieve a rate
% matrix BETTER than b.
%
% Input Parameters
% ================
% A: a (n*(n-1),k) matrix containing k rate matrices in vector form
%   in each of its columns. The rate matrices correspond to modes of a 
%   network of size n.
% b: a (n*(n-1),1) vector containing a rate matrix in vector form.
%
% Output Parameters
% =================
% find_time_division: * a two column matrix containing the time 
%                       percentages in the first column and the 
%                       positions of the required rate matrices in A, 
%                       if the time division is achievable. The position 
%                       0 signifies the quiet mode, and appears last.
%                     * [0 0], if b does not belong in the capacity region.
%
% NUMERICAL STABILITY ISSUES
% ==========================
% There are two known cases in which the routine will fail:
%  1)if the critical elements of b are much smaller than the critical
%    elements of Asmall (for example b=10^-9*ones(9,1), A=eye(9)),
%    the real objective will be around 0, but will be truncated to 0
%    exactly.
%  2)if the critical elements of both A and b are small( for example
%    ~10^-5), and the real objective is between 0 and 1, the routine will 
%    fail and will wrongly claim that the problem is infeasible.

function find_time_division=find_time_division(A,b);

% Initializing
% ============
find_time_division=[];
[m k]=size(A);


% We calculate the time_division
% ==============================

if (min(b)<0),
  find_time_division=[0 0];
else,
  % we solve a linear programming problem
  obj=[];
  %[obj,x]=lp_solve(-ones(k,1),A,b,ones(m,1),zeros(k,1),ones(k,1));
 %A
 
 %b
  [obj,x,]=lp_solve(-ones(k,1),A,b,ones(m,1),zeros(k,1),ones(k,1));
  if ~isempty(obj),
    % the optimization finished successfully
    xsum=-obj;
    if (xsum<=1)
      % the rate matrix lies in the capacity region,
      % so we construct the time division
      for i=1:length(x);
        if (x(i)>0),
          find_time_division=[find_time_division
                              x(i) i]     ;
        end;
      end;
      if (1-xsum>0),
          find_time_division=[find_time_division
                              1-xsum 0];
      end;
    else, 
      find_time_division=[0 0];
    end;
  else, 
    find_time_division=[0 0];
  end;
end;



