function nerr = LMtestQuasiRandom(ndim,nruns,nsamp)
% LMtestQuasiRandom
%   Generate quasirandoms in specified dimensions
%   and compare the norms of correlations with and
%   without correlations.
%
% Usage: nerr = LMtestQuasiRandom(ndim,nruns,nsamp)
%
% Copyright (c) 2008
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com 

%
% Last update Apr, 2009 (MKA)
%

if nargin<3,
    nsamp=60;
    if nargin<2,    
        nruns=20;
        if nargin<1,
            ndim=5;
        end;
    end;
end;
p=primes(102293);
rand('seed',0);
seeds=p(floor(rand(nruns,1)*length(p)));
s1=0;s2=0;

T=eye(ndim); % target correlation
T(1,2)=0.5;
T(2,1)=0.5;
     
for i=1:nruns,
    % generate 5 dimensional sample of U(0,1), each sample size of 60 
    [X,Y,nErr]=LMtestSamp('u',[0,1],nsamp,1,seeds(i),ndim,0);
    n1=norm(corr(X));
    n2=norm(corr(Y));
    s1=s1+n1;
    s2=s2+n2;
    fprintf('%5d: ||Corr(X)||=%.5f, ||Corr(Y)||=%.5f (target: %g)\n',i,n1,n2,norm(T));
end;
fprintf('%5s: ||Corr(X)||=%.5f, ||Corr(Y)||=%.5f (target: %g)\n','avr',s1/nruns,s2/nruns,norm(T));
