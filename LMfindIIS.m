function  [nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = LMfindIIS(LSprob)
% LMfindIIS	: Gateway to LINDO API for debugging an infeasible linear program.
% 
% Usage:  [nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = LMfindIIS(LSprob)
  
% Copyright (c) 2006
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      
%
%
% Last update Jan 09, 2007 (MKA)
%
%

% INPUT : Data vectors representing an infeasible LP  
%  LSprob.A    : coefficient matrix of the LP
%  LSprob.b    : rhs vector
%  LSprob.c    : objective vector
%  LSprob.csense: sense of the constraints
%  LSprob.lb    : lower bounds
%  LSprob.ub    : upper bounds
%  LSprob.osense: sense of the objective (min or max)
% 
% OUTPUT: An IIS charaterized by (nsuf,niis,rows)
%  nsuf_r: number of sufficient rows in the IIS 
%  niis_r: number of rows in the IIS.
%  rows_r: indices of rows in the IIS. 
%  nsuf_c: number of sufficient column bounds in the IIS 
%  niis_c: number of column bounds in the IIS.
%  rows_c: indices of cols in the IIS. (C type indexes)
%  bnds_c: indicates the type of the bound in the IIS. lower=-1, upper=+1
%  stat  : status returned by the routine
% 
% REMARK: 
%  1) rows[1:nsuf_r] are the sufficient rows
%  2) cols[1:nsuf_c] are the sufficient column bounds


global MY_LICENSE_FILE 
lindo;
     

if nargin <1,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    szInputFile = [getenv('LINDOAPI_HOME') '/samples/data/testilp.mps'];
    [LSprob] = LMreadf(szInputFile);
end                

x = []; c = []; A = []; b = []; lb = []; ub = []; csense = []; vtype = []; 
QCrows = []; QCvar1 = []; QCvar2 = []; QCcoef = []; R = []; osense = LS_MIN;

if isfield(LSprob,'x') x = LSprob.x; end
if isfield(LSprob,'c') c = LSprob.c; end
if isfield(LSprob,'A') A = LSprob.A; end
if isfield(LSprob,'b') b = LSprob.b; end
if isfield(LSprob,'lb') lb = LSprob.lb; end
if isfield(LSprob,'ub') ub = LSprob.ub; end
if isfield(LSprob,'csense') csense = LSprob.csense; end
if isfield(LSprob,'vtype') vtype = LSprob.vtype; end
if isfield(LSprob,'QCrows') QCrows = LSprob.QCrows; end
if isfield(LSprob,'QCvar1') QCvar1 = LSprob.QCvar1; end
if isfield(LSprob,'QCvar2') QCvar2 = LSprob.QCvar2; end
if isfield(LSprob,'QCcoef') QCcoef = LSprob.QCcoef; end
if isfield(LSprob,'R') R = LSprob.R; end
if isfield(LSprob,'osense') osense = LSprob.osense; end


[m,n] = size(A);

oshift = 0;  % assumed fixed obj = 0


% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)) 
   for i=1:m, csense=[csense 'E']; end;
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

% Load the data 
if (~issparse(A)),  A = sparse(A); end;
[nErr]=mxlindo('LSXloadLPData',iModel,osense,oshift,c,b,csense,A,lb,ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-7);
%turn the preprocessor off/on
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
%compute solution even if unbounded or infeasible
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,1);
% turn on the sensitivity filter 
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_USE_SFILTER,1);
% set print level to 2
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_PRINT_LEVEL,2);
% set infeasibility norm 
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_INFEAS_NORM,LS_IIS_NORM_ONE);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_TOPOPT,LS_METHOD_FREE);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_REOPT,LS_METHOD_FREE);          
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% set a log function
[nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');

%[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','Dummy string');   

% Solve as LP
[nStatus,nErr]=mxlindo('LSoptimize',iModel,LS_METHOD_FREE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (nStatus ~= LS_STATUS_INFEASIBLE)
   fprintf('Model is not infeasible (status = %d). Quitting...',nStatus);
   [nErr]=mxlindo('LSdeleteEnv',iEnv);
end;

% locate an IIS if any exists
level = LS_NECESSARY_ROWS ;
%level = LS_NECESSARY_ROWS  + LS_SUFFICIENT_ROWS;
%level = LS_NECESSARY_ROWS + LS_NECESSARY_COLS;
%level = LS_NECESSARY_ROWS + LS_NECESSARY_COLS + LS_SUFFICIENT_ROWS;
%level = LS_NECESSARY_ROWS + LS_NECESSARY_COLS + LS_SUFFICIENT_ROWS + LS_SUFFICIENT_COLS;
[nErr] = mxlindo('LSfindIIS',iModel,level);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = mxlindo('LSgetIIS',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%[nErr]=mxlindo('LSwriteIIS',iModel,'iis.ltx');

% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%%    
function myCleanupFun(iEnv)
    fprintf('\nDestroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 