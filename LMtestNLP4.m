% LMtestNLP4: Set up and solve a double exponential smoothing model for a 
%   given time series. The objective criterion is the minimization of SSE. 
%   The boundary values for E(1),...,E(p) and L(1),...,L(p) are left as 
%   decision variables to increase the degrees of freedom in optimization. 
%   The parameter p is reserved for extending the model to Winter's seasonal 
%   model. The current value for p is set to 1 since seasonality is ignored
%   in double exponential model. Similarly,  the seasonality factor u is 
%   also excluded from the computations.
%
%          minimize  SSE = @sum (i>p) ( (E(i-1)+L(i-1)) - Y(i) )^2
%          subject to
%                              w + v + u    <= 3
%                        1 >=  w , v , u    >= 0
%                      inf >= E(1),...,E(p) >= -inf
%                      inf >= L(1),...,L(p) >= -inf
% 
%    where, E(t) and L(t) are level and trend values at time t and 
%    satisfy the following recursive equations given the initial 
%    values E(1:p) and L(1:p) 
%
%    F(t+i) = E(t) + i * L(t)                        ;   i>=1
%    E(i)   = w*Y(i)          + (1-w)*(E(i-1)+L(i-1));   i>p
%    L(i)   = v*(E(i)-E(i-1)) + (1-v)*L(i-1)         ;   i>p
%
% Usage:  LMtestNLP4

% Remarks:
%  1) The following m-files are called.
%     - LMcbFDE4.m (required callback function to compute function values)
%     - LMcbLP.m (optional callback function for multi-start solver)                                    
%  2) Model is loaded via LSloadLPData() and LSloadNLPData() routines. See LINDO-API
%     manual for details.
%  
% Copyright (c) 2006
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
% Last update Jan 09, 2007 (MKA)
%
function [nErr] = LMtestNLP4()

lindo;
global MY_LICENSE_FILE
clc;
help lmtestnlp4;
pause(1.5);

global E L Y

% Time series 
Y = [ 266.00 	 145.90 	 183.10 	 119.30 	 180.30 	 168.50 ...
      231.80 	 224.50 	 192.80 	 122.90 	 336.50 	 185.90 ...
      194.30 	 149.50 	 210.10 	 273.30 	 191.40 	 287.00 ...
      226.00 	 303.60 	 289.90 	 421.60 	 264.50 	 342.30 ...
      339.70 	 440.40 	 315.90 	 439.30 	 401.30 	 437.40 ...
      575.50 	 407.60 	 682.00 	 475.30 	 581.30 	 646.90    ]';

% Level values
E = zeros(size(Y));
E(1) = 170;

% Trend values
L = zeros(size(Y));
L(1) = 5;


% F(t+i) = E(t) + i * L(t)
% E(i)   = w*Y(i)          + (1-w)*(E(i-1)+L(i-1));
% L(i)   = v*(E(i)-E(i-1)) + (1-v)*L(i-1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Below this line is the NLP model that computes the optimal level and trend factors

% Init model size
m  = 1; 
n  = 5;
nz = 3; 

% Init Bounds and RHS
csense = ['L'];
b = [3]';
c = [0 0 0 ]';
l = [0 0 0 -1000 -1000]';
u = [1 1 1 +1000 +1000]';

% Init LP matrix
Abegcol = [ 0 1 2 3 3 3]';
Alencol = [ 1 1 1 0 0]';
Arowndx = [ 0 0 0]';
Acoef   = [ 1 1 1]';

% Init NLP matrix mask
Nbegcol = [0 0 0 0 0 0]';
Nlencol = [0 0 0 0 0]';
Nrowndx = [0 0 0 0 0]';
Nobjndx = [0 1 2 3 4]';
Nobjcnt = 5;

% Set verbose
verbose = 1;
 
% constant objective = 0
oshift = 0;

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
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set callback function to compute functional values (see LMcbFDE1.m)
[nErr] = mxlindo('LSsetFuncalc', iModel, 'LMcbFDE4', 'Dummy string');
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set callback function to display progress (see LMcbLP.m)
if verbose > 0
   fprintf('\n%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');   
   [nErr] = mxlindo('LSsetCallback', iModel, 'LMcbLP', 'Dummy string');
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

% Load the LP portion of the model
[nErr] = mxlindo('LSloadLPData', iModel, m, n, 1, 0, c, b, csense,...
   nz, Abegcol, Alencol, Acoef, Arowndx, l, u);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Load the NLP portion of the model
[nErr] = mxlindo('LSloadNLPData', iModel, Nbegcol, Nlencol,...
   [], Nrowndx, Nobjcnt,Nobjndx,[]);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Get model dimension
[n, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);
[m, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);      
[LPNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);            
[QCNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_QC_NONZ);            
[NLPNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NLP_NONZ);            
[NLPobjNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NLPOBJ_NONZ);            
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set NLP print level to 1
[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_PRINTLEVEL, verbose);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_PRELEVEL, 126);

% Set NLP solver
%[nErr] = mxlindo('LSsetModelIntParameter', iModel, LS_IPARAM_NLP_SOLVER, LS_NMETHOD_MSW_GRG);

% Set initial solution 
x = [ 0.3 0.5 0.5 E(1) L(1)]';
[nErr] = mxlindo('LSloadVarStartPoint', iModel, x);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Optimize model
[solStatus,nErr] = mxlindo('LSoptimize', iModel, 0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
%[solStatus,nErr] = mxlindo('LSgetInfo',iModel , LS_IINFO_PRIMAL_STATUS);  

if (solStatus == LS_STATUS_OPTIMAL | ...
    solStatus == LS_STATUS_LOCAL_OPTIMAL | ...
    solStatus == LS_STATUS_FEASIBLE)

   if verbose > 0
      fprintf('\n An (local) optimal solution is found ...  \n\n');
   end;
   
   
   % Get solution
   [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   [obj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   
   % Report
   fprintf(' f(w,v,u) = %11.5f\n',obj);
   fprintf(' w        = %11.5f\n',x(1));
   fprintf(' v        = %11.5f\n',x(2));  
   fprintf(' u        = %11.5f\n',x(2));     
   
else
   if verbose > 0
      fprintf('\n Optimizer failed....  \n\n');
   end;
end;
 
% Test NLP data access routines
[aiBegcol,aiColcnt,adRowcoef,aiRowndx,nObjcnt,aiObjndx,...
      adObjcoef,adContype,nErr] = mxLINDO('LSgetNLPData',iModel);

[nNcnt,aiColndx,adColcoef,nErr] = mxLINDO('LSgetNLPConstraintDatai',iModel,0);
%[nNcnt,aiColndx,adColcoef,nErr] = mxLINDO('LSgetNLPConstraintDatai',iModel,1);

[nNcnt,aiRowndx,adRowcoef,nErr] = mxLINDO('LSgetNLPVariableDataj',iModel,0);
%[nNcnt,aiRowndx,adRowcoef,nErr] = mxLINDO('LSgetNLPVariableDataj',iModel,1);

[nNcnt,aiColndx,adObjcoef,nErr] = mxLINDO('LSgetNLPObjectiveData',iModel);

% Exit LINDO API
[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 