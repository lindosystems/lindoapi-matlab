% LMtestQP2: Set up and solve a quadratically constrainted model with LINDO API.
%
%     minimize     f(x) = c' x 
%                         0.5 x' Q x         <= b(1)  
%                                     e'  x  =  b(2)  
%                                 inf >=  x  >= 0


% 
%Usage:  LMtestQP2
 
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
% Last update Jan 09, 2007 (MKA)

lindo;
clc;
help lmtestqp2;

% setup model data
A = [0 0 0 0;
     1 1 1 1 ];
 b = [0.2000 1.0000];
 c = [0.3000 0.2000 -0.4000 0.2000];
 csense = 'LE';
 vtype = 'CCCC';
 l=[]; u=[];
 QCrows =  [0 0 0 0 0 0 0 ];
 QCvars1 = [0 0 0 1 1 2 3 ];
 QCvars2 = [0 1 2 1 2 2 3 ];
 QCCoef = [1.00 0.64 0.27 1.00 0.13 1.00 1.00];
 
 fprintf('\n Optimization started...\n');
% Solve the problem using the generic QP/LP/MIP/MIQP solver (lmsolvemp.m)

opts={};
opts.osense=LS_MIN;
opts.nMethod=LS_METHOD_BARRIER;
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
LSprob.QCcoef = QCcoef;

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