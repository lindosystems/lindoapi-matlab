function flag = LMcbLog(imodel,line,cbData)
% LMcbMLP: LINDO API uses this callback function to have its
%          messages printed to Matlab's stdout. It simply sends
%          the string to printed as an argument and then waits 
%          for it to be printed or processed some other way.
% 
% Usage:  This m-function is called by LINDO API internally at 
%         certain intervals depending on the solver being used. 
%         All LINDO API solvers can use it.
%
%         See LMsolvef.m to see how it is set using LSsetLogfunc().
  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com
%
% Last update Jan 09, 2007 (MKA)
%

global CTRLC
fprintf('%s',line,CTRLC);  
% set flag to a positive number to interrupt the solver
if CTRLC==0,
    flag = 0;
else
    flag = 1;
end;    
    