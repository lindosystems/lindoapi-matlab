function flag = LMcbLP(iModel,iLoc,cbData)
% LMcbLP  : Callback M-function that LINDO API calls every 't' seconds 
%           when solving linear models. For nonlinear models, the callback 
%           function is called at every iteration.
% 
% Usage:  This m-function is called by LINDO API internally. 
%         See LMsolvef.m to see how it is set using LSsetCallback().
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com

%% Last update Jan 09, 2007 (MKA)
%
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback information macros 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lindo;

if (iLoc == LSLOC_PRIMAL  | iLoc == LSLOC_DUAL | ... 
    iLoc == LSLOC_BARRIER | iLoc == LSLOC_CONOPT | ...
    iLoc == LSLOC_LOCAL_OPT)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Get callback information from PRIMAL SIMPLEX, DUAL SIMPLEX and 
  %% NONLINEAR solvers
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  if (iLoc == LSLOC_PRIMAL | iLoc == LSLOC_DUAL)
     [iter ,nErr] = mxlindo('LSgetCallbackInfo',iModel,iLoc,LS_IINFO_SIM_ITER);
  elseif (iLoc == LSLOC_BARRIER)
     [iter ,nErr] = mxlindo('LSgetCallbackInfo',iModel,iLoc,LS_IINFO_BAR_ITER);
  else     
     [iter ,nErr] = mxlindo('LSgetCallbackInfo',iModel,iLoc,LS_IINFO_NLP_ITER);
  end;
  
  [pobj,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_DINFO_POBJ);
  [dobj,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_DINFO_DOBJ);
  [pinf,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_DINFO_PINFEAS);
  [dinf,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_DINFO_DINFEAS);
      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Display to screen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (iLoc == LSLOC_LOCAL_OPT),
     [bobj,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_DINFO_MSW_POBJ);
     [pass,nErr] = mxlindo('LSgetCallbackInfo', iModel, iLoc , LS_IINFO_MSW_PASS);
     [solStatus,nErr] = mxlindo('LSgetInfo',iModel , LS_IINFO_PRIMAL_STATUS);  
     fprintf('\n%10d %15.7e %15.7e %15.7e %15.7e (*)',iter,pobj,dobj,pinf,dinf);
  else
     fprintf('\n%10d %15.7e %15.7e %15.7e %15.7e',iter,pobj,dobj,pinf,dinf);     
  end;
 
 
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set flag to a nonzero value to interrupt the solver, otherwise
%% it should be set to zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag = 0;
