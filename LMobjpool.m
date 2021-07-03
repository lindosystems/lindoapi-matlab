function [nStatus] = LMobjpool()
% LMobjpool
%
% Bi-objective linear assignment problem
% 
%MODEL:
% [DEM_1] V_1_1 + V_2_1 + V_3_1 = 1;
% [DEM_2] V_1_2 + V_2_2 + V_3_2 = 1;
% [DEM_3] V_1_3 + V_2_3 + V_3_3 = 1;
% [SUP_1] V_1_1 + V_1_2 + V_1_3 = 1;
% [SUP_2] V_2_1 + V_2_2 + V_2_3 = 1;
% [SUP_3] V_3_1 + V_3_2 + V_3_3 = 1;
%
%[OBJ1] MIN= 3 * V_1_1 +  9 * V_1_2 + 7 * V_1_3 + 
%           16 * V_2_1 + 10 * V_2_2 + 6 * V_2_3 + 
%            2 * V_3_1 + 7 * V_3_2 + 11 * V_3_3;                                            
%
%[OBJ2] MIN= 16 * V_1_1 + 15 * V_1_2 +  6 * V_1_3 + 
%             5 * V_2_1 +  7 * V_2_2 + 13 * V_2_3 + 
%             1 * V_3_1 +  2 * V_3_2 + 13 * V_3_3;
%@BIN(V_I_J);
%END

% Copyright (c) 2020
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

%
% Last update May 15, 2020 (MKA)
%

lindo;
global MY_LICENSE_FILE

nMethod = LS_METHOD_BARRIER;
iDefaultLog = 1; 
 
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

nErr = mxlindo('LSreadMPIFile',iModel,'c:\tmp\assign5.mpi');
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;

[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nc,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONT);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

padC2 =[16 5 6 19 12 15 7 13 7 7 1 2 13 2 3 14 7 8 1 7 10 10 1 0 0];
nErr = mxlindo('LSaddObjPool',iModel,padC2,LS_MIN,1,1e-7);

if n>nc,
    % Optimize model
    [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    lm_stat_mipsol(iModel,iDefaultLog);

    X=[];
    nErr = mxlindo('LSloadSolutionAt',iModel,0,0);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    [x,nErr]=mxlindo('LSgetMIPPrimalSolution',iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    X=[X x];

    nErr = mxlindo('LSloadSolutionAt',iModel,1,0);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    [x,nErr]=mxlindo('LSgetMIPPrimalSolution',iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    X=[X x];
else
% Optimize model
    [x,y,s,d,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    lm_stat_mipsol(iModel,iDefaultLog);

    X=[];
    nErr = mxlindo('LSloadSolutionAt',iModel,0,0);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    X=[X x];

    nErr = mxlindo('LSloadSolutionAt',iModel,1,0);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    X=[X x];    
end
X
% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 