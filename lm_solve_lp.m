function [x,y,s,d,rx,rs,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel, LSopts)
% lm_solve_lp: Local LP/QP/NLP driver routine for LINDO API
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage [x,y,s,d,rx,rs,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel, opts)

%
% Last update Jan 09, 2007 (MKA)

lindo;
   
if nargin < 3, 
    LSopts={};
end;
LSopts=LMoptions('lindo',LSopts);
LSopts=LMoptions('linprog',LSopts);

iDefaultLog = LSopts.iDefaultLog;
nMethod = LSopts.nMethod;

   if iDefaultLog==-1,
       fprintf('\n%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');              
       % Set LMcbLP.m as the callback function 
       [nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','dummy');   
%       [nErr] = mxlindo('LSsetCallback',iModel,'TLSiterate','Dummy string');          
       if nErr ~= LSERR_NO_ERROR, return; end;
   end;       
    
   % initialize the output
   x=[];    % primal solution
   y=[];    % dual solution
   s=[];    % primal slacks
   d=[];    % dual slacks
   pobj=[]; % primal objective
   nErr=[]; % error code
   rx=[];   % primal extreme ray
   rs=[];   % slacks associated with rx
   
   if isfield(LSopts,'B') && ~isempty(LSopts.B),
       nErr = mxlindo('LSloadBasis',iModel,LSopts.B.cbas,LSopts.B.rbas);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
   end
   
   % Optimize model   
   [nStatus,nErr]=mxlindo('LSoptimize',iModel,nMethod);  
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
   
   % Display solution stats
   if (iDefaultLog ==-1)
       lm_stat_lpsol;      
   end;

   if nStatus==LS_STATUS_BASIC_OPTIMAL || nStatus==LS_STATUS_OPTIMAL || ...
      nStatus==LS_STATUS_FEASIBLE || nStatus==LS_STATUS_LOCAL_OPTIMAL,
	   % Get primal and dual solution   
       [pobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
       
       [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
       [y,nErr]=mxlindo('LSgetDualSolution',iModel);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
       	  	  
	   [s,nErr]=mxlindo('LSgetSlacks',iModel);
	   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
       
       [d,nErr]=mxlindo('LSgetReducedCosts',iModel);   
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;	   

   elseif nStatus==LS_STATUS_UNBOUNDED,
        [rx,rs,pobj,nErr]=mxlindo('LSgetExtremeRay',iModel);      
        if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
   end;

   if nStatus==LS_STATUS_BASIC_OPTIMAL || nStatus==LS_STATUS_UNBOUNDED,
       [cstat,rstat,nErr] = mxlindo('LSgetBasis',iModel);
       if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); end;
   end;   
return;

