%*********************************************************************************
%
% Local LP driver routine 
%
%
%*********************************************************************************
function [x,y,s,d,pobj,nStatus,nErr] = lm_solve_as_lp(iEnv,iModel, verbose, method)

   lindo;

   if (verbose >1 & method==3)
       [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
       if nErr ~= LSERR_NO_ERROR, return; end;
   elseif (verbose>0)
       fprintf('\n%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');              
       % Set LMcbLP.m as the callback function 
       [nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','dummy');   
%       [nErr] = mxlindo('LSsetCallback',iModel,'TLSiterate','Dummy string');          
       if nErr ~= LSERR_NO_ERROR, return; end;
   end;       
    
   % initialize the output
   x=[];y=[];
   s=[];d=[];
   pobj=[]; nErr=[];      
   
   % Optimize model
   [solstat,nErr]=mxlindo('LSoptimize',iModel,method);  
   if nErr ~= LSERR_NO_ERROR, return; end;
   nStatus = solstat;
      
   % Get primal and dual solution
   
   [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;

   [y,nErr]=mxlindo('LSgetDualSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;

   [s,nErr]=mxlindo('LSgetSlacks',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;

   [d,nErr]=mxlindo('LSgetReducedCosts',iModel);   
   if nErr ~= LSERR_NO_ERROR, return; end;

   if solstat==LS_STATUS_BASIC_OPTIMAL,
	   [cstat,rstat,nErr] = mxlindo('LSgetBasis',iModel);
	   if nErr ~= LSERR_NO_ERROR, return; end;
   end;
   
      
   % get solution stats
   [etime, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_ELAPSED_TIME);    
   [siter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_SIM_ITER);        
   [biter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BAR_ITER);         
   [niter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NLP_ITER);        
   [imethod, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_METHOD);         
   [pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_PINFEAS);
   [dfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DINFEAS);
   [pobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
   [dobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DOBJ);
   [basstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BASIC_STATUS);  
   
   if (verbose == 0)
      return;
   end;
      
   if solstat~=LS_STATUS_BASIC_OPTIMAL & solstat~=LS_STATUS_OPTIMAL & solstat~=LS_STATUS_LOCAL_OPTIMAL, 
       fprintf('\n\n No optimal solution was found. (status = %d)\n', solstat); 
       return;
   else, 
       if solstat~=LS_STATUS_BASIC_OPTIMAL & solstat~=LS_STATUS_OPTIMAL
        fprintf('\n\n Local optimal solution is found. (status = %d)\n\n',solstat);       
       else
        fprintf('\n\n Global soptimal solution is found. (status = %d)\n\n',solstat);       
       end
       fprintf(' Prim obj value     : %25.12f \n',pobj);    
       fprintf(' Dual obj value     : %25.12f \n',dobj);    
       fprintf(' Primal-Dual gap    : %25.12e \n',abs(dobj-pobj)/(1+pobj));   
       fprintf(' Prim infeas        : %25.12e \n',pfeas);    
       fprintf(' Dual infeas        : %25.12e \n',dfeas);    
       fprintf(' Simplex iters      : %25d \n',siter);        
       fprintf(' Barrier iters      : %25d \n',biter);            
       fprintf(' Time               : %25.12f \n',etime);       
   end;
  
    
return;

