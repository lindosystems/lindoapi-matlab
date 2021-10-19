function [x,y,s,dj,pobj,nStatus,nErr] = LMsolvem3(A,iA,kA,b,c,csense,lb,ub,vtype,...
                                           QCrows,QCvar1,QCvar2,QCcoef,...
                                           osense,nMethod,iDefaultLog)
% LMSOLVEM: Solve an LP/QP/MIP/MIQP problem with LINDO API. 
% The input model is assumed to be in the following generic form. 
% Function arguments constitute the components of this formulation.
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
% Remark: Differs from LMsolvem  in the way A() matrix is characterized. In this
% version, the so-called three-vector representation is used to characterize A()
% matrix. See the LINDO API manual for an overview of three-vector representation.
% 
% Usage:  [x,y,s,dj,pobj,nStatus,nErr] = LMsolvem3(A,iA,kA,b,c,csense,lb,ub,vtype,...
%                                            QCrows,QCvar1,QCvar2,QCcoef,...
%                                            osense,nMethod,iDefaultLog)  
%
% Copyright (c) 2001-2007
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com      

%
% Last update Jan 09, 2007 (MKA)
%
% 10-20-2002: Code is modified to adopt 2.0 style interface


global MY_LICENSE_FILE
lindo;

x=[];
y=[];
s=[];
dj=[];
pobj=[];
nStatus=[];

m = length(b);
n = length(c);
nz = length(A);

if nargin < 16, iDefaultLog = 0;
   if nargin < 15, nMethod = 2;       
       if nargin < 14, osense = LS_MIN;
       end;
   end;
end;

if nargin < 13 & nargin > 9
   fprintf('Quadratic input is incomplete...\n');      
   return;
end

if nargin < 9, vtype = [];
   if nargin < 8, u =[];
      if nargin < 7, l=[];
         if nargin < 6, csense = [];
         end
      end
   end
end;



% if constraint senses are not given, all assumed to be 'E'
if (isempty(csense)) 
   for i=1:m, csense=[csense 'E']; end;
end;

objconst = 0;  

% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));


%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_TIMLMT,5);
%[nErr]=mxlindo('LSsetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_SCALE,0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_INTTOL,0.0);
%[nErr]=mxlindo('LSsetEnvDouParameter',iEnv,LS_DPARAM_MIP_RELINTTOL,0.0);   



% Declare and create a model 
[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,0.1);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL,0);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_ITRLMT,1000);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE,0);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL,1);  
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);   
[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,iDefaultLog);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_TIMLMT,3);
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_ITRLIM,-1);   
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_NLP_ITRLMT,1000);   
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL,1.0e-10);  
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_BARRIER_PROB_TO_SOLVE,LS_PROB_SOLVE_DUAL);      
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,1);        
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,2.5);      
%[nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,0.01);      
%[nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL,1);




%%
% Open a log channel if required
%%
if (iDefaultLog>0)
   [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
   if nErr ~= LSERR_NO_ERROR, return; end;
end;


% Load LP the data 
[nErr]=mxlindo('LSloadLPData',iModel,m,n,osense,objconst,c,b,csense,nz,kA,[],A,iA,lb,ub);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%check if integers exist
if (isempty(vtype)) 
   for i=1:m, vtype = [vtype 'C']; end; 
end;
nint = length(find(vtype=='I'))+length(find(vtype=='B'));


% Load the MIP data, if any.
if (nint > 0)
   [nErr]=mxlindo('LSloadMIPData',iModel,vtype);
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;

% Load quadratic terms, if any.
if (exist('QCrows') & exist('QCvar1') & exist('QCvar2') & exist('QCcoef'))
   QCnz = length(QCrows);
   if QCnz > 0,   
      [nErr] = mxlindo('LSloadQCData',iModel,QCnz,QCrows,QCvar1,QCvar2,QCcoef);
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
   end;   
end;

opts={}
opts.iDefaultLog = iDefaultLog;
opts.nMethod = nMethod;

if (nint == 0)
   [x,y,s,d,rx,rs,pobj,nStatus,nErr] = lm_solve_lp(iEnv, iModel, opts);    
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
else
   [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel, opts);     
   if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
end;



% Close the interface and terminate
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 