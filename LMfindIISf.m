function  [nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = LMfindIISf(szInputFile, iis_meth, iis_norm, iis_level)
% LMfindIISf	: Gateway to LINDO API for debugging an infeasible (LP, MIP, QP, NLP) programs
% 
% Usage:  [nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = LMfindIISf(szInputFile)
% 
% OUTPUT: An IIS charaterized by (nsuf,niis,rows)
%  nsuf_r: number of sufficient rows in the IIS 
%  niis_r: number of rows in the IIS.
%  rows_r: indices of rows in the IIS. 
%  nsuf_c: number of sufficient column bounds in the IIS 
%  niis_c: number of column bounds in the IIS.
%  rows_c: indices of cols in the IIS. (C type indexes)
%  bnds_c: indicates the type of the bounds in the IIS. lower=-1, upper=+1
%  nErr  : error code returned by the routine
% 

% REMARK: 
%  1) rows[1:nsuf_r] are the sufficient rows
%  2) cols[1:nsuf_c] are the sufficient column bounds  
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      
%

% Last update Jan 09, 2007 (MKA)
%
%

lindo;

global MY_LICENSE_FILE 
lindo;

iis_sf = 1;
iis_prnlev = 2;
iis_write = 0;
iis_rcname= 0;

% init output
nsuf_r=[];
niis_r=[];
rows=[];
nsuf_c=[];
niis_c=[];
cols=[];
bnds_c=[];
nErr=0;

if (nargin<4),
   %iis_level = LS_NECESSARY_ROWS + LS_NECESSARY_COLS + LS_SUFFICIENT_ROWS + LS_SUFFICIENT_COLS;
   %iis_level= LS_NECESSARY_ROWS+LS_SUFFICIENT_ROWS;
   %iis_level= LS_NECESSARY_ROWS+LS_NECESSARY_COLS;
   iis_level= LS_NECESSARY_ROWS;             
   if (nargin<3),
      iis_norm= LS_IIS_NORM_FREE;
      if (nargin < 2),
        iis_meth = LS_IIS_DEFAULT;
        if nargin<1,
            LINDOAPI_HOME=getenv('LINDOAPI_HOME');
            szInputFile = [LINDOAPI_HOME '/samples/data/testilp.mps'];            
        end        
      end;      
   end;
end;
tmpName = szInputFile;

if iis_rcname,
   [LSprob] = LMreadf(szInputFile);
   if (isempty(LSprob.A)) return; end;
   [nErr] = LMwritem('rctemp.mps',LSprob);
   szInputFile = 'rctemp.mps';
end;


% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

% Declare and create a model 
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%
% Read the MPS/LINDO file into the model. 
%%

if strfind(szInputFile,'mps'),
    [nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_FORMATTED_MPS);
    if (nErr),
       [nErr]=mxlindo('LSdeleteModel',iModel);  
       [iModel,nErr]=mxlindo('LScreateModel',iEnv);         
       [nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_UNFORMATTED_MPS);
    end
elseif strfind(szInputFile,'ltx'),
    [nErr]=mxlindo('LSreadLINDOFile',iModel,szInputFile);            
elseif strfind(szInputFile,'mpi'),
    [nErr]=mxlindo('LSreadMPIFile',iModel,szInputFile);            
else
    fprintf('Bad MPS, LINDO or MPI format.\n');                         
end;
 
szInputFile = tmpName; 

%%
% Delete the LINDO environment/model on error
%%
if (nErr), 
   [strbuf,nErr2] = mxlindo('LSgetErrorMessage',iEnv,nErr);
   fprintf('Error: %s\n',strbuf);
   [nErr]=mxlindo('LSdeleteEnv',iEnv);   
   return;
end;

%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-7);
%turn the preprocessor off/on
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_PREP,0);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
%compute solution even if unbounded or infeasible
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,1);

% sensitivity filter
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_USE_SFILTER,iis_sf);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% method
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_METHOD,iis_meth);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% print iis_level
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_PRINT_LEVEL,iis_prnlev);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% infeasibility norm 
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_INFEAS_NORM,iis_norm);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_TOPOPT,LS_METHOD_FREE);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_IIS_REOPT,LS_METHOD_FREE);          
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

% set a log function
[nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');

%[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','Dummy string');   

% Solve as LP
[nStatus,nErr]=mxlindo('LSoptimize',iModel,LS_METHOD_FREE);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (nStatus ~= LS_STATUS_INFEASIBLE)
   fprintf('Model is not infeasible (status = %d). Quitting...',nStatus);
   [nErr]=mxlindo('LSdeleteEnv',iEnv);
end;

% locate an IIS if any exists
[nErr] = mxlindo('LSfindIIS',iModel,iis_level);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nsuf_r,niis_r,rows,nsuf_c,niis_c,cols,bnds_c,nErr] = mxlindo('LSgetIIS',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if (iis_write == 1),
    outputFile = szInputFile;
    ptr1 = findstr(outputFile,'.mps');
    ptr2 = findstr(outputFile,'.ltx');
    if ~isempty(ptr1) 
       outputFile (ptr1:length(outputFile ))=[];
       outputFile = [outputFile '-iis.ltx'];
    elseif ~isempty(ptr2) 
       outputFile (ptr2:length(outputFile ))=[];
       outputFile = [outputFile '-iis.ltx'];   
    else
       outputFile = [outputFile '-iis.ltx'];      
    end;

    [nErr]=mxlindo('LSwriteIIS',iModel,outputFile);
end;


% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

fprintf('\n\n');
fprintf('\nIIS size = %d\n\n',niis_r+niis_c);

szInputFile = tmpName;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 