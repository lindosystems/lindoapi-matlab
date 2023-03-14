function err = LMcutbigm(LSprob,LSopts)
if nargin<2,
    LSopts = LMoptions('lindo');
end
LSopts.iDefaultLog=0;
x0 = LSprob.x;
LSprob.x = [];
vtype = LSprob.vtype;
LSprob.vtype=[];
n = length(LSprob.ub);
idx_ub=[];
sav_ub=[];

pass = 0;
while pass<5,
    pass = pass + 1;
    fprintf('\npass %d',pass);    
    [idx_ub, sav_ub] = find_infeas_projection(LSprob, LSopts);
    if ~isempty(idx_ub),
        nfix=length(idx_ub);
        fprintf('\nFixing %d vars to 0..',nfix);
        ak = sparse(1,n);
        ak(idx_ub)=1.0;
        LSprob.A = [LSprob.A; ak];
        LSprob.b = [LSprob.b; 1.0];
        LSprob.csense = [LSprob.csense 'G'];
        fprintf('\nAdded CARD cut..');
        LSprob.ub(idx_ub) = sav_ub;
        fprintf('\nUnfixed %d vars..',nfix);
    else
        fprintf('\nWarning: No vars could be fixed to 0..');
        break;
    end;
end    

if ~isempty(sav_ub),
    LSprob.ub(idx_ub) = sav_ub;
    fprintf('\nWarning: ub_sav is not empty!\n');
end
LSprob.vtype = vtype;
LSopts.saveSol = 1;
LSopts.iDefaultLog=1;
LSopts.XSOLVER=14; 
fprintf('\nFinal optimization\n');
[x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts);

%%
function idx = find_roundable_j(x)
    idx = find(x>1e-6 & x<1e-4);
    
%% 
function [idx_ub, sav_ub] = find_infeas_projection(LSprob, LSopts)
    idx_ub = [];
    sav_ub = [];
    max_pass = 15;
    for i = 1:max_pass,
        [x,y,s,dj,pobj,nStatus,nErr,xsol] = LMsolvem(LSprob,LSopts);        
        idx_tmp = find_roundable_j(x);
        if ~isempty(idx_tmp),
            nfix_tmp=length(idx_tmp);
            fprintf('\n\tFixing %d vars to 0..',nfix_tmp);                        
            ub_tmp = LSprob.ub(idx_tmp);
            LSprob.ub(idx_tmp) = 0;
            %[idx LSprob.lb(idx) LSprob.ub(idx)]
            idx_ub = [idx_ub; idx_tmp];
            sav_ub = [sav_ub; ub_tmp];
        else
            fprintf('\n\tWarning: find_roundable_j() returned an empty list');
            break;
        end;
        if nStatus==3, break, end;        
    end;    
    if i==max_pass+1,
        if ~isempty(sav_ub),
            LSprob.ub(idx_ub) = sav_ub;
        end
        idx_ub=[];
        sav_ub=[];
    end;
    return



