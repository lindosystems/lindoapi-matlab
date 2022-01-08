function [x,fval,exitflag,output]=LMintlinprog(f,intcon, A,b,Aeq,beq,lb,ub,options)
%LMINTLINPROG Solve Mixed-Integer Linear Programming problems with LINDO
% API. This program follows the same calling conventions as 'intlinprog', 
% the native mixed integer linear programming solver in Matlab's
% optimization toolbox.
%
%   x = LMintlinprog(f,A,b) solves
%
%            min f'*x    
%            subject to:      A*x <= b
%                       -inf <= x <= inf
%                               x(i) integer for i \in intcon[]
%
%   x = LMintlinprog(f,A,b,Aeq,beq) solves the problem above with additional 
%   equality constraints.
%
%            min f'*x  
%            subject to:      A*x <= b
%                           Aeq*x  = beq
%                       -inf <= x <= inf
%                               x(i) integer for i \in intcon[]
%
%   x = LMintlinprog(f,A,b,Aeq,beq,lb,ub) defines a set of lower and upper
%   bounds on the variables, 
%
%                        lb <= x <= ub
% NOTE: 
%   A variable j \in intcon[] could be declared binary by setting 
%   lb(j)=0 and ub(j)=1;
%
%   options specifies the algorithmic options to be used by the solver.
%     Use the following call to create the default options instance.   
%
%   options = LMintlinprog('default')
%
% Desription of return values:
%
%   [x,fval,exitflag,output] = LMintlinprog(...)
%
%          x : The solution vector solving the problem (if exists any). See
%          exitflag.
%
%       fval : The objective function value at 'x'
%
%    exitflag: The exit flag at termination
%           2  Solver stopped prematurely. Integer feasible point found.
%           1  Optimal solution found.
%           0  Solver stopped prematurely. No integer feasible point found.
%          -2  No feasible point found.
%          -3  Root LP problem is unbounded.
%
%     output : A structure with the following fields
%              .relativegap      Relative MIP gap
%              .absolutegap      Absolute MIP gap
%              .numfeaspoints    Number of feasible points found
%              .numnodes         Number of nodes explored
%              .constrviolation  Max constraint violation
%              .message         An exit message
%
%
% See also: LMsolvem, LMreadMAT, LMprob2mat

%% Copyright (c) 2001-2022
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com   

%%
lindo;
defaultopt = LMoptions('intlinprog');

if nargin==1 && nargout <= 1 && isequal(f,'defaults')
   x = defaultopt;
   return
end

% Set missing arguments
if nargin < 9,
    options = [];
    if nargin < 8,
        ub = [];
        if nargin < 7,
            lb = [];
            if nargin < 6,
                beq = [];
                if nargin < 5,
                    Aeq = [];
                end
            end
        end
    end
end

% Set return values
exitflag = -1;
fval     = []; 
x        = [];
output   = {}; 
output.absolutegap = [];
output.relativegap = [];
output.constrviolation = [];
output.numfeaspoints = [];
output.numnodes = [];
output.message = [];
   
if ( nargin == 1)
   model = f;
   if ( ~isstruct(model) ),
       output.message = 'The input to LMintlinprog should be either a structure with valid fields or consist of at least four arguments.';
       warning(output.message);
       return; 
   end

   if ( ~all(isfield(model, {'f','intcon','Aineq','bineq'})) )
      output.message = 'The structure input to LMintlinprog should contain at least four fields. "f", "intcon","Aineq" and "bineq".';
      warning(output.message);
      return; 
   end

   f = model.f;
   A = model.Aineq; 
   b = model.bineq; 
   intcon = model.intcon;
   
   if (isfield(model, 'options')),
      options = model.options;
   end

   if (isfield(model, 'ub')),
       ub = model.ub;
   end

   if (isfield(model, 'lb')),
      lb = model.lb;
   end

   if (isfield(model, 'beq')),
      beq = model.beq;
   end

   if (isfield(model, 'Aeq')),
      Aeq = model.Aeq;
   end

elseif nargin<3,    
   output.message = 'LMintlinprog requires at least three input arguments.';
   warning(output.message);
   return;    
end

% Set up LSprob structure
LSprob = {};
LSprob.osense = LS_MIN;
[mineq,nineq] = size(A);
[meq,neq] = size(Aeq);
LSprob.A = [A; Aeq];
[m,n] = size(LSprob.A);
LSprob.c = reshape(f,n,1);
LSprob.vtype = repmat('C',1,n);
LSprob.vtype(intcon)='I';
if ( isempty(LSprob.A) )
   LSprob.A = sparse(0,length(f));
elseif ~issparse(LSprob.A)
   LSprob.A = sparse(LSprob.A);
end
csense_le=repmat('L',1,mineq);
csense_eq=repmat('E',1,meq);
LSprob.csense = [csense_le csense_eq];
lidx = find(lb==-inf);
uidx = find(ub==inf);
lb(lidx)=-LS_INFINITY;
ub(uidx)=LS_INFINITY;
clear uidx lidx;
LSprob.lb    = lb;
LSprob.ub    = ub;
clear lb ub;
LSprob.b = [b; beq];
clear csense_le csense_eq;
clear A Aeq b beq;

% Set up LINDO options 'LSopt'
LSopts = LMsolvem('defaults');
[x,y,s,dj,fval,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts);

if nargout>2,
    exitflag = LMexitflag(xsol);
end    

if nargout>3 && isfield(xsol,'mipObj'),
    output.absolutegap = xsol.absgap;
    output.relativegap = xsol.relgap;
    output.constrviolation = xsol.pfeas;            
    output.numfeaspoints = xsol.newipsol;
    output.numnodes = xsol.nBranch+1;
    output.message = xsol.errmsg; 
end


