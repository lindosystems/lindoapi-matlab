% LMtestQP: Set up and solve a (quadratic) portfolio model with LINDO API.
%
%          **************************************************************
%          *                Portfolio Selection Problem                 *
%          *                   The Markowitz Model.                     *
%          **************************************************************
%          *                                                            *  
%          *   maximize  z = a*r'*w  - (1-a)w'*Q*w                      *
%          *   subject to                                               *  
%          *                 w(1) +  ...  + w(n)  = 1                   *
%          *                 w(j) >= 0                    j=1..n        *
%          *                                                            *
%          * where                                                      *
%          * a     : risk factor, scalar between 0 and 1                *
%          * r(j)  : return on asset j                                  *
%          * Q(i,j): covariance between the returns of i^th and j^th    *
%          *         assets.                                            *
%          * w(j)  : proportion of total budget invested on asset j     *
%          *                                                            *
%          **************************************************************
% 
%Usage:  LMtestQP
 
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
% Last update Jan 09, 2007 (MKA)

lindo;
clc;
help lmtestqp;

% Specify coefficient matrix
A = [   1     1     1     1];
       
% Specify rhs vector
b = [   1.0000];
      
% Specify returns vector 'r' on assets
c = [    0.3000         0.2000        -0.4000         0.2000];
      
% Specify constraint sense
csense = 'E';

% Specify variable bounds
l = [ 0 0 0 0];
u = [];

% Specifying variable types... 
vtype = 'CCCC';

% Specifying the quadratic portion of the problem data -- see the LINDO API manual for details.
QCrows = [ 0 0 0 0 0 0 0 ];
  
QCvar1 = [ 0 0 0 1 1 2 3 ];
  
QCvar2 = [ 0 1 2 1 2 2 3 ];
  
QCcoef = [ 1.0000    0.6400    0.2700    1.0000    0.1300    1.0000    1.0000  ];
 
% Specify the risk factor
rf = .75;

fprintf('\n Optimization started...\n');

% Solve the problem using the generic QP/LP/MIP/MIQP solver (lmsolvemp.m)
opts={};
opts.osense=LS_MAX;
opts.nMethod=LS_METHOD_BARRIER;
opts.iDefaultLog=1;

LSprob.x = [];
LSprob.c = rf*c;
LSprob.A = A;
LSprob.b = b;
LSprob.lb = l;
LSprob.ub = u;
LSprob.csense = csense;
LSprob.vtype = vtype;
LSprob.QCrows = QCrows-1;
LSprob.QCvar1 = QCvar1;
LSprob.QCvar2 = QCvar2;
LSprob.QCcoef = -2*(1-rf)*QCcoef;

[w,y,s,dj,pobj,solstat,nErr]  = LMsolvem(LSprob,opts);                                

if (solstat == LS_STATUS_OPTIMAL | solstat == LS_STATUS_BASIC_OPTIMAL)
   fprintf('\n Optimal solution found...\n');
   fprintf('\n z    : %f \n',pobj);
   for i=1:4,
      fprintf(' w(%d) : %f\n',i,w(i));
   end;
else
   fprintf(' Optimization failed...\n');
end;
