function err = LMcutbigm(LSprob,LSopts)
if nargin<2,
    LSopts = LMoptions('lindo');
end
x0 = LSprob.x;
LSprob.x = [];
vtype = LSprob.vtype;
LSprob.vtype=[];

[x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob);
idx = find_roundable_j(x);

pass = 0
while 1,
    fprintf('pass %d\n',pass);    
    ub_sav = [];
    if ~isempty(idx),
        ub_sav = LSprob.ub(idx);
        LSprob.ub(idx) = 0;
        %[idx LSprob.lb(idx) LSprob.ub(idx)]
    elseif pass>5,
        break;        
    end
    [xr,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts);
    if nStatus==2,
        pass = pass + 1;
        idx = find_roundable_j(x);
        %xr(idx)        
    elseif nStatus==3,
        ak = sparse(1,length(x));
        ak(idx)=1.0;
        LSprob.A = [LSprob.A; ak];
        LSprob.b = [LSprob.b; 1.0];
        LSprob.csense = [LSprob.csense 'G'];
    end 
    if ~isempty(ub_sav),
        LSprob.ub(idx) = ub_sav;        
    end
    idx = find_roundable_j(xr);
end    

if ~isempty(ub_sav),
    LSprob.ub(idx) = ub_sav;        
end
LSprob.vtype = vtype;
LSopts.saveSol = 1;

[x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts);

%%
function idx = find_roundable_j(x)
    idx = find(x>1e-7 & x<1e-4);
