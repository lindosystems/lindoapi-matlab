function [nStatus] = LMtestSP2(szCoreFile,szTimeFile,szStocFile, N, B, SEED)
% LMtestSP2
% Test SP interface in LINDO API.
% Usage: [nStatus] = LMtestSP2(szCoreFile,szTimeFile,szStocFile, N, B, SEED)
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

if nargin<6.
    SEED = 1031;
    if nargin< 5
        B = 2;
        if nargin< 4
            N = 10;
            if nargin < 3,                
                LINDOAPI_HOME=getenv('LINDOAPI_HOME');
                if ~isempty(LINDOAPI_HOME),
                    szCoreFile = [LINDOAPI_HOME '/samples/data/gbd/gbd-sw.cor'];
                    szTimeFile = [LINDOAPI_HOME '/samples/data/gbd/gbd-sw.tim'];
                    szStocFile = [LINDOAPI_HOME '/samples/data/gbd/gbd-sw.sto'];
                else                    
                    help lmtestsp2;
                    fprintf('System variable $LINDOAPI_HOME not found.\n');
                    return;
                end;
            end;
        end;
    end;
end;

LMversion;

% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Create a LINDO environment
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
anSampleSize=N*ones(numStages,1);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_STOC_RG_SEED, SEED);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr] = mxlindo('LSloadSampleSizes',iModel,anSampleSize);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelStocIntParameter',iModel,LS_IPARAM_STOC_PRINT_LEVEL,2);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,5);

[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_STOC_METHOD, LS_METHOD_STOC_NBD);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_STOC_BUCKET_SIZE, B);

[nStatus,nErr]=mxlindo('LSsolveSP',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

     [dObj,nErr] = mxlindo('LSgetStocInfo', iModel,LS_DINFO_STOC_EVOBJ,0);     
     [dEvpi,nErr] = mxlindo('LSgetStocInfo', iModel,LS_DINFO_STOC_EVPI,0);

     [etime,nErr] = mxlindo('LSgetStocInfo', iModel,LS_DINFO_STOC_TOTAL_TIME,0);
     iters=0;
     [siter,nErr] = mxlindo('LSgetStocInfo', iModel,LS_IINFO_STOC_SIM_ITER,0);
     if (nErr==0), iters=iters+siter; end;
     [biter,nErr] = mxlindo('LSgetStocInfo', iModel,LS_IINFO_STOC_BAR_ITER,0);
     if (nErr==0), iters=iters+biter; end;
     [niter,nErr] = mxlindo('LSgetStocInfo', iModel,LS_IINFO_STOC_NLP_ITER,0);
     if (nErr==0), iters=iters+niter; end;
     [nfcuts,nErr] = mxlindo('LSgetStocInfo', iModel,LS_IINFO_STOC_NUM_NBF_CUTS,0);
     [nocuts,nErr] = mxlindo('LSgetStocInfo', iModel,LS_IINFO_STOC_NUM_NBO_CUTS,0);
     
     if 0>1,
         fp=fopen('swrite.log','a+t');
         ai = strfind(szStocFile,'/');
         sz = szStocFile;
         if (length(ai)>0),
            ai = ai(length(ai));
            sz = szStocFile;
            sz(1:ai)=[];
         end;
         strlog = sprintf('%16s, %3d, %6d, %6d, %6d, %15f, %15f, %12f, %10d, %d+%d',...
             sz,nStatus, SEED,N,B,dObj,dEvpi,etime,iters,nocuts,nfcuts);
         fprintf(fp,'%s\n',strlog);
         fprintf('%s\n',strlog);
         fclose(fp);
     end
     


[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 