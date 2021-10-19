function [partial,nerr] = LMcbGE1(cbData,nRow,x,lb,ub,isnewpt,npar,parlist)
% LMcbGE1: Callback function to compute partial derivatives for the following model.
%
%           minimize  f(x,y) =  3*(1-x).^2.*exp(-(x.^2) - (y+1).^2) ... 
%                            - 10*(x/5 - x.^3 - y.^5).*exp(-x.^2-y.^2) ... 
%                            - 1/3*exp(-(x+1).^2 - y.^2);
%           subject to
%                            x^2 + y   <=  6;
%                            x   + y^2 <=  6;

% Remarks:
% 1) Use LSsetGradcalc() to set as the callback function
% 2) See LMtestNLP1.m for demo.
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

% reset partials. note: parlist has zero based indices
for i2=1:npar,
   partial(i2) = 0.0;
end;

%compute objective partials
if (nRow == -1),
    for i2=1:npar,
       if (lb(parlist(i2)+1)~=ub(parlist(i2)+1)),
         if (parlist(i2)==0), 
            partial(i2)= 3*(dxf1(X,Y)*g1(X,Y) + f1(X,Y)*dxg1(X,Y) ) ...
               -  10*(dxf2(X,Y)*g2(X,Y) + f2(X,Y)*dxg2(X,Y) ) ...
               - 1/3*(dxg3(X,Y));  
         elseif(parlist(i2)==1) 
           partial(i2)= 3*(dyf1(X,Y)*g1(X,Y) + f1(X,Y)*dyg1(X,Y) ) ...
              -  10*(dyf2(X,Y)*g2(X,Y) + f2(X,Y)*dyg2(X,Y) ) ...
              - 1/3*(dyg3(X,Y));
        end
     end
  end
end;
 
%compute constaint 0's partials. note: parlist has zero based indices
if (nRow==0),
    for i2=1:npar,
       if (lb(parlist(i2)+1)~=ub(parlist(i2)+1)),
         if (parlist(i2)==0),  
           partial(i2)=2.0*X;
         elseif (parlist(i2)==1) 
           partial(i2)=1;
         end
       end
     end
end;
 
% compute constaint 1's partials. note: parlist has zero based indices
if (nRow==1),
    for i2=1:npar,
       if (lb(parlist(i2)+1)~=ub(parlist(i2)+1)),
         if (parlist(i2)==0),  
           partial(i2)=1;
         elseif (parlist(i2)==1) 
           partial(i2)=2.0*Y;
         end
       end
     end
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



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxilizary functions to compute the partials 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z] = mypow(a,b) 
z = a^b;

function [z] =  g1(X,Y)   
z = ( exp( -mypow(X  ,2)  - mypow(Y+1,2) )  ); 

function [z] =  g2(X,Y)   
z = ( exp( -mypow(X  ,2)  - mypow(Y  ,2) )  ); 

function [z] =  g3(X,Y)   
z = ( exp( -mypow(X+1,2)  - mypow(Y  ,2) )  ); 

function [z] =  f1(X,Y) 
z = (      3*mypow(1-X,2)                 ); 

function [z] =  f2(X,Y) 
z = ( X/5 - mypow(X  ,3)  - mypow(Y  ,5)    ); 

function [z] = dxg1(X,Y)  
z = ( ( exp( -mypow(X  ,2)  - mypow(Y+1,2) )  ) * (-2)*X     ); 

function [z] = dyg1(X,Y)  
z = ( ( exp( -mypow(X  ,2)  - mypow(Y+1,2) )  ) * (-2)*(Y+1) );

function [z] = dxg2(X,Y)  
z = ( ( exp( -mypow(X  ,2)  - mypow(Y  ,2) )  ) * (-2)*X     );

function [z] = dyg2(X,Y)  
z = ( ( exp( -mypow(X  ,2)  - mypow(Y  ,2) )  ) * (-2)*Y     ); 

function [z] = dxg3(X,Y)  
z = ( ( exp( -mypow(X+1,2)  - mypow(Y  ,2) )  ) * (-2)*(X+1) ); 

function [z] = dyg3(X,Y)  
z = ( ( exp( -mypow(X+1,2)  - mypow(Y  ,2) )  ) * (-2)*Y     ); 

function [z] = dxf1(X,Y)  
z = ( 6*(1-X)            ); 

function [z] = dyf1(X,Y)  
z = ( 0                  ); 

function [z] = dxf2(X,Y)  
z = ( 1/5 - 3*mypow(X,2)   ); 

function [z] = dyf2(X,Y)  
z = ( -5*mypow(Y,4)        ); 

