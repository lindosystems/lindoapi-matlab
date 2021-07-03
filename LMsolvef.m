function  [x,y,s,d,rx,rs,pobj,nErr] = LMsolvef(szInputFile,nMethod,iDefaultLog)
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
% Usage:  [x,y,s,d,pobj,nErr] = LMsolvef(szInputFile,nMethod,iDefaultLog)
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
if nargin < 3
   iDefaultLog = 13;
   if nargin < 2
      nMethod = 0;
   end;
end;

% initialize the output
x=[];y=[];
s=[];d=[];
pobj=[]; nErr=[];


%%
% Read license key from a license file
%%
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

%%
% Create a LINDO environment and a model
%%
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
cleanupObj=onCleanup(@() myCleanupFun(iEnv));

%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_TIMLMT,5);
%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_SCALE,0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_INTTOL,0.0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_RELINTTOL,0.0);



[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%
% Open a log channel if required
%%
if (iDefaultLog>0)
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
   %[nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','dummy');   
   %if nErr ~= LSERR_NO_ERROR, return; end;   
end;


%%
% Read the MPS/LINDO file into the model. 
%%
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

%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_ITRLMT,1000);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE,0);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,1);  
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);   
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_TIMLMT,3);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_ITRLIM,-1);   
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_NLP_ITRLMT,1000);   
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_PROB_TO_SOLVE,LS_PROB_SOLVE_DUAL);
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,iDefaultLog);        
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,iDefaultLog);        
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,0.5);      
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,0.01);      

%% 
% Get model stats (dimension, variable types etc..)
%%

[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[ni,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_INT);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nb,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_BIN);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[nz,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

if ~iDefaultLog,
  fprintf(' \n');           
  fprintf('      Variables  : %12d                 Nonzeroes : %12d\n',n,nz);    
  fprintf('      Constraints: %12d                 Density   : %12g\n',m,nz/m/n);
end;


opts={};
opts.nMethod=LS_METHOD_FREE;
opts.iDefaultLog=iDefaultLog;


%%Invoke the LP/MIP solvers
%
if (nb+ni<1)
   [x,y,s,d,rx,rs,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel, opts);  
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
else     
   [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel, iDefaultLog, nMethod);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

if (0),
	basfile=strrep(szInputFile,'.mps','_bas.mps');
	[nErr] = mxlindo ('LSwriteBasis',iModel,basfile,2);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

if 0,
	[nErr] = mxlindo ('LSwriteSolution',iModel,[szInputFile '.sol']);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

% Delete the LINDO environment/model
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