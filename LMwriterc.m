function [nErr] = LMwriterc(szInputFile,outFormat)
% LMWRITERC: Export a model in matrix form in MPS or LINDO format using R/C names.
%
% Usage:  [nErr] = LMwriterc(szInputFile,outFormat)

% Copyright (c) 2001-2006 
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    

% Last update Jan 09, 2007 (MKA)
%
global MY_LICENSE_FILE
lindo;
if nargin<2
   outFormat = 0;
end;

outputFile=szInputFile;

[LSprob] = LMreadf(szInputFile);
outputFile = strrep(outputFile,'.mps','rc.mps');
outputFile = strrep(outputFile,'.ltx','rc.ltx');
opts={};
opts.outFormat = outFormat;
[nErr] = LMwritem(outputFile,LSprob,opts);

