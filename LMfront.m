function [pobj] = LMfront(N)
% LMFRONT:  Computes and plots the efficient frontier for N assets based on the 
% minimum variance portfolio model. 
%
% A portfolio is said to be efficient if there is no portfolio having the same 
% standard deviation with a greater expected return and there is no portfolio 
% having the same return with a lesser standard deviation. The efficient frontier 
% is the collection of all efficient portfolios.
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

%
% 
%Usage:  LMFRONT

%There may be multiple portfolios that have the same standard deviation. 
%Modern portfolio theory assumes that for a specified standard deviation, 
%a rational investor would choose the portfolio with the greatest return. 
%Similarly, there may be multiple portfolios that have the same return 
%and modern portfolio theory assumes that, for a specified level of return, 
%a rational investor would choose the portfolio having the lowest standard 
%deviation. A portfolio is said to be efficient if there is no portfolio 
%having the same standard deviation with a greater expected return and there 
%is no portfolio having the same return with a lesser standard deviation. 
%The efficient frontier is the collection of all efficient portfolios
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com        
%
%% Last update Jan 09, 2007 (MKA)
%

verbose = 0;
if nargin <= 0
   N = 100;
end;

RET = [];
STD = [];

R1 = 0.01;
R2 = 0.075;

if N > 100
   R1 = 0.01;
   R2 = 0.21;
end;
   
delta = (R2-R1)/12;

R = R1;
while (R <= R2),
   obj = LMminvar(N,R,0);
   RET = [RET; R];
   STD = [STD; obj];
   R = R + delta;  
end;

plot(STD,RET); 
xlabel('Standard Deviation of Return');
ylabel('Return');

if N == 100
   title('The Efficient Frontier for 100 Assets');
else
   title('The Efficient Frontier for 500 Assets');
end;
   
grid;