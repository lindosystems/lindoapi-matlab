function   ME = LMcheckError(iEnv,nErr,killOnErr)
% LMCHECKERROR: Checks the error code returned by a LINDO API
% function. Optionally, kills the underlying environment.
% 
% Usage:  LMcheckError(iEnv,nErr,killOnErr)
%
 
% Copyright (c) 2006
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Last update Jan 09, 2007 (MKA)
%

global MY_LICENSE_FILE
lindo;
if nargin <3,   
   killOnErr = 0; 
end;
ME=[];
if nErr ~= LSERR_NO_ERROR,    
   [szMsg,terr] = mxlindo('LSgetErrorMessage',iEnv,nErr);   
   szErr=sprintf('LINDO Error (%d):',nErr);
   if (terr == LSERR_NO_ERROR),
      fprintf('%s %s\n',szErr,szMsg);
   else
      fprintf('LSgetErrorMessage returned %d\n',terr);
   end;
   if (killOnErr)
      [nErr]=mxlindo('LSdeleteEnv',iEnv);
   end;
   return; 
end;

