function [n,m,ni,nb,nz,nErr] = lm_stat_model(iModel,logLevel)
% lm_stat_model: Write model statistics for specified model.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Usage:
%       [n,m,ni,nb,nz,nErr] = lm_stat_model(iModel,logLevel)

%
% Last update Jan 09, 2007 (MKA)
lindo;
%% 
% Get model stats (dimension, variable types etc..)
%%
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
[ni,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_INT);  
[nb,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_BIN);  
[nz,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_NONZ);  

if logLevel,
  fprintf(' \n');           
  fprintf('      Variables  : %12d                 Nonzeroes       : %12d\n',n,nz);    
  fprintf('      Constraints: %12d                 Density         : %12g\n',m,nz/m/n);           
  fprintf('      Binary vars: %12d                 Integer Vars:   : %12g\n',nb,ni);           
end;
return;