function [LSprob] = LMreadmat(matFile)
% LMREADMAT: Read an LP in MAT format and return the associated data objects 
% in LSprob structure. It optionally exports the model in MPS format.
% See LMwritem.m
%
% The file contents are assumed to be the following
%    aeq: [4863x7068 double]
%     aq: [56544x7068 double]
%    beq: [4863x1 double]
%     bq: [56544x1 double]
%      f: [1x7068 double]
%   L: (1 x n), (n x 1) or (1 x 1)
%   U: (1 x n), (n x 1) or (1 x 1)
lindo;
fprintf('Loading MAT file: %s\n',matFile);
MAT = load(matFile);
MAT
fprintf('Sparsifying data...\n');
[i,j,v] = find(MAT.aq);
[i2,j2,v2] = find(MAT.aeq);
Aq = sparse(i,j,v);
Aeq = sparse(i2,j2,v2);
csense_le=repmat('L',1,length(MAT.bq));
csense_eq=repmat('E',1,length(MAT.beq));
U=ones(size(MAT.f))*LS_INFINITY;
L=-U;


LSprob.c = MAT.f;
LSprob.A = [Aq; Aeq];
LSprob.b = [MAT.bq; MAT.beq];
LSprob.lb = L;
LSprob.ub = U;
LSprob.csense = [csense_le csense_eq];
LSprob.vtype = [];
LSprob.osense = LS_MIN;

if 2>1,
    mpsFile = strrep(matFile,'.mat','.mps');
    fprintf('Exporting MPS file: %s\n',mpsFile);
    LMwritem(mpsFile,LSprob);
end

clear LSprob
[LSprob] = LMreadf(mpsFile);
if 0>1, 
    [x,y,s,dj,pobj,nStatus,nErr,B] = LMsolvem(LSprob);
end    