% LMaddcons
% Read an MPS model, optimize it and then add a set of 
% constraints to reoptimize.
%
% Copyright (c) 2001-2007
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com  
%
% Usage [nErr] = LMaddcons('e:\prob\mps\lp\n1\afiro.mps')



function [nErr] = LMaddcons(mpsfile)
lindo;
global MY_LICENSE_FILE

if nargin<1,
    LINDOAPI_HOME=getenv('LINDOAPI_HOME');
    mpsfile = [LINDOAPI_HOME '/samples/data/testlp.mps'];
end

LMversion;

% Read license key from a license file
[MY_LICENSE_KEY,status] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, return; end;
onCleanup(@() myCleanupFun(iEnv));


%create a model
[iModel,crestatus]=mxlindo('LScreateModel',iEnv);

%read the MPS file into the model
[nErr]=mxlindo('LSreadMPSFile',iModel,mpsfile,0);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr); return; end;

%keep the dimension info in LHS vectors
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


%get the LP data in internal sparse format
[objsen,oshift,c,b,consen,kA,kAcnt,A,iA,l,u,nErr]=mxlindo('LSgetLPData',iModel);

[OptStat,nErr]=mxlindo('LSoptimize',iModel,1);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);

fprintf('Stats for current model.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);

% add copies of the existing columns
fprintf('\nAdding a copy of original constraints (observe number of cons has doubled)...\n\n');
[kAt,At,iAt] = make_At(m,n,kA,A,iA);
[nErr] = mxlindo('LSaddConstraints',iModel,m,consen,[],kAt,At,iAt,b);

[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


[OptStat,nErr]=mxlindo('LSoptimize',iModel,LS_METHOD_FREE);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);

fprintf('Stats for current model.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);

fprintf('\nAdding a single constraint...\n\n');
nCons = 1;
achContypes(1) = 'E';
nt = length(c);
aiArows(1) = 0; 
aiArows(2) = nt;
adAcoef = ones(1,nt);
aiAcols = 0:nt-1;
adB(1) = 1;
[nStatus] = mxlindo('LSaddConstraints', iModel, nCons, achContypes, [], aiArows, adAcoef, aiAcols, adB);
[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[OptStat,nErr]=mxlindo('LSoptimize',iModel,1);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);

fprintf('Stats for current model.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);


%%%%%%%%%%%%%%%%%%%%%%%%%%%% delete a cons
fprintf('\nDeleting constraints...\n\n');
nk = 5
nk1 = 3
mk = nk-nk1
nk2 = nk-1
nCons = mk
aiCons = nk1:nk2
[nStatus] = mxlindo('LSdeleteConstraints',iModel,nCons, aiCons);
nk = nk1;

[n,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_VARS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
[m,nErr]=mxlindo('LSgetInfo',iModel,LS_IINFO_NUM_CONS);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[OptStat,nErr]=mxlindo('LSoptimize',iModel,1);
%stat=mxlindo('LSloadBasis',iModel, cstat,rstat);
[obj,nErr]=mxlindo('LSgetObjective',iModel);
fprintf('Stats for current model.\n');
fprintf('   number of vars = %d \n',n);
fprintf('   number of cons = %d \n',m);
fprintf('   objective val  = %g \n',obj);
[Slacks, nStatus] = mxlindo('LSgetSlacks', iModel);
size(Slacks)


[nErr]=mxlindo('LSdeleteEnv',iEnv);


function [kAt,At,iAt] = make_At(m,n,kA,A,iA)

        kAt=zeros(1,m+1);
        At=zeros(1,length(A));
        iAt=zeros(1,length(iA));
        iwork=zeros(1,m);
        
        for k=0:kA(n)-1,
            row = iA(k+1);
            iwork(row+1) = iwork(row+1) + 1;
        end;
        kAt(0+1) = 0;
        for i=0:m-1,
            kAt(i+2) = kAt(i+1) + iwork(i+1);
            iwork(i+1) = 0;
        end;
        for j=0:n-1,
            for k=kA(j+1):kA(j+2)-1,
                row = iA(k+1);
                addr = kAt(row+1) + iwork(row+1);                
                iwork(row+1) = iwork(row+1) + 1;
                iAt(addr+1) = j;                
                At(addr+1)  = A(k+1);
            end;
        end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 