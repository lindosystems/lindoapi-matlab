function [nErr] = lmtesthist()
lindo;
global MY_LICENSE_FILE

nErr= [];
nSampSize = 500;
%nVarControlType=LS_MONTECARLO;
nVarControlType=LS_LATINSQUARE;
nDistType = LSDIST_TYPE_POISSON;
nPrintLevel = 1;
nSeed=1031;
dHistLow=0;
dHistHigh=0;
nBins=0;
Lambda=10;
%%
% Read license key from a license file
[MY_LICENSE_KEY,status] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));


[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[pRG, nErr] = mxlindo('LScreateRG',iEnv,LS_RANDGEN_FREE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsetRGSeed',pRG, nSeed);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[pSample, nErr] = mxlindo('LSsampCreate',iEnv, nDistType);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsampSetRG',pSample, pRG);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsampSetDistrParam',pSample,0, Lambda);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSsampGenerate',pSample, nVarControlType, nSampSize);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[pX, nLen, nErr] = mxlindo('LSsampGetPoints',pSample);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    
[nErr] = mxlindo('LSsampDelete',pSample);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
 

%w=getw();norm(w-pX)
padVals=pX;
padWeights=[];
nBins=10;
[panBinCounts,padBinProbs,padBinLow,padBinHigh,padBinLeftEdge,padBinRightEdge,nErr] = ...
     mxlindo('LSgetHistogram',iModel,nSampSize,padVals,padWeights,dHistLow,dHistHigh,nBins);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end; 

if nPrintLevel>0,
    fprintf('%9s, %9s, %9s, %9s, %9s, %9s\n','BinCounts','BinProbs',...
            'BinLow','BinHigh','BinLeft','BinRight'); 
    for i=1:nBins,
        fprintf('%9d, %9g, %9g, %9g, %9g, %9g\n',panBinCounts(i),padBinProbs(i),...
            padBinLow(i),padBinHigh(i),padBinLeftEdge(i),padBinRightEdge(i));
    end;
end;
panBinCenters=(padBinLeftEdge+padBinRightEdge)/2;

bar(panBinCenters,padBinProbs);
obsCounts = panBinCounts';
n = sum(obsCounts);
expCounts = n*(poisscdf(padBinRightEdge,Lambda)-poisscdf(padBinLeftEdge,Lambda));


[h,p,st] = chi2gof(panBinCenters,'ctrs',panBinCenters,...
                        'frequency',obsCounts, ...
                        'expected',expCounts,...
                        'nparams',1)

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 