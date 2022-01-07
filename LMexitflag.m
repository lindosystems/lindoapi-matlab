function [exitflag] = LMexitflag(xsol)
% LMexitflag: Convert LINDO API solution status and optimization error code
% to 'exitflag' returned by Matlab's linprog.
%
% Copyright (c) 2001-2021
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% [exitflag] = LMexitflag(xsol)

if nargin<1,
    help LMexitflag;
    return
end 
exitflag = -9999;
if isa(xsol,'struct'),
    if ~isfield(xsol,'optErr') || ~isfield(xsol,'nStatus'),
        warning( 'The structure input to LMexitflag should contain at least two fields. "optErr", "nStatus".');
    end
else
    warning('LMexitflag requires a solution structure as input');
    return;
end    
optErr = xsol.optErr;
nStatus = xsol.nStatus;
    
  
if ( nStatus == LS_STATUS_BASIC_OPTIMAL || nStatus == LS_STATUS_OPTIMAL || nStatus == LS_STATUS_LOCAL_OPTIMAL),
  exitflag = 1;
elseif ( nStatus == LS_STATUS_INFEASIBLE || nStatus == LS_STATUS_LOCAL_INFEASIBLE)
  exitflag = -2;
elseif ( nStatus == LS_STATUS_UNBOUNDED)
  exitflag = -3;        
elseif ( nStatus == LS_STATUS_INFORUNB)
  exitflag = -5;                
elseif ( nStatus == LS_STATUS_NUMERICAL_ERROR)
  exitflag = -4;
elseif ( nStatus == LS_STATUS_FEASIBLE)  
  exitflag = 2;
else
    if optErr==LSERR_ITER_LIMIT || optErr==LSERR_TIME_LIMIT,
        exitflag = 0;
    elseif optErr==LSERR_NUMERIC_INSTABILITY,
        exitflag = -4;
    elseif optErr==LSERR_STEP_TOO_SMALL,
        exitflag = -7;
    else
        warning('Unhandled solution status %d',nStatus);
    end  
end

