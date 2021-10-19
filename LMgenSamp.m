function [X,nErr] = LMgenSamp(szDistType,dPar,nSampSize,iVarControl,nSeed,nDim,nPrintLevel)
% LMgenSamp
% Test sampling routines in LINDO API.
% Usage: [nStatus] =LMgenSamp(szDistType,dPar,iVarControl,nSampSize,nSeed)
%
% INPUT (RHS)
%   szDistType    Distribution type {'no','be',po',...}
%   dPar          Parameters of distribution dPar[1..M]
%   iVarControl   Variance reduction method
%   nSampSize     Sample size
%   nSeed         Randomization seed
%   nDim          Independent samples each 'nSampSize' long
%   nPrintLevel   Print level
% OUTPUT (LHS)
%   X             Sample matrix, each column representing an independent
%                 sample.
%   nErr          Error code.
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
X=[]; XCI=[];
if nargin<7,
    nPrintLevel=0;
    if nargin<6,
        nDim=1;
        if nargin < 5,
            nSeed = 1031;
            if nargin <4,
                iVarControl = LS_LATINSQUARE;  
                %iVarControl = LS_MONTECARLO;
                %iVarControl = LS_ANTITHETIC;               
                if nargin<3,
                    nSampSize = 50;                    
                    if nargin < 2,
                        dPar=[1 1];
                        if nargin < 1,
                            help LMgenSamp;
                            return;
                        end;
                    end;
                end;    
            end;
        end;
    end;
end;
    




if strcmp(szDistType,'be'),
    distType=LSDIST_TYPE_BETA; 
elseif strcmp(szDistType,'ga')
    distType=LSDIST_TYPE_GAMMA; 
elseif strcmp(szDistType,'no')
    distType=LSDIST_TYPE_NORMAL;     
elseif strcmp(szDistType,'u')
    distType=LSDIST_TYPE_UNIFORM; 
elseif strcmp(szDistType,'po')
    distType=LSDIST_TYPE_POISSON;         
elseif strcmp(szDistType,'exp')
    distType=LSDIST_TYPE_EXPONENTIAL;      
elseif strcmp(szDistType,'dsc')
    distType=LSDIST_TYPE_DISCRETE;     
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

V=[];
rand('state',0);
dXbarAvr=0;
dStdAvr=0;

if nPrintLevel>0,
    fprintf(['                         %9s  (%9s)  (%7s)      %9s  (%7s) (%7s) \n'],...
            'xbar','Mean','err(% )','Std','sqrt(Var)','err(% )');
    end;
for i=1:nDim,
    [pSample(i), nErr] = mxlindo('LSsampCreate',iEnv,distType );
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

    [nErr] = mxlindo('LSsampSetRG',pSample(i), pRG);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

    if (distType~=LSDIST_TYPE_DISCRETE),     
        for ipar = 1:length(dPar);
            [nErr] = mxlindo('LSsampSetDistrParam',pSample(i),ipar-1, dPar(ipar)); 
            if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
        end;
    else
        nLen = 10;
        padProb = ones(10,1)*1/nLen;        
        padVals = rand(10,1)*100;
        V=[V padVals];
        [nErr] = mxlindo('LSsampLoadDiscretePdfTable',pSample(i), nLen, padProb,padVals);
    end;

    [nErr] = mxlindo('LSsampGenerate',pSample(i), iVarControl, nSampSize);
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

    [dXbar,dStd,nErr] = LMdispSampleSummary(pSample(i),nPrintLevel);
    dXbarAvr = dXbarAvr + dXbar;
    dStdAvr = dStdAvr + dStd;
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;    

[na,nErr]=mxlindo('LSsampGetInfo',pSample(1),LS_IINFO_DIST_NARG);
dPar=zeros(na,1);
for i=0:na-1,
    [dPar(i+1),nErr]=mxlindo('LSsampGetDistrParam',pSample(1),i);
end;
dXbarAvr = dXbarAvr/nDim;
dStdAvr = dStdAvr/nDim;
[dMean,dVar,distName,nErr] = LMmeanvar(distType,dPar);
if nPrintLevel>0,
fprintf('xbarbar... =%14.4f (%.4f) (%%%.3f)\n',dXbarAvr,dMean,abs(dXbarAvr-dMean)/(dMean)*100);
fprintf('stdbar.... =%14.4f (%.4f) (%%%.3f)\n',dStdAvr,dVar,abs(dStdAvr-dVar)/dVar*100);
end
%nQCnonzeros=3;
%paiQCvarndx1=[0 0 1];
%paiQCvarndx2=[0 1 1];
%padQCcoef=[1 +0.5 1];
%nErr = mxlindo('LSsampInduceCorrelation',pSample,nDim,LS_CORR_LINEAR,nQCnonzeros,paiQCvarndx1,paiQCvarndx2,padQCcoef);
%if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

for i=1:nDim,
    [pX, nLen, nErr] = mxlindo('LSsampGetPoints',pSample(i));
    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    
%    [pXCI, nLen, nErr] = mxlindo('LSsampGetCIPoints',pSample(i));
%    if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
    
    % Map indices to values
    if (distType==LSDIST_TYPE_DISCRETE), 
        padVals = V(:,i);
        pX = padVals(pX+1);
        pXCI = padVals(pXCI+1);
    end;
    
    X=[X pX];
    %XCI=[XCI pXCI];
end;

[nErr] = mxlindo('LSdisposeRG',pRG);

for i=1:nDim,
    [nErr] = mxlindo('LSsampDelete',pSample(i));
end;    

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 