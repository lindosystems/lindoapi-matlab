function [x,y,s,dj,pobj,solstat] = LMlsqlin(Q,c,A,b,csense,lb,ub)
% LMlsqlin: Solve a linear least squares problem of the given form
% using LINDO API's barrier solver. To see how arguments with values 
% [] are handled, see the source code. 
%  
%                   min    f(x) = ||Q*x -c||^2 
%                          A x  ?   b
%                     ub >=  x  >= lb
% 
% Usage: [x,y,s,dj,pobj,solstat] = LMlsqlin(Q,c,A,b,csense,lb,ub)
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      
%
% Last update Jan 09, 2007 (MKA)




global MY_LICENSE_FILE
lindo;

x=[];
y=[];
s=[];
dj=[];
pobj=[];
solstat=[];
verbose = 2;
osense = LS_MIN;
solver = 3;

if nargin < 7,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    szInputFile = [LINDOAPI_HOME '/samples/data/testqp.mps'];      
    [LSprob] = LMreadf(szInputFile);    
    Q = sparse(LSprob.QCvar1+1,LSprob.QCvar2+1,LSprob.QCcoef)';
    c = LSprob.c;
    A = LSprob.A;
    b = LSprob.b;
    lb = LSprob.lb;
    ub = LSprob.ub;
    csense = LSprob.csense;    
end;

[m1, n1] = size(Q);
[m2, n2] = size(A);

if (n2 > 1 & (n1 ~= n2)),
    fprintf('Dimensions of Q and A do not match.\n');      
    return;
end;

if (isempty(A)),
    A = zeros(1,n1);
    [m2, n2] = size(A);
    for i=1:m2, csense=[csense 'G']; end;
    b = zeros(m2,1);
end;

if (isempty(lb)),
    lb =  -LS_INFINITY*ones(n1,1);
end;

if (isempty(ub)),
    ub =  +LS_INFINITY*ones(n1,1);
end;

if (isempty(b)),
    b = zeros(m2,1);
end;

if (isempty(c)),
    c = zeros(n1,1);
end;
    
if (isempty(csense)),
    for i=1:m2, csense=[csense 'E']; end;            
end;
      
% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));


% Declare and create a model 
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% sparsify matrices
if (~issparse(A)),  A = sparse(A); end; 
if (~issparse(Q)),  Q = sparse(Q); end; 

% linear component of f(x)
cost = -2*Q'*c;

% constant component of f(x)
objconst = c'*c;  

% quadratic component of f(x)
tmp = triu(sparse(Q'*Q),0);
[QCvar1,QCvar2,QCcoef] = find(tmp);
QCrows = zeros(size(QCvar1))-1;
QCnz = length(QCrows);
clear tmp;

% load LP components
[nErr]=mxlindo('LSXloadLPData',iModel,osense,objconst,cost,b,csense,A,lb,ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% load QP components
[nErr] = mxlindo('LSloadQCData',iModel,QCnz,QCrows,QCvar1-1,QCvar2-1,2*QCcoef);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,0.1);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


   % Solve as QP/LP
   % 
   if (verbose>1)
       [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   elseif (verbose>0)
       fprintf('\nSolving...\n');
       fprintf('%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');
       [nErr] = mxlindo('LSsetCallback',iModel,'lmcblp','Dummy string');   
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   end;
   
%  [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,1.0e-7);   
%  [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-7);   
%  [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_PREP,0);   
%  [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);    
%  [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,0.0);
  [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,verbose);
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

  nStatus = LS_STATUS_UNKNOWN;
  [nStatus,nErrOpt]=mxlindo('LSoptimize',iModel,solver);
  if nErrOpt ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErrOpt) ; return; end;
  if (nStatus == LS_STATUS_UNKNOWN )
      tmpfile = ['Q' num2str(m1) 'x' num2str(n1) '.mps'];
      nErr = mxlindo('LSwriteMPSFile',iModel,tmpfile,0);
  end;
  
  % get solution stats
  [etime, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_ELAPSED_TIME);      
  [siter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_SIM_ITER);        
  [biter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BAR_ITER);         
  [niter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NLP_ITER);        
  [imethod, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_METHOD);         
  [pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_PINFEAS);
  [dfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DINFEAS);
  [pobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
  [dobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DOBJ);
  [basstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BASIC_STATUS);  
  [solstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STATUS);  
  [dsolstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_DUAL_STATUS);    
  
                                
  
  % Get the primal and dual solution
  [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
  
  [y,nErr]=mxlindo('LSgetDualSolution',iModel);
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
  
  [s,nErr]=mxlindo('LSgetSlacks',iModel);
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
  
  [dj,nErr]=mxlindo('LSgetReducedCosts',iModel);
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
  
  if (verbose>0),
      fprintf('Status = %d\n',nStatus);
      fprintf('Errorcode = %d\n',nErrOpt);
      fprintf('Obj = %f\n',pobj);
  end;
   
% Close the interface and terminate
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 