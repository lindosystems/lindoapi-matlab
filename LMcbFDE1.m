function [val,nerr] = LMcbFDE1(cbData,nRow,x,njdiff,dXjbase,reserved)
% LMcbFDE1: Callback function to compute functional values for the following model.
%
%           minimize  f(x,y) =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... 
%                            - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... 
%                            - 1/3*exp(-(x+1).^2 - y.^2);
%           subject to
%                            x^2 + y   <=  6;
%                            x   + y^2 <=  6;  

% Remarks:
% 1) Use LSsetFuncalc() to set as the callback function.
% 2) See LMtestNLP1.m and LStestNLP2.m for demo.
%
% Copyright (c) 2001-2007
%
% LINDO SYstems, Inc.            312.988.7422
% 1415 North DaYton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com
%
% Last update Jan 09, 2007 (MKA)


X = x(1);
Y = x(2);

 %compute objective functions value
 if (nRow == -1),
    val =  3*(1-X)^2*exp(-(X^2) - (Y+1)^2) ... 
          - 10*(X/5 - X^3 - Y^5)*exp(-X^2-Y^2) ... 
          - 1/3*exp(-(X+1)^2 - Y^2);
 end;
 
 %compute constaint 0's functional value 
 if (nRow==0),
    val = X*X + Y - 6.0;
 end;
 
 % compute constaint 1's functional value 
 if (nRow==1),
    val = X + Y*Y - 6.0;    
 end;
% fprintf('x=%f, y=%f, row = %d , val = %f\n',X,Y,nRow,val);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DisplaY to screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fprintf('%10d %15.3e %15.3e %15.3e %15.3e\n',0,val,0,0,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% nerr corresponds to the number of arithmetic errors encountered
%% during computations -- it is the user's responsibility to count & 
%% set this value.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nerr = 0;
