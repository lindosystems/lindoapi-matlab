function  [nsuf_c,nius_c,cols,stat] = LMfindIUS(LSprob)
% LMfindIUS	: Gateway to LINDO API for debugging an unbounded linear program.
% 
% Usage: [nsuf_c,niis_c,cols,stat] = LMfindIUS(LSprob)
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      
%
% Last update Jan 09, 2007 (MKA)
%


% INPUT : Data vectors representing an unbounded LP 
%  LSprob.A    : coefficient matrix of the LP
%  LSprob.b    : rhs vector
%  LSprob.c    : objective vector
%  LSprob.csense: sense of the constraints
%  LSprob.lb    : lower bounds
%  LSprob.ub    : upper bounds
%  LSprob.osense: sense of the objective (min or max)
% 
% OUTPUT: An IUS charaterized by (nsuf_c,niis_c,cols)
%  nsuf_c: number of sufficient columns in the IUS 
%  niis_c: number of columns in the IUS.
%  rows_c: indices of cols in the IUS. (C type indexing)
%  stat  : status returned by the routine
% 
% REMARK: 
%  1) cols[1:nsuf_c] are the sufficient cols



global MY_LICENSE_FILE 
lindo;
    
if nargin <1,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    szInputFile = [LINDOAPI_HOME '/samples/data/testulp.mps'];
    [LSprob] = LMreadf(szInputFile);
end  

osense = LSprob.osense;
c = LSprob.c;
A = LSprob.A;
b = LSprob.b;
lb = LSprob.lb;
ub = LSprob.ub;
csense = LSprob.csense;
vtype = LSprob.vtype;
QCrows = LSprob.QCrows;
QCvar1 = LSprob.QCvar1;
QCvar2 = LSprob.QCvar2;
QCcoef = LSprob.QCcoef;

[m,n] = size(A);

oshift = 0;  % assumed fixed obj = 0

% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)) 
   for i=1:m, csense=[csense 'E']; end;
end;


% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

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

%turn the preprocessor off/on
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Solve as LP
[nStatus,nErr]=mxlindo('LSoptimize',iModel,LS_METHOD_PSIMPLEX);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (nStatus ~= LS_STATUS_UNBOUNDED)
   fprintf('\nModel is not unbounded (status:%d). Quitting...\n\n',nStatus);
   [nErr]=mxlindo('LSdeleteEnv',iEnv);
   return;
end;
       
level = LS_NECESSARY_COLS;
[nErr] = mxlindo('LSfindIUS',iModel,level);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% locate an IIS if any exists
[nsuf_c,nius_c,cols,nErr] = mxlindo('LSgetIUS',iModel)
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
stat = nErr;

% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 