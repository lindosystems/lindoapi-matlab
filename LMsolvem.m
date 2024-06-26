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
if 0,
    persistent iModel
    persistent iEnv
end    

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
    LSopts = LMoptions('lindo',LSopts);
end;
LSopts = LMoptions('linprog',LSopts);
LSopts = LMoptions('intlinprog',LSopts);

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

% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)), csense=repmat('E',1,m); end;

%check if integers exist
if (isempty(vtype)), vtype=repmat('C',1,n); end;
isMip = length(find(vtype=='I'))+length(find(vtype=='B'))>0;

retval = LMvalidateDim(c,A,b,csense,lb,ub);
if retval<0,
   fprintf('Dimension mismatch in two or more fields in input.\n');
   return
end
objconst = 0;  


%% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

%% Create a LINDO environment
if LSopts.iDefaultLog>0,
    LMversion();
end;    
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

% Environment logger
[nErr] = mxlindo('LSsetEnvLogfunc',iEnv,'LMcbLog','Dummy string');

% Set an external solver
if isfield(LSopts,'XSOLVER') && LSopts.XSOLVER>=1,
    nErr = mxlindo('LSsetXSolverLibrary',iEnv,LSopts.XSOLVER,LSopts.XDLL);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; end;
end
% Set LSopts as env parameters
if isfield(LSopts,'setEnvParams') & LSopts.setEnvParams,
    [nOk,nFail] = lm_set_options(iEnv, iEnv, LSopts, isMip);
end    

%% Declare and create a model 
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Set LSopts as model parameters
[nOk,nFail] = lm_set_options(iEnv, iModel, LSopts, isMip);

%% Open a log channel if required
if (LSopts.iDefaultLog>0)
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
end;
% Set a dummy callback to track progress and serve CTRL-C requests
[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP2','dummy');

% Load LP the data 
if (~issparse(A)),  A = sparse(A); end; 
[nErr]=mxlindo('LSXloadLPData',iModel,osense,objconst,c,b,csense,A,lb,ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Load the MIP data, if any.
if (isMip > 0)
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

if isfield(LSopts,'exportModel'),
    if strcmp(LSopts.exportModel,'ltx'),
        szTmp = sprintf('/tmp/iModel.ltx');
        nErr = mxlindo('LSwriteLINDOFile',iModel,szTmp);
    elseif strcmp(LSopts.exportModel,'mps'),
        szTmp = sprintf('/tmp/iModel.mps');
        nErr = mxlindo('LSwriteMPSFile',iModel,szTmp,0);    
    end
end
   
xsol=[];
Xalt=[];
if (isMip == 0)
   [x,y,s,dj,~,~,pobj,nStatus,optErr] = lm_solve_lp(iEnv, iModel, LSopts);       
   B.cbas=[];B.rbas=[];
   if isfield(LSopts,'numAltOpt') && LSopts.numAltOpt>0,
       if nStatus==LS_STATUS_BASIC_OPTIMAL,
            nErr = mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLPOOL_LIM,LSopts.numAltOpt+1);
            nErr = LMfindAltOpt(iEnv,iModel,LSopts);
       else
           fprintf('\nError: cannot compute alternative solutions when status=%d..\n',nStatus);
       end
   end
   [xsol,~] = lm_stat_lpsol(iModel);
   if nStatus==LS_STATUS_BASIC_OPTIMAL || nStatus==LS_STATUS_OPTIMAL,
       [B.cbas,B.rbas,nErr] = mxlindo('LSgetBasis',iModel);    
       xsol.B = B;
   end
else
   [x,y,s,dj,pobj,nStatus,optErr] = lm_solve_mip(iEnv, iModel, LSopts);        
   [xsol,~] = lm_stat_mipsol(iModel);
   if nStatus == LS_STATUS_OPTIMAL | nStatus == LS_STATUS_FEASIBLE,    
       fprintf('\nChecking if rounded solution is feasible..\n');
       [padPrimalRound,padObjRound,padPfeasRound,pnstatus,nErr] = mxlindo('LSgetRoundMIPsolution',iModel,x,1,0);
       fprintf('\nObjRound=%12.6f, PfeasRound=%12.6f, pnstatus=%d, nErr=%d\n',padObjRound,padPfeasRound,pnstatus,nErr);
       k = 0;
       while k<LSopts.numAltOpt,
           [pnstatus,nErr] = mxlindo('LSgetNextBestMIPSol',iModel);
           k = k + 1;
           if nErr==0,
               [x,nErr]=mxlindo('LSgetMIPPrimalSolution',iModel);
               [padPrimalRound,padObjRound,padPfeasRound,pnstatus,nErr] = mxlindo('LSgetRoundMIPsolution',iModel,x,1,0);
               fprintf('\nObjRound=%12.6f, PfeasRound=%12.6f, pnstatus=%d, nErr=%d\n',padObjRound,padPfeasRound,pnstatus,nErr);
               Xalt = [Xalt x];
           else
               fprintf('\nLSgetNextBestMIPSol returned error %d, stopping..\n',nErr);
               break;
           end           
       end
       if k>0,
           if isfield(LSprob,'InputFile'),
                szOutFile =  [LSprob.InputFile(1:length(LSprob.InputFile)-4) '_contra.mps'];
               [nErr]=mxlindo('LSwriteMPSFile',iModel,szOutFile,0);
               fprintf('\nSaved final state of kbest model as %s\n',szOutFile);                
           else
               fprintf('\nWarning: LSprob.InputFile does not exist, cannot save final state of kbest model\n');
           end
       end
   end
end;

xsol.Xalt = Xalt;
% Record termination status and optimization error
xsol.nStatus = nStatus;
xsol.optErr = optErr;
[xsol.errmsg, ~] = mxlindo('LSgetErrorMessage',iEnv,optErr);
if optErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,optErr); end;


szInputFile=[];
if isfield(LSprob,'InputFile'), 
    szInputFile = LSprob.InputFile; 
    [fPath, fName, fExt] = fileparts(szInputFile);
end

if isfield(LSopts,'saveBas') && LSopts.saveBas,
    if ~isempty(szInputFile),
        basfile=strrep(szInputFile,fExt,'_bas.mps');
    else
        basfile='/tmp/mymodel.bas';
    end
	[nErr] = mxlindo ('LSwriteBasis',iModel,basfile,2);
    fprintf('\n');
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;   
end;

if isfield(LSopts,'saveSol') && LSopts.saveSol,
    if ~isempty(szInputFile),
        solfile=strrep(szInputFile,fExt,'.sol');
    else
        solfile='/tmp/mymodel.sol';
    end
	[nErr] = mxlindo ('LSwriteSolution',iModel,solfile);
    fprintf('\n');
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
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
