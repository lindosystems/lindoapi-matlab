function [pobj] = LMMINVAR(N,R,verbose)
% LMMINVAR: Set up and solve a (quadratic) portfolio model with LINDO API
% based on the Minimum Variance Model. This routine calls a callback 
% function to report solution progress.
%
%          **************************************************************
%          *       Minimum Variance Portfolio Selection Problem         *
%          *                                                            *  
%          *   minimize    z = w'*Q*w                                   *
%          *   subject to                                               *
%          *             @sum(j: r(j)*w(j))  > R                        *
%          *             @sum(j: w(j)     )  = 1                        *
%          *                     w(j)       >= 0        j=1..n          *
%          *                                                            *
%          * where                                                      *
%          * R     : minimum return expected                            *
%          * r(j)  : return on asset j                                  *
%          * Q(i,j): covariance between the returns of i^th and j^th    *
%          *         assets.                                            *
%          * w(j)  : proportion of total budget invested on asset j     *
%          *                                                            *
%          **************************************************************
% 
%Usage:  LMMINVAR

% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
%% Last update Jan 09, 2007 (MKA)
%

global MY_LICENSE_FILE
lindo;

if nargin < 3
   verbose = 1,
end;

if nargin < 2,
   R = 0.05;
end;

if nargin < 1,
   N = 100;
end;


if (verbose > 0)
   clc;
   help lmMINVAR;
end;

if N==100
   load rx100.mat;
else   
   load rx500.mat;
end;

b(2) = R;

if (verbose > 0)
fprintf('\n Press enter to start optimization...\n');
pause;
end;

fprintf('\n Solving min-variance portfolio model for minimum return (R) = %f\n',R);

% Solve the problem using the generic QP/LP/MIP/MIQP solver (lmsolvemp.m)
opts={};
opts.osense=LS_MIN;
opts.nMethod=LS_METHOD_FREE;
opts.iDefaultLog=1;

LSprob.x = [];
LSprob.c = c;
LSprob.A = A;
LSprob.b = b;
LSprob.lb = l;
LSprob.ub = u;
LSprob.csense = csense;
LSprob.vtype = vtype;
LSprob.QCrows = QCrows-1;
LSprob.QCvar1 = QCvar1;
LSprob.QCvar2 = QCvar2;
LSprob.QCcoef = -2*QCcoef;

[w,y,s,dj,pobj,solstat,nErr] = LMsolvem(LSprob,opts);

if (verbose == 0) 
   return;
end;

   
if (solstat == LS_STATUS_BASIC_OPTIMAL | solstat == LS_STATUS_BASIC_OPTIMAL | solstat == LS_STATUS_LOCAL_OPTIMAL)
   fprintf('\n Optimal solution found...\n');
   fprintf('\n   z    : %f \n\n',pobj);
   for i=1:length(w),
      if abs(w(i)) > 1.0e-5, 
         fprintf(' w(%3d) : %f\n',i,w(i));
      end;      
   end;
else
   fprintf(' Optimization failed...\n');
end;


      