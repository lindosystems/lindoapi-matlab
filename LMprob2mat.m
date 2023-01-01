function [model] = LMprob2mat(LSprob,LSopts)
% LMPROB2MAT: Convert LSprob object to a structure compatible with
% 'linprog' and 'LSlinprog'
%
% Usage:  [model] = LMprob2mat(LSprob,LSopts)
%
% Copyright (c) 2001-2022
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%

% Last update Jan 07, 2022 (MKA)
%
global MY_LICENSE_FILE
lindo;
if nargin<1
    help LMprob2mat
    return;
end
if ( ~isstruct(LSprob) ),
   message = 'The input to LMsolvem should be either a structure with valid fields or consist of at least three arguments.';
   warning(message);
   return; 
end

if ( ~all(isfield(LSprob, {'c','A','b'})) )
  message = 'The structure input to LMlinprog should contain at least three fields. "c", "A" and "b".';
  warning(message);
  return; 
end  
[m,n] = size(LSprob.A);

% Assumed Ax = b
if ~isfield(LSprob,'csense'),
    LSprob.csense=repmat('E',1,m); 
end;

if ~isfield(LSprob,'vtype'),
    LSprob.vtype=repmat('C',1,n); 
end;

model={};
idxLE = find(LSprob.csense=='L');
idxGE = find(LSprob.csense=='G');
idxEQ = find(LSprob.csense=='E');
idxINT = find(LSprob.vtype~='C');
Ainq = LSprob.A(idxLE,:);
binq = LSprob.b(idxLE);
Ainq = [Ainq; -LSprob.A(idxGE,:)];
binq = [binq; -LSprob.b(idxGE)];
Aeq = LSprob.A(idxEQ,:);
beq = LSprob.b(idxEQ);
model.f = LSprob.c;
model.Aineq = Ainq;
model.Aeq = Aeq;
model.bineq = binq;
model.beq = beq;
model.lb = LSprob.lb;
model.ub = LSprob.ub;
model.x0 = LSprob.x;    
model.intcon = idxINT;

if isempty(idxINT),
    model.solver = 'linprog';
    model.options = LMlinprog('defaults');
else
    model.solver = 'intlinprog';
    model.options = LMintlinprog('defaults');
end

clear idxLE idxGE idxEQ idxINT;
