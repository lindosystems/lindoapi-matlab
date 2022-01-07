function [lpsol,nErr] = lm_stat_lpsol(iModel,logLevel)
% lm_stat_lpsol: Write LP solution stats for specified model.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage lm_stat_lpsol(iModel)

%
% Last update Jan 09, 2007 (MKA)

lindo;
if nargin<2,
    logLevel=0;
end    

lpsol={};  
% get solution stats
[lpsol.etime, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_ELAPSED_TIME);    
[lpsol.siter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_SIM_ITER);        
[lpsol.biter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BAR_ITER);         
[lpsol.niter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NLP_ITER);        
[lpsol.imethod, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_METHOD);         
[lpsol.pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_PINFEAS);
[lpsol.dfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DINFEAS);
[lpsol.pobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
[lpsol.dobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DOBJ);
[lpsol.basstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BASIC_STATUS);
[lpsol.nStatus, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_MODEL_STATUS);
nStatus = lpsol.nStatus;
if logLevel>0,
    if nStatus~=LS_STATUS_BASIC_OPTIMAL && nStatus~=LS_STATUS_OPTIMAL && nStatus~=LS_STATUS_LOCAL_OPTIMAL , 
       fprintf('\nNo optimal solution was found. (status = %d)\n', nStatus);        
    else
        if nStatus==LS_STATUS_LOCAL_OPTIMAL
            fprintf('\nLocal Optimal solution is found. (status = %d)\n\n',nStatus);       
        else
            fprintf('\nOptimal solution is found. (status = %d)\n\n',nStatus);       
        end
        if logLevel>1,
            fprintf(' Prim obj value     : %25.12f \n',pobj);    
            fprintf(' Dual obj value     : %25.12f \n',dobj);
            fprintf(' Primal-Dual gap    : %25.12e \n',abs(abs(dobj)-abs(pobj))/(1+abs(pobj)));   
            fprintf(' Prim infeas        : %25.12e \n',pfeas);    
            fprintf(' Dual infeas        : %25.12e \n',dfeas);    
            fprintf(' Simplex iters      : %25d \n',siter);        
            fprintf(' Barrier iters      : %25d \n',biter);            
            fprintf(' Time               : %25.12f \n',etime);       
        end
    end
end
