function [dAvr,dStd,nErr] = LMdispSampleSummary(pSample,verbose)
% LMdispSampleSummary
% Display sample summary
% Usage: [nErr] = LMdispSampleSummary(pSample,verbose)
%
% Copyright (c) 2008
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com 

%
% Last update Apr, 2009 (MKA)
%

lindo;
if nargin<2,
    verbose=1;
end;
[distType,nErr]=mxlindo('LSsampGetInfo',pSample,LS_IINFO_DIST_TYPE);

[na,nErr]=mxlindo('LSsampGetInfo',pSample,LS_IINFO_DIST_NARG);
dPar=zeros(na,1);
for i=0:na-1,
    [dPar(i+1),nErr]=mxlindo('LSsampGetDistrParam',pSample,i);
end;

[nVarControl,nErr]=mxlindo('LSsampGetInfo',pSample,LS_IINFO_SAMP_VARCONTROL_METHOD);
distName=[];
dMean=[];
dVar=[];
[dMean,dVar,distName,nErr] = LMmeanvar(distType,dPar);

if nVarControl == LS_LATINSQUARE,
    szMethod = 'LHS';
elseif nVarControl == LS_ANTITHETIC,
    szMethod = 'ANT';
elseif nVarControl == LS_ANTITHETIC+LS_LATINSQUARE,
    szMethod = 'LHS+ANT';
else
    szMethod = 'NONE';
end;

[dAvr, nErr] = mxlindo('LSsampGetInfo',pSample,LS_DINFO_SAMP_MEAN);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[dStd, nErr] = mxlindo('LSsampGetInfo',pSample,LS_DINFO_SAMP_STD);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[pX, nLen, nErr] = mxlindo('LSsampGetPoints',pSample);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

hist(pX,25); 
  
derr = 0;
if verbose>2,
    fprintf('%3s %13s %13s %13s\n','i','X','u=CDF(X)','CDFINV(u)');
    for i=1:nLen,
       [utmp, nErr] = mxlindo('LSsampEvalDistr',pSample,LS_CDF, pX(i));
       [dtmp, nErr] = mxlindo('LSsampEvalDistr',pSample,LS_CDFINV, utmp);
       derr = derr + abs(pX(i)-dtmp);     
       fprintf('%3d %13.7f %13.7f %13.7f\n',i,pX(i),utmp,dtmp);     
    end;   
end;



if (distType~=LSDIST_TYPE_DISCRETE),    
    if verbose>1,
        fprintf('\n');
        fprintf('|err|....... =%14g\n',derr);
        fprintf('avr......... =%14.4f (%.4f) (%%%.3f)\n',dAvr,dMean,abs(dAvr-dMean)/(dMean)*100);
        fprintf('std......... =%14.4f (%.4f) (%%%.3f)\n',dStd,dVar,abs(dStd-dVar)/dVar*100);
    end;

    if verbose>0,
        if length(dPar)==2,
            fprintf([distName '       %9.4f  (%9.4f)  (%%%-7.3f)      %9.4f  (%7.4f) (%%%-7.3f) \n'],...
                szMethod,dPar(1),dPar(2),dAvr,dMean,abs(dAvr-dMean)/(dMean)*100,dStd,dVar,abs(dStd-dVar)/dVar*100);
        else
            fprintf([distName '       %9.4f  (%9.4f)  (%%%-7.3f)      %9.4f  (%7.4f) (%%%-7.3f) \n'],...
                szMethod,dPar(1),dPar(1),dAvr,dMean,abs(dAvr-dMean)/(dMean)*100,dStd,dVar,abs(dStd-dVar)/dVar*100);
        end;
            
    end;
end;