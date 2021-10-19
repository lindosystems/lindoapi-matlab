%function nErr = lm_stat_lpsol(iModel)
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

%lindo;

  
if nStatus~=LS_STATUS_BASIC_OPTIMAL & nStatus~=LS_STATUS_OPTIMAL & nStatus~=LS_STATUS_LOCAL_OPTIMAL , 
   fprintf('\n\n No optimal solution was found. (status = %d)\n', nStatus); 
   return;
end

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
[nStatus, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_MODEL_STATUS);

if nStatus==LS_STATUS_LOCAL_OPTIMAL
   fprintf('\n\n Local Optimal solution is found. (status = %d)\n\n',nStatus);       
else
   fprintf('\n\n Optimal solution is found. (status = %d)\n\n',nStatus);       
end       
fprintf(' Prim obj value     : %25.12f \n',pobj);    
fprintf(' Dual obj value     : %25.12f \n',dobj);
fprintf(' Primal-Dual gap    : %25.12e \n',abs(abs(dobj)-abs(pobj))/(1+abs(pobj)));   
fprintf(' Prim infeas        : %25.12e \n',pfeas);    
fprintf(' Dual infeas        : %25.12e \n',dfeas);    
fprintf(' Simplex iters      : %25d \n',siter);        
fprintf(' Barrier iters      : %25d \n',biter);            
fprintf(' Time               : %25.12f \n',etime);       

    

