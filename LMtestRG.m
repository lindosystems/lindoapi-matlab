function [nStatus] = LMtestRG(nSeed)
% LMtestRG
% Test random rumber generation routines in LINDO API.
% Usage: [nStatus] = LMtestRG(nSeed)
%
% Copyright (c) 2008
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

%
% Last update Aug 29, 2008 (MKA)
%

lindo;
global MY_LICENSE_FILE

if nargin < 1,
   nSeed = 1031;
end;

% Read license key from a license file
[MY_LICENSE_KEY,status] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

[pRG, nErr] = mxlindo('LScreateRG',iEnv,LS_RANDGEN_FREE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetRGSeed',pRG, nSeed);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetDistrRG',pRG,LSDIST_TYPE_NORMAL);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetDistrParamRG',pRG,0, 0.0); 
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetDistrParamRG',pRG,1, 1.0); 
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

ps = [];
for i=1:5000,
    [dVal,nErr] = mxlindo('LSgetDistrRV',pRG);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    %fprintf('%3d, %13.6f\n',i, dVal);
    ps = [ps; dVal];
end;

[nErr] = mxlindo('LSdisposeRG',pRG);

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

hist(ps,100);

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 