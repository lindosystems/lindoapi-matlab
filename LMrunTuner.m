function  [nErr] = LMrunTuner()
% LMrunTuner: Setup and run tuner with a simple configuration
% The model instances can be in MPS, MPI or LTX format
% 
% Usage:  [nErr] = LMrunTuner()
% 
% Copyright (c) 2020
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

%
% Last update Jan 09, 2020 (MKA)
%
global CTRLC
global MY_LICENSE_FILE
lindo;

CTRLC=0;
nErr=[];


%%
% Read license key from a license file
%%
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

%%
% Create a LINDO environment and a model
%%
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
cleanupObj=onCleanup(@() myCleanupFun(iEnv));

%%
[nErr] = mxlindo('LSsetEnvLogfunc',iEnv,'LMcbLog','Dummy string');

%% Tuner instances
szProbPath = [getenv('LINDOAPI_HOME') '/samples/data'];
[nErr] = mxlindo('LSaddTunerInstance',iEnv,[szProbPath '\p0201.mps.gz']);
[nErr] = mxlindo('LSaddTunerInstance',iEnv,[szProbPath '\p0282.mps.gz']);
[nErr] = mxlindo('LSaddTunerInstance',iEnv,[szProbPath '\p0033.mps.gz']);

[nErr] = mxlindo('LSaddTunerOption',iEnv,'max_parsets',6); 
[nErr] = mxlindo('LSaddTunerOption',iEnv,'time_limit',10); 
[nErr] = mxlindo('LSaddTunerOption',iEnv,'ntrials',2); 
[nErr] = mxlindo('LSaddTunerOption',iEnv,'nthreads',1); 
[nErr] = mxlindo('LSaddTunerOption',iEnv,'seed',1032); 
[nErr] = mxlindo('LSaddTunerOption',iEnv,'criterion',1); 
[nErr] = mxlindo('LSsetTunerStrOption',iEnv,'xdll','lindo64_12_0.dll'); 

%% Tuner dynamic parameters */
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_IPARAM_LP_SCALE); 
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_IPARAM_MIP_PRELEVEL); 
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_IPARAM_MIP_BRANCHDIR); 
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_IPARAM_MIP_BRANCHRULE); 
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_IPARAM_MIP_FP_MODE); 
[nErr] = mxlindo('LSaddTunerZDynamic',iEnv,LS_DPARAM_SOLVER_FEASTOL); 

%% Tuner static groups and parameters */
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,1,LS_IPARAM_MIP_NODESELRULE,4); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,1,LS_DPARAM_MIP_RELINTTOL,0.0001); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,1,LS_DPARAM_SOLVER_OPTTOL,1e-006); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,2,LS_IPARAM_MIP_NODESELRULE,1); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,2,LS_DPARAM_MIP_RELINTTOL,0.001); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,2,LS_DPARAM_SOLVER_OPTTOL,1e-005); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,3,LS_IPARAM_MIP_NODESELRULE,3); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,3,LS_DPARAM_MIP_RELINTTOL,1e-005); 
[nErr] = mxlindo('LSaddTunerZStatic',iEnv,3,LS_DPARAM_SOLVER_OPTTOL,0.0001); 

%%
[nErr] = mxlindo('LSprintTuner',iEnv); 

%%
[nErr] = mxlindo('LSrunTuner',iEnv); 

%%
[szConfig,nErr] = mxlindo('LSgetTunerConfigString',iEnv);

%%
szConfigFile='lindo_tuner_sample.json';
if ~isempty(szConfig),
    [nErr] = mxlindo('LSwriteTunerConfigString',iEnv,szConfig,szConfigFile);
end    
   
%%
[nErr] = mxlindo('LSdisplayTunerResults',iEnv); 
%%
[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    global CTRLC
    CTRLC=1;
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 