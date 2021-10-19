% LMaddvars
% Read an MPS model, optimize it and then add a copy of all
% existing columns then reoptimize.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com  
%
% Usage [nErr] = LMaddvars('e:\prob\mps\lp\n1\afiro.mps')



function [nErr] = LMaddvars(mpsfile)
lindo;
global MY_LICENSE_FILE

if nargin<1,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    mpsfile = [LINDOAPI_HOME '/samples/data/testlp.mps'];
end

LMversion;

% Read license key from a license file
[MY_LICENSE_KEY,status] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, return; end;
onCleanup(@() myCleanupFun(iEnv));

%create a model
[iModel,crestatus]=mxlindo('LScreateModel',iEnv);

%read the MPS file into the model
[nErr]=mxlindo('LSreadMPSFile',iModel,mpsfile,0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;

%keep the dimension info in LHS vectors
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%get the LP data in internal sparse format
[objsen,oshift,c,b,consen,kA,kAcnt,A,iA,l,u,nErr]=mxlindo('LSgetLPData',iModel);

[OptStat,nErr]=mxlindo('LSoptimize',iModel,1);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);

fprintf('Stats for current model.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);

% add copies of the existing columns
fprintf('\nAdding all columns...\n\n');
[nErr] = mxlindo('LSaddVariables',iModel,n,[],[],kA,kAcnt,A,iA,c,l,u);
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


[OptStat,nErr]=mxlindo('LSoptimize',iModel,1);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);

fprintf('Stats after new columns added.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);

fprintf('\nAdding all columns (sparse A matrix) LM...\n\n');
[objsen,oshift,c,b,consen,A,l,u,nErr]=mxlindo('LSXgetLPData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nErr] = mxlindo('LSXaddVariables',iModel,n,[],A,c,l,u);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
fprintf('Stats after new columns added.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);


[nErr]=mxlindo('LSdeleteEnv',iEnv);


%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 

