%*********************************************************************************
%
% Local MIP driver routine 
%
%
%*********************************************************************************
function [x,y,s,d,pobj,nStatus,nErr] = lm_solve_as_mip(iEnv, iModel, verbose, method)   

   lindo;

   % initialize the output
   x=[];y=[];
   s=[];d=[];
   pobj=[]; nErr=[];
   
   nErr = LSERR_NO_ERROR; 
   nStatus = LS_STATUS_UNKNOWN;
         
   %fprintf('\n%10s %10s %15s %15s %10s %10s %10s\n','stat','iter','best_bnd','mip_obj','#lps','#branches','#nodes');
   % Set LMcbLP.m as the callback function 
       
   %[nErr] = mxlindo('LSsetCallback',iModel,'LMcbMLP','Dummy string');  
   %if nErr ~= LSERR_NO_ERROR, return; end;
   %status = mxlindo('LSsetMIPCallback',iModel,'LMcbMIP','Dummy string');
   if verbose,
      [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');   
      if nErr ~= LSERR_NO_ERROR, return; end;
   end;

          
   tic;
   % Optimize
   nStatus= [];
   [nStatus, nErr]=mxlindo('LSsolveMIP',iModel);   
   t2 = toc;        
   if nErr ~= LSERR_NO_ERROR, return; end;   
   
   % Get solution
   [x,nErr]=mxlindo('LSgetMIPPrimalSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;
  
   [y,nErr]=mxlindo('LSgetMIPDualSolution',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;
  
   [s,nErr]=mxlindo('LSgetMIPSlacks',iModel);
   if nErr ~= LSERR_NO_ERROR, return; end;
  
   [d,nErr]=mxlindo('LSgetMIPReducedCosts',iModel);         
   if nErr ~= LSERR_NO_ERROR, return; end;

   % Get MIP statistics   
   [ pobj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_OBJ);          
   [ nStatus, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_STATUS);
   [ BestBnd, nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_BESTBOUND);
   [ siter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_SIM_ITER);
   [ biter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_BAR_ITER);
   [ niter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_NLP_ITER);
   [ nLPs, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LPCOUNT);
   [ nBranch, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_BRANCHCOUNT);
   [ nActiveN, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_ACTIVENODES);
   [ n_cons_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDCONS);
   [ n_vars_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDVARS);
   [ nonzeros_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDNONZ);
   [ n_int_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDINT);
   [ n_cut_contra, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_CONTRA_CUTS);
   [ n_cut_obj, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_OBJ_CUT); 
   [ n_cut_gub, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GUB_COVER_CUTS);
   [ n_cut_lift, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LIFT_CUTS);
   [ n_cut_flow, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_FLOW_COVER_CUTS);
   [ n_cut_gomory, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GOMORY_CUTS);
   [ n_cut_gcd, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GCD_CUTS);
   [ n_cut_clique, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_CLIQUE_CUTS);
   [ n_cut_disagg, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_DISAGG_CUTS);     
   [ n_cut_planloc,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_PLAN_LOC_CUTS);
   [ n_cut_latice,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LATTICE_CUTS);
   [ n_cut_coef,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_COEF_REDC_CUTS);
   
   if verbose > 1,   
      fprintf('%10s %8s %10s %10s %10s %10s %10s %10s\n','MIPobj','MIPstat',...
         'nBranch','nLPs','nSimIter','nIpmIter','nNlpIter','CPU');
      fprintf('%10.2f %8d %10d %10d %10d %10d %10d %10.2f\n', pobj, nStatus ,...
         nBranch', nLPs ,siter,biter,niter,t2);
   end;
    
return;
