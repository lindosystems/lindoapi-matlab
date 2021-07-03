function [T] = LMtableau(szInputFile)
% LMtableau	: Constructs the optimal tableau using LSdoFTRAN() routine
% 
% Usage:  [T] = LMtableau(szInputFile)

% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com       
%
% Last update Jan 09, 2007 (MKA)
%

global MY_LICENSE_FILE
lindo;

verbose = 1;
if nargin<1,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    szInputFile = [LINDOAPI_HOME '/samples/data/testlp.mps']; 
end  
% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

%turn the preprocessor off/on
[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_LP_PRELEVEL,0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%turn the scaler off/on
[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_SCALE,0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%force a solution to be computed even if infeasible or unbounded
[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_IUSOL,1);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%create a model
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if verbose==1,
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
end
%read the MPS file into the model
[nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_UNFORMATTED_MPS);
if nErr,
   [nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_FORMATTED_MPS);
   if nErr,
      [nErr]=mxlindo('LSreadLINDOFile',iModel,szInputFile);
      if nErr,
         fprintf('Bad input format or file does not exist.\n');
         if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
      end;      
   end;
end;


%keep the dimension info
[n, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);      
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);            
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[vtype,nErr]=mxlindo('LSgetVarType',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (verbose==2)
    fprintf('\n%10s %15s %15s %15s %15s\n','iter','pobj','dobj','pinf','dinf');
    nErr = mxlindo('LSsetCallback',iModel,'LMcback','Dummy string');   
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;
   
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,verbose);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_OBJSENSE,LS_MIN);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%optimize it and retrieve optimal solution/basis
[optstat,nErr]=mxlindo('LSoptimize',iModel,LS_METHOD_FREE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
nStatus = optstat;
if optstat~=LS_STATUS_BASIC_OPTIMAL, 
    fprintf('Solution is not optimal (%d)\n', optstat); 
    %return;
else
    fprintf('Solution is optimal (%d)\n', optstat); 
    lm_stat_lpsol;
end;

[x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[y,nErr]=mxlindo('LSgetDualSolution',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[s,nErr]=mxlindo('LSgetSlacks',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

  % get solution stats
  [etime, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_ELAPSED_TIME);    
  [sim_iter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_SIM_ITER);        
  [bar_iter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BAR_ITER);         
  [nlp_iter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NLP_ITER);        
  [imethod, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_METHOD);         
  [pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_PINFEAS);
  [dfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DINFEAS);
  [pobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
  [dobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DOBJ);
  [basstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BASIC_STATUS);  
  [solstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STATUS);  
  [dsolstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_DUAL_STATUS); 
  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[cbas,rbas,nErr]=mxlindo('LSgetBasis',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%get the LP data in internal sparse format
[objsen,oshift,c0,b,consen,kA,kAcnt,A,iA,l,u,nErr]=mxlindo('LSgetLPData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%get the LP data in MATLAB sparse form, just to get the AA
[osense,oshift,c0,b,consen,A0,l,u,nErr]=mxlindo('LSXgetLPData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

c = [c0; zeros(m,1)];

%get the full representation
AA = full(A0);

%append the identity columns
slk = zeros(m,1);
for i=1:m,
   if consen(i) == 'L' | consen(i) == 'E', %flip the sign of the slack if it is a 'G' columns
      slk(i) = 1.0;
   end;
   if consen(i) == 'G', %flip the sign of the slack if it is a 'G' columns
      slk(i) = -1.0;
   end;
   AA = [AA slk];
   slk(i) = 0.0; %reset to zero vector
end;
clear slk;

%find the basis indices of AA
c_idx = find(cbas>=0);
r_idx = find(rbas>=0)+n;
Bidx  = [c_idx;r_idx]; % positive entries run from 1 to n+m
bas   = [cbas;rbas]; % positive entries run from 1 to m
for k=1:m+n,
    if bas(k)>=0, bas(k) = bas(k) + 1; end
end


%extract the basis B
B = AA(:,Bidx);
P = bas(find(bas>0)); %permutation matrix
v = zeros(m,m);
for i=1:m, v(P(i),i) = 1; end;
P = v;
clear v;

%initialize the tableau T as an empty matrix
T=[];

%compute the columns associated w/ structural (original) variables in the LP
for k=1:n,
   
   %a_k denotes the k^{th} column of A matrix
   
   nz_ak = kAcnt(k);            % number of nonzeroes in col_{k}
   jbeg  = kA(k);               % beg index of col_{k}
   jend  = kA(k+1)-1;           % end index of col_{k}
   ia_k  = iA(jbeg+1:jend+1);	% map row indices of col_{k}
   a_k   = A(jbeg+1:jend+1);	% map coeff of col_{k}
     
   [xnz,xind,xval,nErr]=mxlindo('LSdoFTRAN',iModel,nz_ak,ia_k,a_k);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   
   xjnd=1*ones(size(xind));
   col = zeros(m,1);
   col(xind+1,1) = xval;
   T = [T col];
   
   if mod(k, 100) == 0,
      fprintf('Columns processed > %d\n',k);
   end;
   
end;

%compute the columns associated w/ slack/surplus variables in the LP
for i=1:m,
   
   nz_ak = 1;
   ia_k = i-1;
   a_k = 1.0;
   if consen(i)=='G'
      a_k = -1.0;
   end;
   
   [xnz,xind,xval,nErr]=mxlindo('LSdoFTRAN',iModel,nz_ak,ia_k,a_k);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   
   xjnd=1*ones(size(xind));
   col = zeros(m,1);
   col(xind+1,1) = xval;
   T = [T col];
   if mod(i, 100) == 0,
      fprintf('Columns processed > %d\n',i+n);
   end;   
   
end;


[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

return;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 