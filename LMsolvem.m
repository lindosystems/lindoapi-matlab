function [x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob, LSopts)
% LMSOLVEM: Solve an LP/QP/MIP/MIQP problem with LINDO API. 
% The input model is assumed to be in the following generic form stored
% in a structure LSprob. 
%
% LSprob should constitute the components of this formulation.
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
% Usage:  [x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts)  
%
% See also LMreadf.

%% Copyright (c) 2001-2007
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      

%%
% Last update Jan 09, 2020 (MKA)
%
% 10-20-2020: Code is modified to keep model data in LSprob structure
% 10-20-2002: Code is modified to adopt 2.0 style interface


global MY_LICENSE_FILE
lindo;
if nargin<1,
    help LMsolvem;
    return;
end    
x=[];
y=[];
s=[];
dj=[];
pobj=[];
nStatus=[];
nErr=[];
xsol=[];

if nargin < 2, 
    LSopts={};
    LSopts.nMethod=LS_METHOD_FREE;
    LSopts.iDefaultLog=1;
    LSopts.presolve=1; %Preprocess
    LSopts.B = [];
    LSopts.numAltOpt = 0;
    LSopts.MaxIter = -1;
    LSopts.MaxTime = -1;
    LSopts.TolCon = 1e-7;
    LSopts.TolFun = 1e-7;
    LSopts.Diagnostics = 'off';
    LSopts.Display = 'iter';
    LSopts.IPMSOL = 0;
    LSopts.IUSOL = 0;
end;
if ~isfield(LSopts,'nMethod'), LSopts.nMethod=LS_METHOD_FREE; end
if ~isfield(LSopts,'iDefaultLog'), LSopts.iDefaultLog=1; end
if ~isfield(LSopts,'presolve'), LSopts.presolve=1; end
if ~isfield(LSopts,'B'), LSopts.B=[]; end
if ~isfield(LSopts,'IUSOL'), LSopts.IUSOL=0; end
if ~isfield(LSopts,'numAltOpt'), LSopts.numAltOpt=0; end
if ~isfield(LSopts,'MaxIter'), LSopts.MaxIter=-1; end
if ~isfield(LSopts,'MaxTime'), LSopts.MaxTime=-1; end
if ~isfield(LSopts,'TolCon'), LSopts.TolCon=1e-7; end
if ~isfield(LSopts,'TolFun'), LSopts.TolFun=1e-7; end
if ~isfield(LSopts,'Diagnostics'), LSopts.Diagnostics='off'; end
if ~isfield(LSopts,'Display'), LSopts.Display='iter'; end
if ~isfield(LSopts,'IPMSOL'), LSopts.IPMSOL=0; end
if ~isfield(LSopts,'IUSOL'), LSopts.IUSOL=0; end

% overrides
if strcmp(LSopts.Display,'final'),
    LSopts.iDefaultLog = 0;
end

if nargin==1,
    if nargout <= 1 && isequal(LSprob,'defaults'),
        x = LSopts;
        return;
    else
       if ( ~isstruct(LSprob) ),
           message = 'The input to LMsolvem should be either a structure with valid fields or consist of at least three arguments.';
           warning(message);
           return; 
       end

       if ( ~all(isfield(LSprob, {'c','A','b'})) )
          message = 'The structure input to LMlinprog should contain at least three fields. "c", "A" and "b".';
          warning(message);
          return; 
       end        
    end
end


x = []; c = []; A = []; b = []; lb = []; ub = []; csense = []; vtype = []; 
QCrows = []; QCvar1 = []; QCvar2 = []; QCcoef = []; R = []; osense = LS_MIN;
B = [];

if isfield(LSprob,'x'), x = LSprob.x; end
if isfield(LSprob,'c'), c = LSprob.c; end
if isfield(LSprob,'A'), A = LSprob.A; end
if isfield(LSprob,'b'), b = LSprob.b; end
if isfield(LSprob,'lb'), lb = LSprob.lb; end
if isfield(LSprob,'ub'), ub = LSprob.ub; end
if isfield(LSprob,'csense'), csense = LSprob.csense; end
if isfield(LSprob,'vtype'), vtype = LSprob.vtype; end
if isfield(LSprob,'QCrows'), QCrows = LSprob.QCrows; end
if isfield(LSprob,'QCvar1'), QCvar1 = LSprob.QCvar1; end
if isfield(LSprob,'QCvar2'), QCvar2 = LSprob.QCvar2; end
if isfield(LSprob,'QCcoef'), QCcoef = LSprob.QCcoef; end
if isfield(LSprob,'R'), R = LSprob.R; end
if isfield(LSprob,'B'), B = LSprob.B; end
if isfield(LSprob,'osense'), osense = LSprob.osense; end


[m,n] = size(A);
iDefaultLog = LSopts.iDefaultLog;
nMethod = LSopts.nMethod;
presolve = LSopts.presolve;


% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)), csense=repmat('E',1,m); end;

retval = LMvalidateDim(c,A,b,csense,lb,ub);
if retval<0,
   fprintf('Dimension mismatch in two or more fields in input.\n');
   return
end
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

%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE,0);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,LSopts.IUSOL);  
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,LSopts.IPMSOL);   
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_DPARAM_SOLVER_TIMLMT,LSopts.MaxTime);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_DPARAM_MIP_TIMLIM,LSopts.MaxTime);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_DPARAM_LP_ITRLMT,LSopts.MaxIter);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_DPARAM_MIP_ITRLIM,LSopts.MaxIter);   
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_DPARAM_NLP_ITRLMT,LSopts.MaxIter);   
[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,LSopts.TolCon);
[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,LSopts.TolFun);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_BARRIER_PROB_TO_SOLVE,LS_PROB_SOLVE_DUAL);   
if iDefaultLog>0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,2);
end    
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,iDefaultLog);
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,0.01);      





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
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; end;
end;

% Load quadratic terms, if any.
if (exist('QCrows') & exist('QCvar1') & exist('QCvar2') & exist('QCcoef'))
   QCnz = length(QCrows);
   if QCnz > 0,   
      [nErr] = mxlindo('LSloadQCData',iModel,QCnz,QCrows,QCvar1,QCvar2,QCcoef);
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; end;
   end;   
end;

if 0>1,
    szTmp = sprintf('/tmp/obj.ltx',pobj);
    nErr = mxlindo('LSwriteLINDOFile',iModel,szTmp);
end

xsol=[];
if (nint == 0)
   if ~isempty(B) && isfield(B,'cbas'),
       [nErr] = mxlindo('LSloadBasis',iModel,B.cbas,B.rbas);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
   end
   [x,y,s,dj,rx,rs,pobj,nStatus,optErr] = lm_solve_lp(iEnv, iModel, LSopts);       
   B.cbas=[];B.rbas=[];   
   [xsol,nErr] = lm_stat_lpsol(iModel);
   if LSopts.numAltOpt>0,
       if nStatus==LS_STATUS_BASIC_OPTIMAL,
            nErr = mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLPOOL_LIM,LSopts.numAltOpt+1);
            nErr = LMfindAltOpt(iEnv,iModel,LSopts);
       else
           fprintf('\nError: cannot compute alternative solutions when status=%d..\n',nStatus);
       end
   end
else
   [x,y,s,dj,pobj,nStatus,optErr] = lm_solve_mip(iEnv, iModel, LSopts);        
   [xsol,nErr] = lm_stat_mipsol(iModel);
end;
xsol.nStatus = nStatus;
xsol.optErr = optErr;
[xsol.errmsg, nErr] = mxlindo('LSgetErrorMessage',iEnv,optErr);
if optErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,optErr); end;

% Close the interface and terminate
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%%    
function myCleanupFun(iEnv)
    %%fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 
    
%%    
function nErr = LMfindAltOpt(iEnv,iModel,opts)   
   for j1=1:opts.numAltOpt, 
       [pnModStatus,nErr] = mxlindo('LSgetNextBestSol',iModel);
       if nErr==0, 
           [cbas,rbas,nErr] = mxlindo('LSgetBasis',iModel);
            [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
            fprintf('\nNextBestSol #%d, status:%d, |x|: %g',j1,pnModStatus,norm(x));
       else
            LMcheckError(iEnv,nErr,0);
            break;
       end
   end
   fprintf('\nComputed alternative solutions..\n');
