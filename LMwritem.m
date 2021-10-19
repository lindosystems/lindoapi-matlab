function [nErr] = LMwritem(szOutFile,LSprob,opts)
% LMWRITEM: Export a model in matrix form in MPS or LINDO format.
%
% Usage:  [nErr] =LMwritem(szOutFile,LSprob,opts)
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%

% Last update Jan 09, 2007 (MKA)
%
global MY_LICENSE_FILE
lindo;

if nargin < 3,
    opts={};
    opts.iDefaultLog=1;
    opts.outFormat=0;
    if nargin <2,
       fprintf('Incomplete model data\n');
       return;        
    end;
end    

fixed_obj = 0;   % assumed fixed objective = 0

% if constraint senses are not given, all assumed to be 'E'
if (isempty(LSprob.csense)) 
   for i=1:m, LSprob.csense=[LSprob.csense 'E']; end;
end;

% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

% Declare and create a model 
[imodel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% Load the data 
if (~issparse(LSprob.A)),  LSprob.A = sparse(LSprob.A); end; 
if LSprob.osense == LS_MAX, LSprob.c = -LSprob.c; end;
[nErr]=mxlindo('LSXloadLPData',imodel,LSprob.osense,fixed_obj,LSprob.c,LSprob.b,LSprob.csense,LSprob.A,LSprob.lb,LSprob.ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (~isempty(LSprob.vtype))
[nErr]=mxlindo('LSloadMIPData',imodel,LSprob.vtype);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

if opts.outFormat == 0,
   [nErr]=mxlindo('LSwriteMPSFile',imodel,szOutFile,LS_UNFORMATTED_MPS);
else 
   [nErr]=mxlindo('LSwriteLINDOFile',imodel,szOutFile);
end;
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
 
% Un-hook
[nErr]=mxlindo('LSdeleteModel',imodel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 