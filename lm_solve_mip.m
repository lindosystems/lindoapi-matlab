function [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel, opts)   
% lm_solve_mip: Local MIP driver routine for LINDO API
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage [x,y,s,d,pobj,nStatus,nErr] = lm_solve_mip(iEnv, iModel, iDefaultLog, nMethod)

%
% Last update Jan 09, 2007 (MKA)

   lindo;
         
if nargin < 3, 
    opts={};
    opts.nMethod=LS_METHOD_FREE;
    opts.iDefaultLog=1;
    opts.presolve=1;
    opts.B = [];
    opts.mipduals=0;
end;
if ~isfield(opts,'nMethod'), opts.nMethod=LS_METHOD_FREE; end
if ~isfield(opts,'iDefaultLog'), opts.iDefaultLog=1; end
if ~isfield(opts,'presolve'), opts.presolve=1; end
if ~isfield(opts,'mipduals'), opts.mipduals=0; end

iDefaultLog = opts.iDefaultLog;

   if iDefaultLog==0,
      % Turn-off LP logs when solving a MIP
      [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,0);
      if nErr ~= LSERR_NO_ERROR, return; end;      
   elseif iDefaultLog==-1,
      fprintf('\n%10s %10s %15s %15s %10s %10s %10s\n','Status','Iter','BestBound','MipObj','#LPs','#Branches','#Nodes');
      % Set LMcbLP.m as the callback function        
      if 1,
	   	[nErr] = mxlindo('LSsetCallback',iModel,'LMcbMLP','Dummy string');  
         if nErr ~= LSERR_NO_ERROR, return; end;
      else
	      status = mxlindo('LSsetMIPCallback',iModel,'LMcbMIP','Dummy string');      
         if nErr ~= LSERR_NO_ERROR, return; end;
      end;
   end;

   % initialize the output
   x=[];y=[];
   s=[];d=[];
   pobj=[]; nErr=[];
   
   nErr = LSERR_NO_ERROR; 
   nStatus = LS_STATUS_UNKNOWN;
          
   tic;
   % Optimize
   nStatus= [];
   [nStatus, nErr]=mxlindo('LSsolveMIP',iModel);   
   t2 = toc;        
   if nErr ~= LSERR_NO_ERROR, return; end;   

   % Display solution stats    
   nErr = lm_stat_mipsol(iModel,iDefaultLog);
   if nErr ~= LSERR_NO_ERROR, return; end;   
   
   
   % Get solution
   [x,nErr]=mxlindo('LSgetMIPPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;
  
   if opts.mipduals==1,
       [y,nErr]=mxlindo('LSgetMIPDualSolution',iModel);
       if nErr ~= LSERR_NO_ERROR, return; end;

       [d,nErr]=mxlindo('LSgetMIPReducedCosts',iModel);         
       if nErr ~= LSERR_NO_ERROR, return; end;
   end
  
   [s,nErr]=mxlindo('LSgetMIPSlacks',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;
  

   [ pobj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_OBJ);  
   if nErr ~= LSERR_NO_ERROR, return; end;
    
return;
