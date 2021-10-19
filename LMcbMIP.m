function retval  =  LMcbMIP(imodel,cbData,obj,primal)
% LMcMIP	: Callback M-function that LINDO API calls every time a new integer solution is found.
% 
% Usage:  This m-function is called by LINDO API internally. 
%         Check out LMsolvef.m to see how it is set using 
%         LSsetMIPCallback().
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
% Last update Jan 09, 2007 (MKA)
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Callback information macros  (defined in lindo.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lindo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get callback information 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[iter,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_SIM_ITER);
[bestbnd,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_DINFO_MIPBESTBOUND);
[mipobj,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_DINFO_MIPOBJ);
[numbranch,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIPBRANCHCOUNT);
[mipstat,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIPSTATUS);
[numlp,status] = mxlindo('LSgetMIPCallbackInfo',imodel,LS_IINFO_MIPLPCOUNT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display to screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('%10d %10d %10d %10d %15.3e %15.3e\n',mipstat,iter,numlp,numbranch,bestbnd,mipobj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Return a nonzero value to interrup the solver.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if numlp > 3
   retval  =  0;
else
   retval = 0;
end;

   
