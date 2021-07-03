function nErr = lm_stat_mipsol(iModel,iDefaultLog)
% lm_stat_mipsol: Write LP solution stats for specified model.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage lm_stat_mipsol(iModel)
lindo;

% Get MIP statistics   
   [ pobj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_OBJ);          
   [ nStatus, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_STATUS);
   [ BestBnd, nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_BESTBOUND);
   [ pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_PFEAS);
   [ intfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_INTPFEAS );
   [ siter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_SIM_ITER);
   [ biter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_BAR_ITER);
   [ niter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_NLP_ITER);
   [ etime, nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_TOT_TIME);
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
   
   if iDefaultLog == -1,
      if nStatus~=LS_STATUS_BASIC_OPTIMAL & nStatus~=LS_STATUS_OPTIMAL, 
         fprintf('\n\n No optimal solution was found. (status = %d)\n', nStatus); 
         return;
      else
         fprintf('\n\n Optimal solution is found. (status = %d)\n\n',nStatus);       
         fprintf(' Objective value    : %25.12f \n',pobj);    
         fprintf(' MIP gap            : %25.12e \n',abs(abs(BestBnd)-abs(pobj))/(1+abs(pobj)));   
         fprintf(' Prim infeas        : %25.12e \n',pfeas);    
         fprintf(' Int. infeas        : %25.12e \n',intfeas);    
         fprintf(' Simplex iters      : %25d \n',siter);        
         fprintf(' Barrier iters      : %25d \n',biter);            
         fprintf(' Time               : %25.12f\n',etime);       
      end;      
   end; %iDefaultLog
