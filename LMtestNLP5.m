% LMtestNLP5:  Set up and solve the following nonlinear model using LINDO API's
%              nonlinear optimizer. 
%              minimize     x3 + x4 + x5 + x6
%                 s.t.
%                         x1 + x2   + x3   = 1;
%                         x1 + x2   + x4   = 1;
%                         x1 + x2   + x5   = 1;
%                         x1 + x2   + x6   = 1;
%                         x1 - x2^2        = 0;
%
% 
% Usage:  LMtestNLP5

% Remarks:
%  1) The following m-files are called.
%     - LMcbFDE5.m (required callback function to compute function values)
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
function [nErr] = LMtestNLP5()

lindo;
global MY_LICENSE_FILE
clc;
help lmtestnlp5;
pause(0.01);

% Init model size
m  = 5; 
n  = 6;
nz = 14; 

% Init Bounds and RHS
csense = ['EEEEE'];
b = [ 1 1 1 1 0 ]';
c = [ 0 0 1 1 1 1]';
l = [ 0 0 0 0 0 0]';
u = [ 1 1 1 1 1 1]';

% Init LP matrix
Abegcol = [ 0 5 10 11 12 13 14]';
Alencol = [ 5 5 1 1 1 1]';

Arowndx = [ 0 1 2 3 4 ...
            0 1 2 3 4 ...
            0 ...
            1 ...
            2 ...
            3 ]';
            
Acoef   = [ 1 1 1 1 1 ...
            1 1 1 1 0 ...
            1 ...
            1 ...
            1 ... 
            1 ]';

% bounds

% Init NLP matrix mask
Nbegcol = [0 0 1 1 1 1 1]';
Nlencol = [0 1 0 0 0 0]';
Nrowndx = [4]';
Nobjndx = [1]';
Nobjcnt = [0];

% Set verbose
verbose = 1;

if verbose > 0 & 0,
   [x,y] = meshgrid(min(l):6/(40-1):max(u));
   z =  exp(abs(x - y.^2));
   surf(x,y,z)
   axis([min(min(x)) max(max(x)) min(min(y)) max(max(y)) ...
          min(min(z)) max(max(z))])
    xlabel('X'), ylabel('Y'), title('Penalty function function');
    fprintf('\n Press Enter to start Multi-Start Nonlinear Optimizer... \n\n'); 
    pause;
end;
 
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
[nErr] = mxlindo('LSsetFuncalc', iModel, 'LMcbFDE5', 'Dummy string');
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

% Load the LP portion of the model
[nErr] = mxlindo('LSloadLPData', iModel, m, n, 1, 0, c, b, csense,...
   nz, Abegcol, Alencol, Acoef, Arowndx, l, u);
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

if (solStatus == LS_STATUS_OPTIMAL | solStatus == LS_STATUS_LOCAL_OPTIMAL | solStatus == LS_STATUS_FEASIBLE)
   if verbose > 0
      fprintf('\n An (local) optimal solution is found ...  \n\n');
   end;
   
   
   % Get solution
   [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   [obj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   
   % Report
   fprintf(' f(x1,...,x6) = %11.5f\n',obj);
else
   if verbose > 0
      fprintf('\n Optimizer failed....  \n\n');
   end;
end;
 

% Exit LINDO API
[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 