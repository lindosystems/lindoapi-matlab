function [LSprob] = LMreadf(szInputFile,dropMethod,dropCount)
% LMREADF: Read an LP/QP/MIP/MIQP problem in (extended) MPS or LINDO format, 
% and return the associated data objects characterizing the model. The input
% model is assumed to be in the following generic form.
%
%     optimize     f(x) = 0.5 x' Qc x + c' x 
%                         0.5 x' Qi x + A(i,:) x  ?  b(i)   for all i
%                      ub >=  x  >= lb
%                      x(v) is integer or binary
%
%     where,
%     Qc, and Qi are symmetric n by n matrices of constants for all i,
%     c, x and A(i,:) are n-vectors, and "?" is one of the relational 
%     operators "<=", "=", or ">=".
%
% Usage:  [LSprob] = LMreadf(szInputFile)
%
% LSprob.x = x;
% LSprob.c = c;
% LSprob.A = A;
% LSprob.b = b;
% LSprob.lb = lb;
% LSprob.ub = ub;
% LSprob.csense = csense;
% LSprob.vtype = vtype;
% LSprob.QCrows = QCrows;
% LSprob.QCvar1 = QCvar1;
% LSprob.QCvar2 = QCvar2;
% LSprob.QCcoef = QCcoef;
% LSprob.R = R;
%
% Copyright (c) 2020
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com          

%
% Last update Jan 09, 2020 (MKA)
%


global MY_LICENSE_FILE 
lindo;
if nargin<1
    help lmreadf
    return;
end	

if nargin<2, dropMethod=-1; end;
if nargin<3, dropCount=-1; end;
LTF = 0; % Convert to lower triangular form
c = []; A = []; b = [];
lb = []; ub=[]; csense=[];vtype=[];
QCrows=[];QCvar1=[];QCvar2=[];QCcoef=[];
x=[];
% Read license key from a license file
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

% Create a LINDO environment
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
onCleanup(@() myCleanupFun(iEnv));

[iModel,nErr]=mxlindo('LScreateModel',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;


[nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_UNFORMATTED_MPS);
if nErr,
   [nErr]=mxlindo('LSreadMPSFile',iModel,szInputFile,LS_FORMATTED_MPS);
   if nErr,
      [nErr]=mxlindo('LSreadLINDOFile',iModel,szInputFile);
      if nErr,
          [nErr]=mxlindo('LSreadMPIFile',iModel,szInputFile);
          if nErr,
            fprintf('Bad input format or file does not exist.\n');
            return;
          end;         
      end;      
   end;
end;


%fprintf('LSreadXXXFile finished\n');
%[osense,oshift,adC,adB,csense,aiAcols,acAcols,adCoef,aiArows,adL,adU,nErr] = mxlindo('LSgetLPData',iModel);
[osense,oshift,c,b,csense,A,lb,ub,nErr]=mxlindo('LSXgetLPData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
%fprintf('LSXgetLPData finished\n');
[QCrows,QCvar1,QCvar2,QCcoef,nErr]=mxlindo('LSgetQCData',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%keep the dimension info in LHS vectors
[n,m,ni,nb,nz] = lm_stat_model(iModel,1);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[maxrnz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_MAX_RNONZ);
[maxcnz, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_MAX_CNONZ);
[avgrnz, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_AVG_RNONZ);
[avgcnz, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_AVG_CNONZ);
fprintf('\n')
fprintf('row nonz: max:%d, avg:%g\n',maxrnz,avgrnz);
fprintf('col nonz: max:%d, avg:%g\n',maxcnz,avgcnz);
fprintf('\n')
[vtype,nErr]=mxlindo('LSgetVarType',iModel);  
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

LSprob = {};
LSprob.osense = osense;
LSprob.x = x;
LSprob.c = c;
LSprob.A = A;
LSprob.b = b;
LSprob.lb = lb;
LSprob.ub = ub;
LSprob.csense = csense;
LSprob.vtype = vtype;
LSprob.QCrows = QCrows;
LSprob.QCvar1 = QCvar1;
LSprob.QCvar2 = QCvar2;
LSprob.QCcoef = QCcoef;
LSprob.oshift = oshift;

solFile = strrep(szInputFile,'.mps','.sol');
if exist(solFile, 'file') == 2    
    errorcode = mxlindo('LSreadVarStartPoint',iModel,solFile);
    if errorcode==0,    
        [B.cbas,B.rbas,nErr] = mxlindo('LSgetBasis',iModel);
        if nErr==0,
            fprintf('Read initial solution file %s\n',solFile);
            LSprob.B = B;
        end
    end
end
%[nErr]=mxlindo('LSwriteMPSFile',iModel,'temp.mps',1);
if 0,
   fprintf('\n%12s %16s %16s %16s\n','Variable','Lower Bound','Upper Bound','Cost');
   for k=0:n-1,
      [szVarname,nErr] = mxlindo('LSgetVariableNamej',iModel,k);
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
      fprintf('%12s %16.7e %16.7e %16.7e\n',szVarname,lb(k+1),ub(k+1),c(k+1));
   end;
   
   fprintf('\n%12s %16s %8s\n','Constraint','RHS','Sense');
   for k=0:m-1,
      [szConname,nErr] = mxlindo('LSgetConstraintNamei',iModel,k);
      if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;
      fprintf('%12s %16.7e %8s\n',szConname,b(k+1),csense(k+1));
   end;
   
end;

% Nonzero related structure
R = {};
if dropMethod>0,    
    [padCidx,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZCINDEX);
    [padRidx,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZRINDEX);
    [padCrnk,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZCRANK);
    [padRrnk,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZRRANK);
    [padCcnt,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZCCOUNT);
    [padRcnt,nErr] = mxlindo('LSgetNnzData',iModel,LS_IINFO_NZRCOUNT);

    R.rkeep = [1:m];
    R.ckeep = [1:n];
    R.rdrop = [];
    R.cdrop = [];

    R.padCcnt = padCcnt;
    R.padRcnt = padRcnt;
    R.padCidx = padCidx;
    R.padRidx = padRidx;
    R.padCrnk = padCrnk;
    R.padRrnk = padRrnk;
    LSprob.R = R
    

    if dropMethod==1,
        cnt = dropCount; %floor(m*.01/50)+1;
        LSprob.R = myKeepDrop_nzcnt(LSprob,cnt);
    elseif dropMethod==2,
        LSprob.R = myKeepDrop_nzmaxpercol(LSprob,dropCount);
    end
end

% LTF required
if LTF>0,
    [R.panNewColIdx,R.panNewRowIdx,R.panNewColPos,R.panNewRowPos,nErr] = mxlindo('LSfindLtf',iModel);
end    
LSprob.R = R;

% Un-hook
[nErr]=mxlindo('LSdeleteModel',iModel);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

[nErr]=mxlindo('LSdeleteEnv',iEnv);
if nErr ~= LSERR_NO_ERROR, LMcheckError(iEnv,nErr) ; return; end;

%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 

%% 	Mark 'cnt' rows/cols with most nzs from the top
function R = myKeepDrop_nzcnt(LSprob,cnt)
	R = LSprob.R;
	m = length(LSprob.b);
	n = length(LSprob.c);
	for r=1:cnt, % get rows from dense to sparse
		r1 = m-r+1;
		c1 = n-r+1;
		r2 = R.padRidx(r1) + 1;
		c2 = R.padCidx(c1) + 1;
		R.rdrop = [R.rdrop; r2];
		R.cdrop = [R.cdrop; c2];
		rrk = R.padRrnk(r2) + 1;
		crk = R.padCrnk(c2) + 1;
		nzr = R.padRcnt(r2);
		nzc = R.padCcnt(c2);
		%nzr = nnz(A(r2,:));
		fprintf('%d, rnz(%d):%d, rank:%d,    cnz(%d):%d, rank:%d\n',r,r2,nzr,rrk,c2,nzc,crk);
	end
	R.rkeep(R.rdrop)=[];
	R.ckeep(R.cdrop)=[];    


%% Mark rows/cols with nzs>dns 
function R = myKeepDrop_nzmaxpercol(LSprob,nzmax)
	R = LSprob.R;
	m = length(LSprob.b);
	n = length(LSprob.c);
    fprintf('\nMarking rows/cols with %d or more nzs',nzmax);
	for c2=1:n, % get rows from dense to sparse		
		nzc = R.padCcnt(c2);
		if nzc>nzmax,
			R.cdrop = [R.cdrop; c2];
		end				
	end
	for r2=1:m, % get rows from dense to sparse		
		nzr = R.padRcnt(r2);
		if nzr>nzmax,
			R.rdrop = [R.rdrop; r2];
		end				
    end
    fprintf('\nFound %d rows with %d or more nzs',length(R.rdrop),nzmax);
    fprintf('\nFound %d cols with %d or more nzs\n',length(R.cdrop),nzmax);
	R.rkeep(R.rdrop)=[];
	R.ckeep(R.cdrop)=[];	    
