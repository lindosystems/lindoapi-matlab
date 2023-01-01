function lm_write_stats(iModel,verbose)
lindo;
%% 
% Get model stats (dimension, variable types etc..)
%%
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
[ni,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_INT);  
[nb,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_BIN);  
[nz,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);  

if verbose,
  fprintf(' \n');           
  fprintf('      Variables  : %12d                 Nonzeroes : %12d\n',n,nz);    
  fprintf('      Constraints: %12d                 Density   : %12g\n',m,nz/m/n);           
end;
return;