% LMtestNLP3:  Set up and solve the following nonlinear model using LINDO API's
%             multi-start nonlinear optimizer. 
%
%             maximize  f(x) =  x*y*sin(x)*cos(1.5*y) 
%             subject to
%                               L <=   x  <=  U;
%                               L <=   y  <=  U;

% 
% Usage:  LMtestNLP3

% Remarks:
%  1) The following m-files are called.
%     - LMcbFDE3.m (required callback function to compute function values)
%     - LMcbLP.m (optional callback function for multi-start solver)                                    
%  2) Model is loaded via LSloadLPData() and LSloadNLPData() routines. See LINDO-API
%     manual for details.
%  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
% Last update Jan 09, 2007 (MKA)
%
function [nErr] = LMtestNLP3()

lindo;
global MY_LICENSE_FILE
clc;
help lmtestnlp3;
pause (0.01);

%maximization
objsense = -1;

% Init model size
m  = 2; 
n  = 2;
nz = 2; 

% Init Bounds and RHS
csense = ['LL'];
b = [ 10  10 ]';
c = [ 0  0 ]';
l = [-12 -12 ]';
u = [+12 +12 ]';

% Init LP matrix
Abegcol = [ 0 1 2]';
Alencol = [ 1 1]';
Arowndx = [ 0 1 ]';
Acoef   = [ 1 1 ]';

% bounds

% Init NLP matrix mask
Nbegcol = [0 1 2]';
Nlencol = [1 1]';
Nrowndx = [0 1]';
Nobjndx = [0 1]';
Nobjcnt = 2;

% constant objective = 0
oshift = 0;

% Set verbose
verbose = 1;

if verbose > 0
   [x,y] = meshgrid(min(l):14/(60-1):max(u));
   z = x.*y.*sin(x).*cos(1.5*y);
    surf(x,y,z)
    axis([min(min(x)) max(max(x)) min(min(y)) max(max(y)) ...
          min(min(z)) max(max(z))])
    xlabel('X'), ylabel('Y'), title('f(x) =  x*y*sin(x)*cos(1.5*y)');   
   fprintf('\n Press Enter to start Multi-Start Nonlinear Optimizer... \n\n');
   pause;
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

% Set default log function (uncomment if necessary)
%[nErr] = mxlindo('LSsetLogfunc',iModel,'LScbLog','Dummy string');

% Set callback function to compute functional values (see LMcbFDE3.m)
[nErr] = mxlindo('LSsetFuncalc', iModel, 'LMcbFDE3', 'Dummy string');
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set callback function to display local solutions (see LMcbLP.m)
if verbose > 0
   fprintf('\n%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');   
   [nErr] = mxlindo('LSsetCallback', iModel, 'LMcbLP', 'Dummy string');
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

% Set NLP print level to 1
[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_PRINTLEVEL, verbose);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set NLP solver
[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_SOLVER, LS_NMETHOD_MSW_GRG);
[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_MAXLOCALSEARCH, 5);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


% Load the LP portion of the model
[nErr] = mxlindo('LSloadLPData', iModel, m, n, objsense, 0, c, b, csense,...
   nz, Abegcol, Alencol, Acoef, Arowndx, l, u);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

nErr = mxlindo('LSloadVarType',iModel,'CC');
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


% Load the NLP portion of the model
[nErr] = mxlindo('LSloadNLPData', iModel, Nbegcol, Nlencol,...
   [], Nrowndx, Nobjcnt,Nobjndx,[]);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Display model dimension
[n, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);
[m, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);      
[LPNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);            
[QCNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_QC_NONZ);            
[NLPNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NLP_NONZ);            
[NLPobjNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NLPOBJ_NONZ);            
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


% Optimize model
[solStatus,nErr] = mxlindo('LSoptimize', iModel, 0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
%[solStatus,nErr] = mxlindo('LSgetInfo',iModel , LS_IINFO_PRIMAL_STATUS);  

if (solStatus == LS_STATUS_OPTIMAL | ...
    solStatus == LS_STATUS_LOCAL_OPTIMAL)
   if verbose > 0
      fprintf('\n An (local) optimal solution is found ...  \n\n');
   end;
elseif (solStatus == LS_STATUS_FEASIBLE )
   if verbose > 0
      fprintf('\n An feasible (but not optimal) solution is found ...  \n\n');
   end;
end;
   
   % Get solution
   [x,status]=mxlindo('LSgetPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   [obj,status]=mxlindo('LSgetObjective',iModel);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   
   % Report
   fprintf(' f(X,Y) = %11.5f\n',obj);
   fprintf(' X      = %11.5f\n',x(1));
   fprintf(' Y      = %11.5f\n',x(2));   

 
% Test NLP data access routines
[aiBegcol,aiColcnt,adRowcoef,aiRowndx,nObjcnt,aiObjndx,...
      adObjcoef,adContype,nErr] = mxlindo('LSgetNLPData',iModel);

[nNcnt,aiColndx,adColcoef,nErr] = mxlindo('LSgetNLPConstraintDatai',iModel,0);
[nNcnt,aiColndx,adColcoef,nErr] = mxlindo('LSgetNLPConstraintDatai',iModel,1);

[nNcnt,aiRowndx,adRowcoef,nErr] = mxlindo('LSgetNLPVariableDataj',iModel,0);
[nNcnt,aiRowndx,adRowcoef,nErr] = mxlindo('LSgetNLPVariableDataj',iModel,1);

[nNcnt,aiColndx,adObjcoef,nErr] = mxlindo('LSgetNLPObjectiveData',iModel);

% Exit LINDO API
[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 