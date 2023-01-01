function [nStatus] = LMtestSP1(szCoreFile,szTimeFile,szStocFile)
% LMtestSP1
% Test SP interface in LINDO API.
% Usage: [nStatus] = LMtestSP1(szCoreFile,szTimeFile,szStocFile)
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

if nargin < 3,
   LINDOAPI_HOME=getenv('LINDOAPI_HOME');
   if ~isempty(LINDOAPI_HOME),
       szCoreFile = [LINDOAPI_HOME '/samples/data/newsvendor/smpi/newsvendor.mpi'];
       szTimeFile = [LINDOAPI_HOME '/samples/data/newsvendor/smpi/newsvendor-agg.time'];
       szStocFile = [LINDOAPI_HOME '/samples/data/newsvendor/smpi/newsvendor-agg.stoch'];
   else
       help lmtestsp1;
       fprintf('System variable $LINDOAPI_HOME not found.\n');       
       return;
   end;
end;

% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);
iEnv=0;
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%% Create a LINDO environment and model
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr,1) ; return; end;

[nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
if nErr ~= LSERR_NO_ERROR, return; end;
[nErr] = mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_NLP_LINEARZ,1); 

%% Read model
[nErr]=mxlindo('LSreadSMPIFile',iModel,szCoreFile,szTimeFile,szStocFile);
if nErr ~= LSERR_NO_ERROR, 
    [nErr]=mxlindo('LSreadSMPSFile',iModel,szCoreFile,szTimeFile,szStocFile,LS_UNFORMATTED_MPS);
end;   
if nErr ~= LSERR_NO_ERROR, 
    LMcheckError(iEnv,nErr,1) ; 
    return; 
end;

%% 
[numStages,nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STOC_NUM_STAGES);
anSampleSize=5*ones(numStages,1);
[nErr] = mxlindo('LSloadSampleSizes',iModel,anSampleSize);
%if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[anRStages,nErr] = mxlindo('LSgetConstraintStages',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[anCStages,nErr] = mxlindo('LSgetVariableStages',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[anSampleSize,nErr] = mxlindo('LSgetSampleSizes',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelStocIntParameter',iModel,LS_IPARAM_STOC_PRINT_LEVEL,2);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,5);
[dVal,nErr]=mxlindo('LSgetModelStocDouParameter',iModel,LS_DPARAM_STOC_RELOPTTOL);

%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_STOC_METHOD, LS_METHOD_STOC_NBD);

[nStatus,nErr]=mxlindo('LSsolveSP',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nQCnonzeros,paiQCvarndx1,paiQCvarndx2,padQCcoef,nErr] = ...
                                 mxlindo('LSgetCorrelationMatrix',iModel,0,LS_CORR_LINEAR);
if nErr==LSERR_NO_ERROR,
    fprintf('\nCorrelations\n');
    for i=1:length(padQCcoef),
        fprintf('rho(%d,%d): %g\n',paiQCvarndx1(i),paiQCvarndx2(i),padQCcoef(i));
    end;
else
    fprintf('\nLSgetCorrelationMatrix() returned error %d\n',nErr);
end;

[iNumBlockEvents, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STOC_NUM_EVENTS_BLOCK);
if (iNumBlockEvents>0),
    fprintf('Events with Joint Distributions...\n');            
    for iEvent=0:iNumBlockEvents-1,
        [nDistType,iStage,nRealzBlock,padProbs,iModifyRule,nErr] = ...
                                   mxlindo('LSgetDiscreteBlocks',iModel,iEvent);
        for iRealz=0:nRealzBlock-1,
            [nRealz,paiArows,paiAcols,paiStvs,padVals,nErr] = ...
                               mxlindo('LSgetDiscreteBlockOutcomes',iModel,iEvent,iRealz);
             fprintf('Event:%2d, Stage:%2d, Block:%d, Prob:%4g\n',iEvent,iStage,iRealz,padProbs(iEvent+1));
             disp([paiStvs paiArows paiAcols]);                           
             for i=1:nRealz,
                 [pSample, nErr] = mxlindo('LSgetStocParSample',iModel,paiStvs(i),paiArows(i),paiAcols(i));
             end;
        end;
    end;                           
end;                               

[iNumDiscreteEvents, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STOC_NUM_EVENTS_DISCRETE);
if (iNumDiscreteEvents>0),
    fprintf('Events with Discrete Distributions...\n');        
    for iEvent=0:iNumDiscreteEvents-1,
        [nDistType,iStage,iRow,jCol,iStv, ...
          nRealizations,padProbs,padVals,iModifyRule,nErr] = ...
                               mxlindo('LSgetDiscreteIndep',iModel,iEvent); 
        [pSample, nErr] = mxlindo('LSgetStocParSample',iModel,iStv,iRow,jCol);
    end;
end;

[iNumParametricEvents, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STOC_NUM_EVENTS_PARAMETRIC);
if (iNumParametricEvents>0),
    fprintf('Events with Parametric Distributions...\n');    
    for iEvent=0:iNumParametricEvents-1,
        [nDistType,iStage,iRow,jCol,iStv, ...
              nParams,padParams,iModifyRule,nErr] = ...
                               mxlindo('LSgetParamDistIndep',iModel,iEvent);
        [pSample, nErr] = mxlindo('LSgetStocParSample',iModel,iStv,iRow,jCol);
    end;
end;

[iNumScenarios, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_STOC_NUM_EXPLICIT_SCENARIOS);
if (iNumScenarios>0),
    fprintf('Scenarios...\n');
    for jScenario=0:iNumScenarios-1,
        [iParentScen, iBranchStage, dProb, nRealz, paiArows,paiAcols,paiStvs,padVals,iModifyRule,nErr] = ...
                              mxlindo('LSgetScenario',iModel,jScenario);
        fprintf('Scenario:%2d, Parent: %2d, BranchStage: %2d, Prob: %4g, numRealizations: %d\n',...
            jScenario,iParentScen, iBranchStage, dProb, nRealz);
    end;
end;

[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 