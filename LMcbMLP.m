function flag = LMcbMLP(imodel,iLoc,cbData)
% LMcbMLP : Callback M-function that LINDO API calls during B&B
% 
% Usage:  This m-function is called by LINDO API internally. 
%         See LMsolvef.m to see how it is set using LSsetCallback().
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com
%
%% Last update Jan 09, 2007 (MKA)
%
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback information macros 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lindo;

if (iLoc == LSLOC_MIP)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Get callback information 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [sim_iter ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_SIM_ITER);
  [bar_iter ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_BAR_ITER);
  [nlp_iter ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_NLP_ITER);
  
  [bestbnd,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_DINFO_MIP_BESTBOUND);
  [mipobj ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_DINFO_MIP_OBJ);
  [numbrn ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_BRANCHCOUNT);
  [mipstat,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_STATUS);
  [numlp  ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_LPCOUNT);
  [numact ,nErr] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIP_ACTIVENODES); 
    
  iter = sim_iter+bar_iter+nlp_iter;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Display to screen
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  fprintf('%10d %10d %15.6g %15.6g %10d %10d %10d\n',mipstat,iter,bestbnd,mipobj,numlp,numbrn,numact);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set flag to a nonzero value to interrupt the solver, otherwise
%% it should be set to zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag = 0;
