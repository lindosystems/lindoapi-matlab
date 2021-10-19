function [nStatus] = LMtestLP(inputFile, nMethod, iDefaultLog)
% LMtestLP
%
% Calculates the approx. analytical center on/near the optimal face of an LP
% and then computes the distance to a nearby optimal basic (vertex) solution. 
% If the analytical center is very close to the vertex solution in primal (dual)
% then it is likely that the primal (dual) basic solution is unique. The
% method also returns the condition of the optimal basis.
% 
% Usage: [nStatus] = LMtestLP(inputFile, nMethod)
%
% Copyright (c) 2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

%
% Last update Jan 09, 2007 (MKA)
%

lindo;
global MY_LICENSE_FILE

LINDO_DATA=[getenv('LINDOAPI_HOME') '\samples\data\'];

if nargin < 1,
    inputFile = [LINDO_DATA 'testlp.mps'];
    if nargin < 2,
        nMethod = LS_METHOD_BARRIER;
        if nargin < 3,
            iDefaultLog = 0; %set this 
        end;   
    end;
end;


for k=length(inputFile):-1:1,
     if inputFile(k) == '\',
        break;
     end;
end;

foldername = inputFile(1:k);
filename=inputFile(k+1:length(inputFile));

for k=1:length(filename),
     if filename(k) == '.',
        break;
     end;
end;
extname=filename(k:length(filename));
filename=filename(1:k-1);
 
LMversion;

% Read license key from a license file
[MY_LICENSE_KEY,status] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));


% Create a LINDO model
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;

% Open a log channel
if (iDefaultLog > 0),
   [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,iDefaultLog);        
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;
end;

[nErr]=mxlindo('LSreadMPSFile',iModel,inputFile,LS_UNFORMATTED_MPS);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;

[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Uncomment if only interior solutions are needed
% [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);
% if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


% Optimize model
[nStatus,nErr]=mxlindo('LSoptimize',iModel,nMethod);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (nStatus== LS_STATUS_BASIC_OPTIMAL )    
   [x, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_BASIC_PRIMAL);  
   [y, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_BASIC_DUAL);      
   [s, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_BASIC_SLACK);  
   [d, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_BASIC_REDCOST);      
   
   if (nMethod == LS_METHOD_BARRIER && 0>1),
      [xb, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_INTERIOR_PRIMAL);  
	  [yb, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_INTERIOR_DUAL);      
   	  [sb, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_INTERIOR_SLACK);  
	  [db, nErr] = mxlindo('LSgetSolution',iModel,LSSOL_INTERIOR_REDCOST);
   
		fprintf('\n Distance from the optimal basis (x,y,s,d) to the analytic center (xb,yb,sb,db)\n');
		fprintf(' ||x-xb|| = %12.4g \n',norm(x-xb));
		fprintf(' ||y-yb|| = %12.4g \n',norm(y-yb));
		fprintf(' ||s-sb|| = %12.4g \n',norm(s-sb));
		fprintf(' ||d-db|| = %12.4g \n',norm(d-db));
      fprintf('\n');    
   end;
else
	fprintf('\n Failed to find an optimal solution. Status = %d\n',nStatus);
end;


% Get LP data in MATLAB sparse form
[osense,oshift,c,b,consen,A,lb,ub,nErr]=mxlindo('LSXgetLPData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Get the optimal basis
[cbas,rbas,nErr]=mxlindo('LSgetBasis',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Get the canonical representation
% Append the identity columns
slk = zeros(m,1);
for i=1:m,
   if consen(i) == 'L' | consen(i) == 'E', %flip the sign of the slack if it is a 'G' columns
      slk(i) = 1.0;
   end;
   if consen(i) == 'G', %flip the sign of the slack if it is a 'G' columns
      slk(i) = -1.0;
   end;
   A = [A slk];
   slk(i) = 0.0; %reset to zero vector
end;
clear slk;


% Find the basis indices of A
c_idx = find(cbas>=0);
r_idx = find(rbas>=0)+n;
Bidx  = [c_idx;r_idx]; % positive entries run from 1 to n+m
idx   = [cbas;rbas]+1; % positive entries run from 1 to m

%extract the basis B
B = A(:,Bidx);

try,
    fprintf('\n Condition est. of optimal basis  [B] = %-21.8f \n',condest(B));
catch ME,
    ME.stack;
end;

lm_stat_lpsol;

% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 