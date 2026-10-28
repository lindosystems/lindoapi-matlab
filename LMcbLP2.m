function flag = LMcbLP2(iModel,iLoc,cbData)
% LMcbLP  : Callback M-function that LINDO API calls every 't' seconds 
%           when solving linear models. For nonlinear models, the callback 
%           function is called at every iteration.
% 
% Usage:  This m-function is called by LINDO API internally. 
%         See LMsolvef.m to see how it is set using LSsetCallback().
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1332 North Halsted Street      info@lindo.com
% Chicago, Illinois 60642        http://www.lindo.com

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set flag to a nonzero value to interrupt the solver, otherwise
%% it should be set to zero.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flagtmp = 0;
flag = flagtmp;