function [nOk,nFail] = lm_set_options(iEnv, iModel, LSopts, isMip)
% lm_set_options: Set LSopts to internal solver
%
% Copyright (c) 2001-2022
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage [nOk,nFail] = lm_set_options(iEnv, iModel, LSopts, isMip)

%
% Last update Jan 09, 2022 (MKA)
lindo;
   
if nargin < 3, 
    isMip = 0;
    if nargin <2,
        fprintf('lm_set_options requires at least two arguments\n');
        return;
    end
end;
if ~isstruct(LSopts),
    fprintf('lm_set_options requires the second argument to be a structure with proper fields\n');
    return;
end

nOk=0; nFail=0;
dgOn = strcmp(LSopts.Diagnostics,'on');

if LSopts.SCALE>=0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE,LSopts.SCALE);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end    

if LSopts.iDefaultLog>0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,2);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_TIMLMT,LSopts.MaxTime);
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_TIMLIM,LSopts.MaxTime);
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_LP_ITRLMT,LSopts.MaxIter);
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_ITRLIM,LSopts.MaxIter);   
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_NLP_ITRLMT,LSopts.MaxIter);   
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,LSopts.TolCon);
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,LSopts.TolFun);
if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;

if isMip>0,
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,LSopts.TolFunLP);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,LSopts.TolGapRel);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_ABSOPTTOL,LSopts.TolGapAbs);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,LSopts.iDefaultLog);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end;    

if LSopts.IUSOL>=0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,LSopts.IUSOL);  
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end    

if LSopts.IPMSOL>=0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,LSopts.IPMSOL);   
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end    

if LSopts.SOLVE_DUAL>=0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_BARRIER_PROB_TO_SOLVE,LSopts.SOLVE_DUAL);   
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end

if LSopts.presolve==0,
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end

if LSopts.CBFREQ>0,
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,LSopts.CBFREQ);
    if nErr ~= LSERR_NO_ERROR, if dgOn, LMcheckError(iEnv,nErr); end; nFail = nFail + 1; else nOk = nOk+1; end;
end    

if dgOn && nFail,
    fprintf('Warning: lm_set_options failed setting "%d" parameters\n',nFail);
end

return;

