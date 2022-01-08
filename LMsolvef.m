function  [x,y,s,dj,rx,rs,pobj,nErr,xsol] = LMsolvef(szInputFile,LSopts)
% LMSOLVEF: Read and solve LP/QP/MIP/MIQP models with LINDO API. 
% The input model is assumed to be in the following generic form. 
% Extended MPS format supports quadratic forms, but LINDO file
% format does not. 
%
%     optimize     f(x) = 0.5 x' Qc x + c' x 
%                         0.5 x' Qi x + A(i,:) x  ?  b(i)   for all i
%                      ub >=  x  >= lb
%                      x(v) is integer or binary
%
%     where,
%     Qc, and Qi are symmetric n by n matrices of constants for all i,
%     c, x and A(i,:) are n-vectors, and "?" is one of the relational 
%     operators "<=", "=", or ">=".
% 
% Usage:  [x,y,s,d,pobj,nErr,xsol] = LMsolvef(szInputFile,LSopts)
% 
% Copyright (c) 2006
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

%
% Last update Jan 09, 2007 (MKA)
%
global CTRLC
global MY_LICENSE_FILE
lindo;

CTRLC=0
if nargin < 2, 
    LSopts={};
end;
LSopts = LMoptions('lindo',LSopts);
LSopts = LMoptions('linprog',LSopts);
LSopts = LMoptions('intlinprog',LSopts);

% initialize the output
x=[];y=[];
s=[];dj=[];
pobj=[]; nErr=[];


%% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

%% Create a LINDO environment and a model
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
cleanupObj=onCleanup(@() myCleanupFun(iEnv));

% Set LSopts as env parameters
if LSopts.setEnvParams,
    [nOk,nFail] = lm_set_options(iEnv, iEnv, LSopts);
end

%% Declare and create model
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%% Open a log channel if required
if (LSopts.iDefaultLog>0)
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
end;
% Set a dummy callback to track progress and serve CTRL-C requests
[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP2','dummy');   
if nErr ~= LSERR_NO_ERROR, return; end;   

%% Read the MPS/LINDO file into the model. 
[nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_UNFORMATTED_MPS);
if (nErr)
   [nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_FORMATTED_MPS);         
   if (nErr)            
      [nErr]=mxlindo('LSreadLINDOFile',iModel,szInputFile);            
      if (nErr)            
         [nErr]=mxlindo('LSreadMPIFile',iModel,szInputFile);
         if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
      end;                        
   end;            
   if (nErr),             
      fprintf('Bad MPS, LINDO or MPI format. Quitting...\n');               
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   end;         
end; 

[n,m,ni,nb,nz] = lm_stat_model(iModel,1);
isMip = ni+nb>0;

% Set LSopts as model parameters
[nOk,nFail] = lm_set_options(iEnv, iModel, LSopts, isMip);


%% Invoke the LP/MIP solvers
if (isMip==0),
   [x,y,s,dj,rx,rs,pobj,nStatus,optErr] = lm_solve_lp(iEnv, iModel, LSopts);  
   [xsol,nErr] = lm_stat_lpsol(iModel);
else     
   [x,y,s,dj,pobj,nStatus,optErr] = lm_solve_mip(iEnv, iModel, LSopts);
   [xsol,nErr] = lm_stat_mipsol(iModel);
end;

% Record termination status and optimization error
xsol.nStatus = nStatus;
xsol.optErr = optErr;
[xsol.errmsg, nErr] = mxlindo('LSgetErrorMessage',iEnv,optErr);
if optErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,optErr); end;


%% Delete the LINDO environment/model
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

return;




%*********************************************************************************
% Simple output generator
%*********************************************************************************
function lm_write_nonz_file(iModel,x,fname)
  
  %keep the dimension info in LHS vectors
  [n, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);
  [m, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);      
  [LPNz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);            
  if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;  

  fid=fopen(fname,'wt');

  fprintf(fid,'Writing the solution (nonzeros only)...\n');
  fprintf(fid,'%20s  %16s\n', 'Variable', 'Activity');
  for j=0:n-1,
    [varname,nErr] = mxlindo('LSgetVariableNamej',iModel,j);
    if abs(x(j+1)) > 1.0e-5,
       fprintf(fid,'%20s  %16g\n', varname,x(j+1));
    end;
  end;   
  fclose(fid);  
return;

    
%%    
function myCleanupFun(iEnv)
    global CTRLC
    CTRLC=1;
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 