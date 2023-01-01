function [LSprob] = LMreadmat(matFile,flagExport)
% LMREADMAT: Read an LP in MAT and return the associated data objects 
% in LSprob structure. It optionally exports the model in MPS/LINDO format.
%
% The file contents are assumed to be the following
%    Aineq: [m1 x n double]
%      Aeq: [m2 x n double]
%    bineq: [m1 x 1 double]
%      beq: [m2 x 1 double]
%        f: [1 x n double] or [n x 1 double]
%       lb: [1 x n double] or [n x 1 double] 
%       ub: [1 x n double] or [n x 1 double]
%
% See also LMwritem
lindo;
if nargin<1,
    help LMreadmat;
	return;
end
if nargin<2,
    flagExport=0;
end    
fprintf('Loading MAT file: %s\n',matFile);
MAT = load(matFile);

if ~isstruct(MAT),
	warning('MAT file is not a structure');
	return;
end

if isfield(MAT,'model'),
    MAT = MAT.model;
end    

if ( ~all(isfield(MAT, {'f','Aineq','bineq'})) )
  message = 'The structure input to LMlinprog should contain at least three fields. "f", "Aineq" and "bineq".';
  warning(message);
  return; 
end

if ~issparse(MAT.Aineq),    
    fprintf('Sparsifying data...\n');
    Aq = sparse(MAT.Aineq);
else
    Aq = MAT.Aineq;
end
if ~issparse(MAT.Aeq),
    Aeq = sparse(MAT.Aeq);
else
    Aeq = MAT.Aeq;
end

if ~isfield(MAT,'ub'),
    ub =ones(size(MAT.f))*LS_INFINITY;
else
    ub = MAT.ub;
end
if ~isfield(MAT,'lb'),
    lb =-ones(size(MAT.f))*LS_INFINITY;
else
    lb = MAT.lb;
end

csense_le=repmat('L',1,length(MAT.bineq));
csense_eq=repmat('E',1,length(MAT.beq));

LSprob.c = MAT.f;
LSprob.A = [Aq; Aeq];
LSprob.b = [MAT.bineq; MAT.beq];
LSprob.lb = lb;
LSprob.ub = ub;
LSprob.csense = [csense_le csense_eq];
LSprob.vtype = [];
LSprob.osense = LS_MIN;

clear csense_le csense_eq

if flagExport>0,
    LSopts={};
    LSopts.outFormat = 1;
    mpsFile = strrep(matFile,'.mat','_mat.mps');
    fprintf('Exporting MPS file: %s\n',mpsFile);
    LMwritem(mpsFile,LSprob,LSopts);
end

