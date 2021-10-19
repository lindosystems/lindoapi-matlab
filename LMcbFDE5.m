function [val,nerr] = LMcbFDE5(cbData,nRow,x,njdiff,dXjbase,reserved)
% LMcbFDE5: Callback function to compute functional values for LStestNLP5
%

%
% Copyright (c) 2001-2007
%
% LINDO SYstems, Inc.            312.988.7422
% 1415 North DaYton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com
%
% Last update Jan 09, 2007 (MKA)



 %compute objective functions value
 if (nRow == -1),
    val =  x(3) + x(4) + x(5) + x(6);

 %compute constaints functional values          
 elseif (nRow >= 0  & nRow <= 3), 
    val = x(1) + x(2) + x(nRow+3) - 1;
    
 elseif (nRow==4),
    val = x(1) - x(2)^2;
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
