function   ME = LMthrowError(iEnv,nErr)
% LMThrowError: Throws a Matlab native exception, wrapping the error code 
% returned by a LINDO API function.  
% 
% Usage:  ME = LMthrowError(iEnv,nErr)
%
 
% Copyright (c) 2010
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Last update Mar 20, 2010 (MKA)
%

global MY_LICENSE_FILE
lindo;
ME=[];
if nargin <2,   
   throw(ME); 
end;

if nErr ~= LSERR_NO_ERROR,    
   [szMsg,terr] = mxlindo('LSgetErrorMessage',iEnv,nErr);
   if (terr == LSERR_NO_ERROR),
       szErr=sprintf('LINDO Error %d:',nErr);
       ME = MException(szErr,szMsg);
   else
       szErr=sprintf('LSgetErrorMessage Error %d:',terr);
       ME = MException(szErr,szMsg);       
   end;
   throw(ME);
end;

return; 

