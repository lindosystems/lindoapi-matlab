function [LSbprob,Xg] = LMgin2bin(LSgprob)
lindo;

LSbprob=[];
if ~isfield(LSgprob,'vtype') || isempty(LSgprob.vtype),
    fprintf('Warning: the input model is continuous\n');
    return
end

bidx2 = find(LSgprob.ub==1 & LSgprob.lb==0);
for k=1:length(bidx2),
    j = bidx2(k);
    if LSgprob.vtype(j)=='I', LSgprob.vtype(j)='B'; end
end    
%bidx = find(LSgprob.vtype=='B');
gidx = find(LSgprob.vtype=='I');
cidx = find(LSgprob.vtype=='C');
if isempty(gidx),
    fprintf('Warning: the input model is a 0-1 integer model\n');
    return
end

A = LSgprob.A;
if 0>1,
    l = LSgprob.lb;
    u = LSgprob.ub;
else
    l = LSgprob.zlb;
    u = LSgprob.zub;    
end
c = LSgprob.c;
vtype = LSgprob.vtype;
G = [];
for k=1:length(gidx),
    j = gidx(k);
    uj = min(u(j),100);
    cj = c(j);
    if uj<LS_INFINITY,        
        nj = ceil(log2(uj));
        aj = A(:,j);
        Aj = [];
        if nj>0,
            for r=1:nj,
                Aj = [Aj aj*2^(r-1)];
                c = [c; cj*2^(r-1)];            
            end;
            A = [A Aj];
            l = [l; zeros(nj,1)];
            G = [G length(u)];
            u = [u; ones(nj,1)];        
            vtype = [vtype repmat('B',1,nj)];
        else
            G = [G length(u)];
        end
    end
end  
G = [G length(u)];
G = G - length(gidx) + 1;
A(:,gidx)=[];
l(gidx)=[];
u(gidx)=[];
c(gidx)=[];
vtype(gidx)=[];
LSbprob.A = A;
LSbprob.lb = l;
LSbprob.ub = u;
LSbprob.c = c;
LSbprob.vtype = vtype;
LSbprob.csense = LSgprob.csense;
LSbprob.b = LSgprob.b;
LSbprob.osense = LSgprob.osense;
LSopts = LMoptions('lindo');
LSopts.numAltOpt = 10;
LSopts.FP_MODE=0;
tsec = cputime;
LMwritem('/tmp/1/bexp_mat.mps',LSbprob);
[x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSbprob,LSopts);
[ndim, nsol ] = size(xsol.Xalt);
tsec = cputime - tsec;
Xg = [];
for j=1:nsol,
    x = xsol.Xalt(:,j);
    xg = zeros(size(LSgprob.c));
    xg(cidx) = x(cidx);
    for k=1:length(gidx),
        j = gidx(k);
        colbeg = G(k);
        colend = G(k+1);
        xb = x(colbeg:colend-1);
        xi = 0;
        for p = 1:length(xb),
            xi = xi + xb(p)*2^(p-1);
        end
        xg(j) = xi;
        %fprintf('x[%d][%d:%d] -> %d\n',j,colbeg,colend-1,xi);
    end
    Xg = [Xg xg];    
end    
fprintf('Elapsed %g secs\n',tsec);
size(Xg)