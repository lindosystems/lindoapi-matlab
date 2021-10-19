function [E,eb,ec,x,z,how] =LMbinpack(a,cap)
% LMBINPACK: Solves the Dantzig-Wolfe relaxation to the bin packing problem.
%  
% Usage: [E,eb,ec,x,z,how] = LMbinpack(a,cap)
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%


% Last update Jan 09, 2007 (MKA)
%   
% INPUT:
%    a:  n-by-1 column vector for weights of items to be packed  > 0.    
%   cap:  1-by-1 (scalar) bin capacity  > 0.
%
% OUTPUT: 
%    E:  n-by-k matrix where its columns correspond to the incidence 
%        vectors of feasible bin-loadings.       
%   eb:  n-by-1 column vector of all ones (rhs in the DW formulation).
%   ec:  k-by-1 column vector of all ones (obj function in the DW formulation).
%    x:  optimal solution to the DW relaxation of the bin packing problem.
%    z:  lower bound for the minimum number of bins required.
%  how:  status of the solution


if nargin < 2,
    if nargin>0,        
        cap = floor(sum(a)/3);
        fprintf(' Setting capacity to %g... \n',cap);
    else
        fprintf(' Generating 100 items to pack randomly... \n');
        [a,cap]=randombin(100);
        fprintf(' Setting capacity to %g... \n',cap);
    end;    
end;

%************************* INIT *************************************
% initialize the senses of the variables and constraints involved
% before passed to LINDO callable library
%********************************************************************

zerotol  = 1.0e-7; % tolerance for zero reduced cost
dispfreq = 1;      % display progress at every 5 iteration  

n0       = length(a); % number of objects to be packed
maxncols = n0*10;     % max number of columns allowed in column generation

% find an initial solution and keep the solution vectors in E
[E,eb,ec,z]=LSinitbin(a,cap,3);
E = eye(n0);
ec = ones(n0,1);
ncols = 0;
hist  = [];
how   = 'Unknown';

% display banner
fprintf('\n\n');
fprintf('%15s %15s %15s\n','Num cols ','Obj of DW ','Reduced cost ');
fprintf('%15s %15s %15s\n','generated','relaxation','of new column');
fprintf('%15s %15s %15s\n','---------','----------','-------------');

t=cputime; % record current time

csense=[]; 
for i=1:length(eb), 
   csense=[csense 'E']; 
end;

vtype=[]; 
for i=1:length(eb), 
   vtype=[vtype 'I']; 
end;

lb = []; % use default lower bounds
ub = []; % use default upper bounds
ubk = ones(length(eb),1);

opts={};
opts.iDefaultLog=0;

LSprob = {};
LSprob.c = ec;
LSprob.A = sparse(E);
LSprob.b = eb;
LSprob.lb = lb;
LSprob.ub = ub;
LSprob.csense = csense;

%%%%%%%%%%%%%%%%%%%%%%%%%
% main loop begins
%%%%%%%%%%%%%%%%%%%%%%%%%
while ncols <= maxncols,   
   
   % ***********************  STEP 1 ***************************************
   % * solve the current D-W relaxation using lmsolvem.m 
   % * minimize {c^T.x : Ex = b, x>=0},  
   % ***********************************************************************
   
   [x,y,s,dj,z,stat,nErr] = LMsolvem(LSprob,opts);   
   % x -  primal optimal solution
   % y -  dual optimal solution
   % z -  objective

   
   % ***********************  STEP 2 ***************************************
   % * solve a knapsack problem to generate an entering column by solving
   % * maximize {w^T.v = a^T.v <= cap, v_j \in {0,1} }
   % *   v    - the solution is the incidence vector of the candidate column 
   % *   zknp  - the optimal solution to the knapsack       
   % ******************************* ***************************************
   LSsub = {};
   LSsub.A = sparse(a');
   LSsub.b = cap;
   LSsub.c = -y;
   LSsub.csense = 'L';
   LSsub.lb = [];
   LSsub.ub = ubk;
   LSsub.vtype = vtype;
   [v,y,s,dj,zknp,stat,nErr]     = LMsolvem(LSsub,opts);
   
   %negate obj value as the knapsack was a maximization type
   zknp         = -zknp;     
   
   %compute reduced cost, note that c_j = 1
   cj_zj       =  zknp - 1;     
   
   % ************************ STEP 3 ***************************************
   % ** if the max cj_zj is positive, 
   % **    append the column found to E and continue
   % ** else 
   % **    terminate 
   %************************************************************************
   if cj_zj > zerotol,
     LSprob.A   = [LSprob.A   v];
     LSprob.c   = [LSprob.c ;1];
     ncols = ncols+1;      
   else      
     how  = 'LP relaxation is optimal';
     break;
   end;   
   
   %  ** print to screen
   %
   if mod(ncols,dispfreq)==0,
      fprintf('%15d %15.3f %15.3f\n',ncols,z,cj_zj);
   end;
   
end;

%*************************** FINISH *************************************
% End of run. 'z' provides a lower bound to the number of
% bins required the pack the weights in w.
%************************************************************************
fprintf('%15d %15.3f %15.3f\n',ncols,z,cj_zj);
t=cputime - t;
fprintf('\n');
fprintf('Elapsed time  = %10.3f secs\n',t);
fprintf('Minimum bins >= %10.3f\n',z);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A Simple Heuritics for the Bin Packing Problem
%
%
function [z] = mypow(a,b)
z = a^b;

% A Simple Heuritics for the Bin Packing Problem
% Usage: [E,eb,ec,z]=LSinitbin(a1,cap,heuristic)
function [E,eb,ec,z]=LSinitbin(a1,cap,heuristic)
if nargin <3
   heuristic = 1;
end;

n = length(a1);

switch heuristic
case 1,  
   [a,j] = sort(-a1); 
   a=-a;
case 2,
   [a,j] = sort(a1);
otherwise,
   a=a1;
   j=[1:n]';
end;

X=[];
z = 0;
i = 0;
while i < n,
   load=0;
   idx=[];
	while a(i+1)+load <= cap,
        idx=[idx i+1];
        load = load + a(i+1);
        i=i+1;
        if i==n, break; end;
	end;
   x=zeros(n,1);
   x(j(idx))=1;
   X =[X x];
   z = z + 1;
end;
E=X;
eb=ones(n,1);
ec=ones(z,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate a random bin packing instance
%
%
function [a,cap] = randombin(n)
% generate a random bin packing instance
% with an initial seed based on current time
rand('state',sum(100*clock));

a  = floor(n*rand(n,1));
ii = floor(log(n));
cap = floor(sum(a)/ii/ii);


