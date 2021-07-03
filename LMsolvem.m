function [x,y,s,dj,pobj,nStatus,nErr,B] = LMsolvem(LSprob, opts)
% LMSOLVEM: Solve an LP/QP/MIP/MIQP problem with LINDO API. 
% The input model is assumed to be in the following generic form. 
% Function arguments constitute the components of this formulation.
%  
%     optimize     f(x) = 0.5 x' Qc x + c' x 
%                         0.5 x' Qi x + A(i,:) x  ?  b(i)   for all i
%                      ub >=  x  >= lb
%                      x(v) is integer or binary
%
%     where,
%     Qc, and Qi are symmetric n by n matrices of constants for all i,
%     c, x and A(i,:) are n-vectors, and "?" is one of the relational 
%     operators "<=", "=", or ">=".
%                         
% 
% Usage:  [x,y,s,dj,pobj,nStatus,nErr] = LMsolvem(LSprob,opts)  
%
% Copyright (c) 2001-2007
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      

%
% Last update Jan 09, 2020 (MKA)
%
% 10-20-2020: Code is modified to keep model data in LSprob structure
% 10-20-2002: Code is modified to adopt 2.0 style interface


global MY_LICENSE_FILE
lindo;

x=[];
y=[];
s=[];
dj=[];
pobj=[];
nStatus=[];

if nargin < 2, 
    opts={};
    opts.nMethod=LS_METHOD_FREE;
    opts.iDefaultLog=1;
    opts.presolve=1;
    opts.B = [];
end;
if ~isfield(opts,'nMethod'), opts.nMethod=LS_METHOD_FREE; end
if ~isfield(opts,'iDefaultLog'), opts.iDefaultLog=1; end
if ~isfield(opts,'presolve'), opts.presolve=1; end
if ~isfield(opts,'B'), opts.B=[]; end
if ~isfield(opts,'IUSOL'), opts.IUSOL=0; end

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
iDefaultLog = opts.iDefaultLog;
nMethod = opts.nMethod;
presolve = opts.presolve;


% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)) 
   for i=1:m, csense=[csense 'E']; end;
end;

objconst = 0;  

% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));


%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_TIMLMT,5);
%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_SCALE,0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_INTTOL,0.0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_RELINTTOL,0.0); 
%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_LP_PRELEVEL,0)



% Declare and create a model 
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,0.1);
if presolve==0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
end    
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_ITRLMT,1000);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE,0);
if opts.IUSOL==1,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,1);  
end
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);   
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,iDefaultLog);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_TIMLMT,3);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_ITRLIM,-1);   
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_NLP_ITRLMT,1000);   
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_BARRIER_PROB_TO_SOLVE,LS_PROB_SOLVE_DUAL);      
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,1);        
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,2.5);      
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,0.01);      
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);




%%
% Open a log channel if required
%%
if (iDefaultLog>0)
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
end;
[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP2','dummy');

% Load LP the data 
if (~issparse(A)),  A = sparse(A); end; 
[nErr]=mxlindo('LSXloadLPData',iModel,osense,objconst,c,b,csense,A,lb,ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%check if integers exist
if (isempty(vtype)) 
   for i=1:m, vtype = [vtype 'C']; end; 
end;
nint = length(find(vtype=='I'))+length(find(vtype=='B'));


% Load the MIP data, if any.
if (nint > 0)
   [nErr]=mxlindo('LSloadMIPData',iModel,vtype);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

% Load quadratic terms, if any.
if (exist('QCrows') & exist('QCvar1') & exist('QCvar2') & exist('QCcoef'))
   QCnz = length(QCrows);
   if QCnz > 0,   
      [nErr] = mxlindo('LSloadQCData',iModel,QCnz,QCrows,QCvar1,QCvar2,QCcoef);
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   end;   
end;

if 0>1,
    szTmp = sprintf('c:/tmp/obj.ltx',pobj);
    nErr = mxlindo('LSwriteLINDOFile',iModel,szTmp);
end


if (nint == 0)
   [x,y,s,d,rx,rs,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel, opts); 
   B.cbas=[];B.rbas=[];
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   [B.cbas,B.rbas,nErr] = mxlindo('LSgetBasis',iModel);
else
   [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel, opts);     
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;


% Close the interface and terminate
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%%    
function myCleanupFun(iEnv)
    %%fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 