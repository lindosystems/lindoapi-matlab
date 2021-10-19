function [val,nerr] = LMcbFDE3(cbData,nRow,x,njdiff,dXjbase,reserved)
% LMcbFDE3: Callback function to compute functional values for the following model.
%
%             maximize  f(x) =  x*y*sin(x)*cos(1.5*y) 
%             subject to
%                               L <=   x  <=  U;
%                               L <=   y  <=  U;

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
    val = X*Y*sin(X)*cos(1.5*Y);
 end;
 
 %compute constaint 0's functional value 
 if (nRow==0),
    val = X - 10;
 end;
 
 % compute constaint 1's functional value 
 if (nRow==1),
    val = Y - 10;
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
