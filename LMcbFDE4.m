function [val,nerr] = LMcbFDE4(cbData,nRow,x,njdiff,dXjbase,reserved)
% LMcbFDE4: Callback function to compute functional values for the 
%  double exponential smoothing model. The parameter p is reserved
%  to extend the callback function to support Winter's seasonal model.         
%
%  f = @sum (i>p) ||(E(i-1)+L(i-1)) - Y(i) ||^2
%
%  where,
%
%    F(t+i) = E(t) + i * L(t)
%    E(i)   = w*Y(i)          + (1-w)*(E(i-1)+L(i-1));
%    L(i)   = v*(E(i)-E(i-1)) + (1-v)*L(i-1);
%
%    given E(1),...,E(p) and L(1),...,L(p) with p>=1
%



% Remarks:
% 1) Use LSsetFuncalc() to set as the callback function.
%
% Copyright (c) 2001-2007
%
% LINDO SYstems, Inc.            312.988.7422
% 1415 North DaYton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com
%
% Last update Jan 09, 2007 (MKA)

global E L Y

w = x(1);
v = x(2);
u = x(3);

% number of seasons in a cycle. 
p = 1;


% note, initial values are also variable 
for i=1:p; 
   E(i) = x(3+i) ;
end;

for i=1:p,
   L(i) = x(3+p+i);
end;


 %compute objective functions value
 if (nRow == -1),
     for i=p+1:length(Y),
         E(i) = w*Y(i) + (1-w)*(E(i-1)+L(i-1));
     end;
     
     for i=p+1:length(Y),
         L(i) = v*(E(i)-E(i-1)) + (1-v)*L(i-1);
     end;

     val = 0;
     
     for i=2:length(Y),
         val = val + (E(i-1)+L(i-1) - Y(i))^2;
     end;
     val = val;                  
 end;
  
 % compute constaint 0's functional value 
 if (nRow==0),
    val = w + v + u - 3;
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
