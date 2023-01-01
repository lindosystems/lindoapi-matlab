function [mipsol,nErr] = lm_stat_mipsol(iModel,logLevel)
% lm_stat_mipsol: Get and optionally write MIP solution stats for specified model.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage lm_stat_mipsol(iModel,logLevel)
lindo;
if nargin<2,
    logLevel=0;
end 
mipsol={};
% Get MIP statistics   
[mipsol.mipObj,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_OBJ);          
[mipsol.nStatus, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_STATUS);
[mipsol.BestBnd, nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_BESTBOUND);
[mipsol.pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_PFEAS);
[mipsol.intfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_INTPFEAS );
[mipsol.siter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_SIM_ITER);
[mipsol.biter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_BAR_ITER);
[mipsol.niter, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_NLP_ITER);
[mipsol.etime, nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_TOT_TIME);
[mipsol.nLPs, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LPCOUNT);
[mipsol.nBranch, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_BRANCHCOUNT);
[mipsol.nActiveN, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_ACTIVENODES);
[mipsol.n_cons_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDCONS);
[mipsol.n_vars_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDVARS);
[mipsol.nonzeros_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDNONZ);
[mipsol.n_int_red, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_RDINT);
[mipsol.n_cut_contra, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_CONTRA_CUTS);
[mipsol.n_cut_obj, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_OBJ_CUT); 
[mipsol.n_cut_gub, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GUB_COVER_CUTS);
[mipsol.n_cut_lift, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LIFT_CUTS);
[mipsol.n_cut_flow, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_FLOW_COVER_CUTS);
[mipsol.n_cut_gomory, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GOMORY_CUTS);
[mipsol.n_cut_gcd, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_GCD_CUTS);
[mipsol.n_cut_clique, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_CLIQUE_CUTS);
[mipsol.n_cut_disagg, nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_DISAGG_CUTS);     
[mipsol.n_cut_planloc,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_PLAN_LOC_CUTS);
[mipsol.n_cut_latice,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_LATTICE_CUTS);
[mipsol.n_cut_coef,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_COEF_REDC_CUTS);
[mipsol.absgap,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_ABSGAP);
[mipsol.relgap,nErr]=mxlindo('LSgetInfo',iModel,LS_DINFO_MIP_RELGAP);
[mipsol.newipsol,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_MIP_NEWIPSOL);
nStatus = mipsol.nStatus;

if logLevel>0,
  if nStatus~=LS_STATUS_BASIC_OPTIMAL & nStatus~=LS_STATUS_OPTIMAL, 
     fprintf('\n\n No optimal solution was found. (status = %d)\n', nStatus);          
  else
     fprintf('\n\n Optimal solution is found. (status = %d)\n\n',nStatus);       
  end
  if logLevel>1,
     fprintf(' Objective value    : %25.12f \n',pobj);    
     fprintf(' MIP gap            : %25.12e \n',abs(abs(BestBnd)-abs(pobj))/(1+abs(pobj)));   
     fprintf(' Prim infeas        : %25.12e \n',pfeas);    
     fprintf(' Int. infeas        : %25.12e \n',intfeas);    
     fprintf(' Simplex iters      : %25d \n',siter);        
     fprintf(' Barrier iters      : %25d \n',biter);            
     fprintf(' Time               : %25.12f\n',etime);       
  end;      
end; 
