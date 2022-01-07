function [x,fval,exitflag,output,lambda]=LMlinprog(f,A,b,Aeq,beq,lb,ub,x0,options)
%LMLINPROG Solve Linear Programming problems with LINDO API. This program
% follows the same calling conventions as 'linprog', the native linear
% programming solver in Matlab's optimization toolbox.
%
%   x = LMlinprog(f,A,b) solves
%
%            min f'*x    
%            subject to:      A*x <= b
%                       -inf <= x <= inf
%
%   x = LMlinprog(f,A,b,Aeq,beq) solves the problem above with additional 
%   equality constraints.
%
%            min f'*x  
%            subject to:      A*x <= b
%                           Aeq*x  = beq
%                       -inf <= x <= inf
%
%   x = LMlinprog(f,A,b,Aeq,beq,lb,ub) defines a set of lower and upper
%   bounds on the variables,
%
%                        lb <= x <= ub
% NOTE: 
%   x0 specifies the starting point and is only available when solving
%     with the standard nonlinear-solver. Other solvers will ignore any 
%     non-empty starting point.
%   
%   options specifies the algorithmic options to be used by the solver.
%     Use the following call to create the default options instance.   
%
%   options = LMlinprog('default')
%
% Desription of return values:
%
%   [x,fval,exitflag,output,lambda] = LMlinprog(...)
%
%          x : The solution vector solving the problem (if exists any). See
%          exitflag.
%
%       fval : The objective function value at 'x'
%
%    exitflag: The exit flag at termination
%               1  LMlinprog converged to a solution x.
%               0  Maximum number of iterations reached.
%              -2  No feasible point found.
%              -3  Problem is unbounded.
%              -4  NaN value encountered during execution of algorithm.
%              -5  Both primal and dual problems are infeasible.
%              -7  Magnitude of search direction became too small; no further
%                  progress can be made. The problem is ill-posed or badly
%                  conditioned.
%
%     output : A structure with the following fields
%              .iterations      Number of iterations 
%              .constrviolation Max constraint violation
%              .algorithm       Algorithm used {primal-simplex,
%                               dual-simplex, barrier-method}
%              .message         An exit message
%
%      lambda: A structure containing the set of Lagrangian multipliers 
%              .ineqlin         Inequality constraints (A)
%              .eqlin           Equality constraints (Aeq)
%              .lower           For lower-bounds (x>=LB)
%              .upper           For upper-bounds (x<=UB)
%
% See also: LMsolvem, LMreadMAT

%% Copyright (c) 2001-2021
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com   

%%
lindo;
defaultopt = {};
defaultopt.Algorithm= 'dual-simplex';
defaultopt.Diagnostics= 'off';
defaultopt.Display= 'iter';
defaultopt.LargeScale= 'on';
defaultopt.MaxIter= 2147483648;
defaultopt.MaxTime= 99999;
defaultopt.Preprocess= 'basic';
defaultopt.Simplex= 'off';
defaultopt.TolCon= 1e-7;
defaultopt.TolFun= 1e-7;

if nargin==1 && nargout <= 1 && isequal(f,'defaults')
   x = defaultopt;
   return
end

% Set missing arguments
if nargin < 9,
    options = [];
    if nargin < 8,
        x0 = [];
        if nargin < 7,
            ub = [];
            if nargin < 6,
                lb = [];
                if nargin < 5,
                    beq = [];
                    if nargin < 4,
                        Aeq = [];
                    end
                end
            end
        end
    end
end

% Set return values
exitflag = -1;
fval     = []; 
lambda   = [];
x        = [];
output   = {}; 
output.iterations = 0;
output.constrviolation = [];
output.firstorderopt = [];
output.algorithm = ''; % not known at this stage
output.cgiterations = [];
output.message = ''; % not known at this stage
   
if ( nargin == 1)
   model = f;
   if ( ~isstruct(model) ),
       output.message = 'The input to LMlinprog should be either a structure with valid fields or consist of at least three arguments.';
       warning(output.message);
       return; 
   end

   if ( ~all(isfield(model, {'f','Aineq','bineq'})) )
      output.message = 'The structure input to LMlinprog should contain at least three fields. "f", "Aineq" and "bineq".';
      warning(output.message);
      return; 
   end

   f = model.f;
   A = model.Aineq; 
   b = model.bineq; 
      
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
   output.message = 'LMlinprog requires at least three input arguments.';
   warning(output.message);
   return;    
end

% Set up LSprob structure
LSprob = {};
LSprob.vtype = [];
LSprob.osense = LS_MIN;
[mineq,nineq] = size(A);
[meq,neq] = size(Aeq);
LSprob.A = [A; Aeq];
[m,n] = size(LSprob.A);
LSprob.c = reshape(f,n,1);
if ( isempty(LSprob.A) )
   LSprob.A = sparse(0,length(f));
elseif ~issparse(LSprob.A)
   LSprob.A = sparse(LSprob.A);
end
csense_le=repmat('L',1,mineq);
csense_eq=repmat('E',1,meq);
LSprob.csense = [csense_le csense_eq];
if isempty(lb),
    lb = -ones(n)*LS_INFINITY;
end
if isempty(ub),
    ub = ones(n)*LS_INFINITY;
end
linfx = find(lb==-inf);
uindx = find(ub==inf);
lb(linfx)=-LS_INFINITY;
ub(uindx)=LS_INFINITY;
clear linfx uinfx;
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

if nargout>3,
    output.iterations = xsol.biter+xsol.siter+xsol.niter;
    output.constrviolation = xsol.pfeas;    
    output.cgiterations = [];
    output.message = xsol.errmsg; 
    if ~isfield(xsol,'mipObj'),
        output.firstorderopt = xsol.pobj-xsol.dobj;
        output.algorithm = 'dual-simplex';
        if xsol.biter>0,
            output.algorithm = 'interior-point';
        end                    
    else
        output.firstorderopt = xsol.BestBnd-xsol.mipObj;
        output.algorithm = 'LSsolveMIP';
    end
end

if nargout>4,
   if ( ~isfield(xsol,'mipObj') ),
       lambda.lower   = dj;
       lambda.upper   = dj;
       lambda.ineqlin = -y(1:mineq);
       lambda.eqlin   = -y((mineq+1):end);
   else
      lambda = [];
   end
end

