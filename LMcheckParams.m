function   LMcheckParams()
% LMCHECKPARAMS: Display environment and model parameters
% 
% Usage:  LMcheckParams()
%
 
% Copyright (c) 2006
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com    
%
% Last update Jan 09, 2007 (MKA)
%

global MY_LICENSE_FILE
lindo;

%%
% Read license key from a license file
%%
[MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

%%
% Create a LINDO environment and a model
%%
[iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
LMcheckError(iEnv,nErr);
onCleanup(@() myCleanupFun(iEnv));

[Version,BuiltOn] = mxlindo('LSgetVersionInfo');

fprintf('\n*** LINDO API Version %s\n*** DEFAULT VALUES ENVIRONMENT PARAMETERS \n\n',Version);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_CALLBACKFREQ);	fprintf('iEnv.LS_DPARAM_CALLBACKFREQ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_BNDLIM);	fprintf('iEnv.LS_DPARAM_GOP_BNDLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_BOXTOL);	fprintf('iEnv.LS_DPARAM_GOP_BOXTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_DELTATOL);	fprintf('iEnv.LS_DPARAM_GOP_DELTATOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_FLTTOL);	fprintf('iEnv.LS_DPARAM_GOP_FLTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_OPTTOL);	fprintf('iEnv.LS_DPARAM_GOP_OPTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_GOP_WIDTOL);	fprintf('iEnv.LS_DPARAM_GOP_WIDTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_ADDCUTOBJTOL);	fprintf('iEnv.LS_DPARAM_MIP_ADDCUTOBJTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_ADDCUTPER);	fprintf('iEnv.LS_DPARAM_MIP_ADDCUTPER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_ADDCUTPER_TREE);	fprintf('iEnv.LS_DPARAM_MIP_ADDCUTPER_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_CUTOFFOBJ);	fprintf('iEnv.LS_DPARAM_MIP_CUTOFFOBJ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_DELTA);	fprintf('iEnv.LS_DPARAM_MIP_DELTA=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_INTTOL);	fprintf('iEnv.LS_DPARAM_MIP_INTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_LBIGM);	fprintf('iEnv.LS_DPARAM_MIP_LBIGM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_OPTTOL);	fprintf('iEnv.LS_DPARAM_MIP_OPTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_PEROPTTOL);	fprintf('iEnv.LS_DPARAM_MIP_PEROPTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_REDCOSTFIX_CUTOFF);	fprintf('iEnv.LS_DPARAM_MIP_REDCOSTFIX_CUTOFF=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_RELINTTOL);	fprintf('iEnv.LS_DPARAM_MIP_RELINTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_NLP_FEASTOL);	fprintf('iEnv.LS_DPARAM_NLP_FEASTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_NLP_PSTEP_FINITEDIFF);	fprintf('iEnv.LS_DPARAM_NLP_PSTEP_FINITEDIFF=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_NLP_REDGTOL);	fprintf('iEnv.LS_DPARAM_NLP_REDGTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_OBJPRINTMUL);	fprintf('iEnv.LS_DPARAM_OBJPRINTMUL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_SOLVER_CUTOFFVAL);	fprintf('iEnv.LS_DPARAM_SOLVER_CUTOFFVAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_SOLVER_FEASTOL);	fprintf('iEnv.LS_DPARAM_SOLVER_FEASTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_SOLVER_OPTTOL);	fprintf('iEnv.LS_DPARAM_SOLVER_OPTTOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_ALLOW_CNTRLBREAK);	fprintf('iEnv.LS_IPARAM_ALLOW_CNTRLBREAK=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_PROB_TO_SOLVE);	fprintf('iEnv.LS_IPARAM_BARRIER_PROB_TO_SOLVE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_BARRIER_SOLVER);	fprintf('iEnv.LS_IPARAM_BARRIER_SOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_CHECK_FOR_ERRORS);	fprintf('iEnv.LS_IPARAM_CHECK_FOR_ERRORS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_DECOMPOSITION_TYPE);	fprintf('iEnv.LS_IPARAM_DECOMPOSITION_TYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_ALGREFORMMD);	fprintf('iEnv.LS_IPARAM_GOP_ALGREFORMMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_BBSRCHMD);	fprintf('iEnv.LS_IPARAM_GOP_BBSRCHMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_BRANCHMD);	fprintf('iEnv.LS_IPARAM_GOP_BRANCHMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_DECOMPPTMD);	fprintf('iEnv.LS_IPARAM_GOP_DECOMPPTMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_MAXWIDMD);	fprintf('iEnv.LS_IPARAM_GOP_MAXWIDMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_OPTCHKMD);	fprintf('iEnv.LS_IPARAM_GOP_OPTCHKMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_POSTLEVEL);	fprintf('iEnv.LS_IPARAM_GOP_POSTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_PRELEVEL);	fprintf('iEnv.LS_IPARAM_GOP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_PRINTLEVEL);	fprintf('iEnv.LS_IPARAM_GOP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_RELBRNDMD);	fprintf('iEnv.LS_IPARAM_GOP_RELBRNDMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_TIMLIM);	fprintf('iEnv.LS_IPARAM_GOP_TIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_GOP_USEBNDLIM);	fprintf('iEnv.LS_IPARAM_GOP_USEBNDLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_IIS_ANALYZE_LEVEL);	fprintf('iEnv.LS_IPARAM_IIS_ANALYZE_LEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_IUS_ANALYZE_LEVEL);	fprintf('iEnv.LS_IPARAM_IUS_ANALYZE_LEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_BARRIER);	fprintf('iEnv.LS_IPARAM_LIC_BARRIER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_CONSTRAINTS);	fprintf('iEnv.LS_IPARAM_LIC_CONSTRAINTS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_DAYSTOEXP);	fprintf('iEnv.LS_IPARAM_LIC_DAYSTOEXP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_DAYSTOTRIALEXP);	fprintf('iEnv.LS_IPARAM_LIC_DAYSTOTRIALEXP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_EDUCATIONAL);	fprintf('iEnv.LS_IPARAM_LIC_EDUCATIONAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_GLOBAL);	fprintf('iEnv.LS_IPARAM_LIC_GLOBAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_GOP_INTEGERS);	fprintf('iEnv.LS_IPARAM_LIC_GOP_INTEGERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_GOP_NONLINEARVARS);	fprintf('iEnv.LS_IPARAM_LIC_GOP_NONLINEARVARS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_INTEGERS);	fprintf('iEnv.LS_IPARAM_LIC_INTEGERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_NONLINEAR);	fprintf('iEnv.LS_IPARAM_LIC_NONLINEAR=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_NONLINEARVARS);	fprintf('iEnv.LS_IPARAM_LIC_NONLINEARVARS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_NUMUSERS);	fprintf('iEnv.LS_IPARAM_LIC_NUMUSERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_RUNTIME);	fprintf('iEnv.LS_IPARAM_LIC_RUNTIME=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LIC_VARIABLES);	fprintf('iEnv.LS_IPARAM_LIC_VARIABLES=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LP_PRINTLEVEL);	fprintf('iEnv.LS_IPARAM_LP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_AGGCUTLIM_TOP);	fprintf('iEnv.LS_IPARAM_MIP_AGGCUTLIM_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_AGGCUTLIM_TREE);	fprintf('iEnv.LS_IPARAM_MIP_AGGCUTLIM_TREE=%d, nErr=%d\n',par,nErr);
%[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_ANODES_SWITCH_DF);	fprintf('iEnv.LS_IPARAM_MIP_ANODES_SWITCH_DF=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_AOPTTIMLIM);	fprintf('iEnv.LS_IPARAM_MIP_AOPTTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_BRANCH_LIMIT);	fprintf('iEnv.LS_IPARAM_MIP_BRANCH_LIMIT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_BRANCH_PRIO);	fprintf('iEnv.LS_IPARAM_MIP_BRANCH_PRIO=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_BRANCHDIR);	fprintf('iEnv.LS_IPARAM_MIP_BRANCHDIR=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_BRANCHRULE);	fprintf('iEnv.LS_IPARAM_MIP_BRANCHRULE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_CUTDEPTH);	fprintf('iEnv.LS_IPARAM_MIP_CUTDEPTH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_CUTFREQ);	fprintf('iEnv.LS_IPARAM_MIP_CUTFREQ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_CUTLEVEL_TOP);	fprintf('iEnv.LS_IPARAM_MIP_CUTLEVEL_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_CUTLEVEL_TREE);	fprintf('iEnv.LS_IPARAM_MIP_CUTLEVEL_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_CUTTIMLIM);	fprintf('iEnv.LS_IPARAM_MIP_CUTTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_DUAL_SOLUTION);	fprintf('iEnv.LS_IPARAM_MIP_DUAL_SOLUTION=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_HEULEVEL);	fprintf('iEnv.LS_IPARAM_MIP_HEULEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_HEUMINTIMLIM);	fprintf('iEnv.LS_IPARAM_MIP_HEUMINTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvDouParameter',iEnv,LS_DPARAM_MIP_ITRLIM);	fprintf('iEnv.LS_DPARAM_MIP_ITRLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_KEEPINMEM);	fprintf('iEnv.LS_IPARAM_MIP_KEEPINMEM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_LSOLTIMLIM);	fprintf('iEnv.LS_IPARAM_MIP_LSOLTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_MAXCUTPASS_TOP);	fprintf('iEnv.LS_IPARAM_MIP_MAXCUTPASS_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_MAXCUTPASS_TREE);	fprintf('iEnv.LS_IPARAM_MIP_MAXCUTPASS_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_MAXNONIMP_CUTPASS);	fprintf('iEnv.LS_IPARAM_MIP_MAXNONIMP_CUTPASS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_NODESELRULE);	fprintf('iEnv.LS_IPARAM_MIP_NODESELRULE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_PRELEVEL);	fprintf('iEnv.LS_IPARAM_MIP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_PREPRINTLEVEL);	fprintf('iEnv.LS_IPARAM_MIP_PREPRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_PRINTLEVEL);	fprintf('iEnv.LS_IPARAM_MIP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_REOPT);	fprintf('iEnv.LS_IPARAM_MIP_REOPT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_SCALING_BOUND);	fprintf('iEnv.LS_IPARAM_MIP_SCALING_BOUND=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_SOLVERTYPE);	fprintf('iEnv.LS_IPARAM_MIP_SOLVERTYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_STRONGBRANCHLEVEL);	fprintf('iEnv.LS_IPARAM_MIP_STRONGBRANCHLEVEL=%d, nErr=%d\n',par,nErr);
%[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_SWITCHFAC_SIM_IPM);	fprintf('iEnv.LS_IPARAM_MIP_SWITCHFAC_SIM_IPM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_TIMLIM);	fprintf('iEnv.LS_IPARAM_MIP_TIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_TOPOPT);	fprintf('iEnv.LS_IPARAM_MIP_TOPOPT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_TREEREORDERLEVEL);	fprintf('iEnv.LS_IPARAM_MIP_TREEREORDERLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MIP_USECUTOFFOBJ);	fprintf('iEnv.LS_IPARAM_MIP_USECUTOFFOBJ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_MPS_OBJ_WRITESTYLE);	fprintf('iEnv.LS_IPARAM_MPS_OBJ_WRITESTYLE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_AUTODERIV);	fprintf('iEnv.LS_IPARAM_NLP_AUTODERIV=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_CONVEX);	fprintf('iEnv.LS_IPARAM_NLP_CONVEX=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_CONVEXRELAX);	fprintf('iEnv.LS_IPARAM_NLP_CONVEXRELAX=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_CR_ALG_REFORM);	fprintf('iEnv.LS_IPARAM_NLP_CR_ALG_REFORM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_DERIV_DIFFTYPE);	fprintf('iEnv.LS_IPARAM_NLP_DERIV_DIFFTYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_ITRLMT);	fprintf('iEnv.LS_IPARAM_NLP_ITRLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_LINEARITY);	fprintf('iEnv.LS_IPARAM_NLP_LINEARITY=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_LINEARZ);	fprintf('iEnv.LS_IPARAM_NLP_LINEARZ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_MAXLOCALSEARCH);	fprintf('iEnv.LS_IPARAM_NLP_MAXLOCALSEARCH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_PRELEVEL);	fprintf('iEnv.LS_IPARAM_NLP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_PRINTLEVEL);	fprintf('iEnv.LS_IPARAM_NLP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_QUADCHK);	fprintf('iEnv.LS_IPARAM_NLP_QUADCHK=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_SOLVE_AS_LP);	fprintf('iEnv.LS_IPARAM_NLP_SOLVE_AS_LP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_SOLVER);	fprintf('iEnv.LS_IPARAM_NLP_SOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_STARTPOINT);	fprintf('iEnv.LS_IPARAM_NLP_STARTPOINT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_SUBSOLVER);	fprintf('iEnv.LS_IPARAM_NLP_SUBSOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_USE_CRASH);	fprintf('iEnv.LS_IPARAM_NLP_USE_CRASH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_USE_SELCONEVAL);	fprintf('iEnv.LS_IPARAM_NLP_USE_SELCONEVAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_USE_SLP);	fprintf('iEnv.LS_IPARAM_NLP_USE_SLP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_NLP_USE_STEEPEDGE);	fprintf('iEnv.LS_IPARAM_NLP_USE_STEEPEDGE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_OBJSENSE);	fprintf('iEnv.LS_IPARAM_OBJSENSE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_IPMSOL);	fprintf('iEnv.LS_IPARAM_SOLVER_IPMSOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_IUSOL);	fprintf('iEnv.LS_IPARAM_SOLVER_IUSOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_RESTART);	fprintf('iEnv.LS_IPARAM_SOLVER_RESTART=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_TIMLMT);	fprintf('iEnv.LS_IPARAM_SOLVER_TIMLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SOLVER_USECUTOFFVAL);	fprintf('iEnv.LS_IPARAM_SOLVER_USECUTOFFVAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_DPRICING);	fprintf('iEnv.LS_IPARAM_SPLEX_DPRICING=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LP_ITRLMT);	fprintf('iEnv.LS_IPARAM_LP_ITRLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_PPRICING);	fprintf('iEnv.LS_IPARAM_SPLEX_PPRICING=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_LP_PRELEVEL);	fprintf('iEnv.LS_IPARAM_LP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_REFACFRQ);	fprintf('iEnv.LS_IPARAM_SPLEX_REFACFRQ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_SPLEX_SCALE);	fprintf('iEnv.LS_IPARAM_SPLEX_SCALE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetEnvIntParameter',iEnv,LS_IPARAM_VER_NUMBER);	fprintf('iEnv.LS_IPARAM_VER_NUMBER=%d, nErr=%d\n',par,nErr);

[iModel,nErr]=mxlindo('LScreateModel',iEnv);
LMcheckError(iEnv,nErr);

fprintf('\n*** LINDO API Version %s\n*** DEFAULT VALUES MODEL PARAMETERS \n\n',Version);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ);	fprintf('iModel.LS_DPARAM_CALLBACKFREQ=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_BNDLIM);	fprintf('iModel.LS_DPARAM_GOP_BNDLIM=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_BOXTOL);	fprintf('iModel.LS_DPARAM_GOP_BOXTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_DELTATOL);	fprintf('iModel.LS_DPARAM_GOP_DELTATOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_FLTTOL);	fprintf('iModel.LS_DPARAM_GOP_FLTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_OPTTOL);	fprintf('iModel.LS_DPARAM_GOP_OPTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_GOP_WIDTOL);	fprintf('iModel.LS_DPARAM_GOP_WIDTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_ADDCUTOBJTOL);	fprintf('iModel.LS_DPARAM_MIP_ADDCUTOBJTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_ADDCUTPER);	fprintf('iModel.LS_DPARAM_MIP_ADDCUTPER=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_ADDCUTPER_TREE);	fprintf('iModel.LS_DPARAM_MIP_ADDCUTPER_TREE=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_CUTOFFOBJ);	fprintf('iModel.LS_DPARAM_MIP_CUTOFFOBJ=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_DELTA);	fprintf('iModel.LS_DPARAM_MIP_DELTA=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_INTTOL);	fprintf('iModel.LS_DPARAM_MIP_INTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_LBIGM);	fprintf('iModel.LS_DPARAM_MIP_LBIGM=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_OPTTOL);	fprintf('iModel.LS_DPARAM_MIP_OPTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_PEROPTTOL);	fprintf('iModel.LS_DPARAM_MIP_PEROPTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_REDCOSTFIX_CUTOFF);	fprintf('iModel.LS_DPARAM_MIP_REDCOSTFIX_CUTOFF=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_RELINTTOL);	fprintf('iModel.LS_DPARAM_MIP_RELINTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_NLP_FEASTOL);	fprintf('iModel.LS_DPARAM_NLP_FEASTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_NLP_PSTEP_FINITEDIFF);	fprintf('iModel.LS_DPARAM_NLP_PSTEP_FINITEDIFF=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_NLP_REDGTOL);	fprintf('iModel.LS_DPARAM_NLP_REDGTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_OBJPRINTMUL);	fprintf('iModel.LS_DPARAM_OBJPRINTMUL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_SOLVER_CUTOFFVAL);	fprintf('iModel.LS_DPARAM_SOLVER_CUTOFFVAL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_SOLVER_FEASTOL);	fprintf('iModel.LS_DPARAM_SOLVER_FEASTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_SOLVER_OPTTOL);	fprintf('iModel.LS_DPARAM_SOLVER_OPTTOL=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_ALLOW_CNTRLBREAK);	fprintf('iModel.LS_IPARAM_ALLOW_CNTRLBREAK=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_PROB_TO_SOLVE);	fprintf('iModel.LS_IPARAM_PROB_TO_SOLVE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_BARRIER_SOLVER);	fprintf('iModel.LS_IPARAM_BARRIER_SOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_CHECK_FOR_ERRORS);	fprintf('iModel.LS_IPARAM_CHECK_FOR_ERRORS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_DECOMPOSITION_TYPE);	fprintf('iModel.LS_IPARAM_DECOMPOSITION_TYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_ALGREFORMMD);	fprintf('iModel.LS_IPARAM_GOP_ALGREFORMMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_BBSRCHMD);	fprintf('iModel.LS_IPARAM_GOP_BBSRCHMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_BRANCHMD);	fprintf('iModel.LS_IPARAM_GOP_BRANCHMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_DECOMPPTMD);	fprintf('iModel.LS_IPARAM_GOP_DECOMPPTMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_MAXWIDMD);	fprintf('iModel.LS_IPARAM_GOP_MAXWIDMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_OPTCHKMD);	fprintf('iModel.LS_IPARAM_GOP_OPTCHKMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_POSTLEVEL);	fprintf('iModel.LS_IPARAM_GOP_POSTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_PRELEVEL);	fprintf('iModel.LS_IPARAM_GOP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_PRINTLEVEL);	fprintf('iModel.LS_IPARAM_GOP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_RELBRNDMD);	fprintf('iModel.LS_IPARAM_GOP_RELBRNDMD=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_TIMLIM);	fprintf('iModel.LS_IPARAM_GOP_TIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_GOP_USEBNDLIM);	fprintf('iModel.LS_IPARAM_GOP_USEBNDLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_IIS_ANALYZE_LEVEL);	fprintf('iModel.LS_IPARAM_IIS_ANALYZE_LEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_IUS_ANALYZE_LEVEL);	fprintf('iModel.LS_IPARAM_IUS_ANALYZE_LEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_BARRIER);	fprintf('iModel.LS_IPARAM_LIC_BARRIER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_CONSTRAINTS);	fprintf('iModel.LS_IPARAM_LIC_CONSTRAINTS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_DAYSTOEXP);	fprintf('iModel.LS_IPARAM_LIC_DAYSTOEXP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_DAYSTOTRIALEXP);	fprintf('iModel.LS_IPARAM_LIC_DAYSTOTRIALEXP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_EDUCATIONAL);	fprintf('iModel.LS_IPARAM_LIC_EDUCATIONAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_GLOBAL);	fprintf('iModel.LS_IPARAM_LIC_GLOBAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_GOP_INTEGERS);	fprintf('iModel.LS_IPARAM_LIC_GOP_INTEGERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_GOP_NONLINEARVARS);	fprintf('iModel.LS_IPARAM_LIC_GOP_NONLINEARVARS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_INTEGERS);	fprintf('iModel.LS_IPARAM_LIC_INTEGERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_NONLINEAR);	fprintf('iModel.LS_IPARAM_LIC_NONLINEAR=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_NONLINEARVARS);	fprintf('iModel.LS_IPARAM_LIC_NONLINEARVARS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_NUMUSERS);	fprintf('iModel.LS_IPARAM_LIC_NUMUSERS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_RUNTIME);	fprintf('iModel.LS_IPARAM_LIC_RUNTIME=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LIC_VARIABLES);	fprintf('iModel.LS_IPARAM_LIC_VARIABLES=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL);	fprintf('iModel.LS_IPARAM_LP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_AGGCUTLIM_TOP);	fprintf('iModel.LS_IPARAM_MIP_AGGCUTLIM_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_AGGCUTLIM_TREE);	fprintf('iModel.LS_IPARAM_MIP_AGGCUTLIM_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_ANODES_SWITCH_DF);	fprintf('iModel.LS_IPARAM_MIP_ANODES_SWITCH_DF=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_AOPTTIMLIM);	fprintf('iModel.LS_IPARAM_MIP_AOPTTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_BRANCH_LIMIT);	fprintf('iModel.LS_IPARAM_MIP_BRANCH_LIMIT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_BRANCH_PRIO);	fprintf('iModel.LS_IPARAM_MIP_BRANCH_PRIO=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_BRANCHDIR);	fprintf('iModel.LS_IPARAM_MIP_BRANCHDIR=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_BRANCHRULE);	fprintf('iModel.LS_IPARAM_MIP_BRANCHRULE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_CUTDEPTH);	fprintf('iModel.LS_IPARAM_MIP_CUTDEPTH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_CUTFREQ);	fprintf('iModel.LS_IPARAM_MIP_CUTFREQ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_CUTLEVEL_TOP);	fprintf('iModel.LS_IPARAM_MIP_CUTLEVEL_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_CUTLEVEL_TREE);	fprintf('iModel.LS_IPARAM_MIP_CUTLEVEL_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_CUTTIMLIM);	fprintf('iModel.LS_IPARAM_MIP_CUTTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_DUAL_SOLUTION);	fprintf('iModel.LS_IPARAM_MIP_DUAL_SOLUTION=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_HEULEVEL);	fprintf('iModel.LS_IPARAM_MIP_HEULEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_HEUMINTIMLIM);	fprintf('iModel.LS_IPARAM_MIP_HEUMINTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelDouParameter',iModel,LS_DPARAM_MIP_ITRLIM);	fprintf('iModel.LS_DPARAM_MIP_ITRLIM=%g, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_KEEPINMEM);	fprintf('iModel.LS_IPARAM_MIP_KEEPINMEM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_LSOLTIMLIM);	fprintf('iModel.LS_IPARAM_MIP_LSOLTIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_MAXCUTPASS_TOP);	fprintf('iModel.LS_IPARAM_MIP_MAXCUTPASS_TOP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_MAXCUTPASS_TREE);	fprintf('iModel.LS_IPARAM_MIP_MAXCUTPASS_TREE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_MAXNONIMP_CUTPASS);	fprintf('iModel.LS_IPARAM_MIP_MAXNONIMP_CUTPASS=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_NODESELRULE);	fprintf('iModel.LS_IPARAM_MIP_NODESELRULE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_PRELEVEL);	fprintf('iModel.LS_IPARAM_MIP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_PREPRINTLEVEL);	fprintf('iModel.LS_IPARAM_MIP_PREPRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL);	fprintf('iModel.LS_IPARAM_MIP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_REOPT);	fprintf('iModel.LS_IPARAM_MIP_REOPT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_SCALING_BOUND);	fprintf('iModel.LS_IPARAM_MIP_SCALING_BOUND=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_SOLVERTYPE);	fprintf('iModel.LS_IPARAM_MIP_SOLVERTYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_STRONGBRANCHLEVEL);	fprintf('iModel.LS_IPARAM_MIP_STRONGBRANCHLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_TIMLIM);	fprintf('iModel.LS_IPARAM_MIP_TIMLIM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_TOPOPT);	fprintf('iModel.LS_IPARAM_MIP_TOPOPT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_TREEREORDERLEVEL);	fprintf('iModel.LS_IPARAM_MIP_TREEREORDERLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MIP_USECUTOFFOBJ);	fprintf('iModel.LS_IPARAM_MIP_USECUTOFFOBJ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_MPS_OBJ_WRITESTYLE);	fprintf('iModel.LS_IPARAM_MPS_OBJ_WRITESTYLE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_AUTODERIV);	fprintf('iModel.LS_IPARAM_NLP_AUTODERIV=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_CONVEX);	fprintf('iModel.LS_IPARAM_NLP_CONVEX=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_CONVEXRELAX);	fprintf('iModel.LS_IPARAM_NLP_CONVEXRELAX=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_CR_ALG_REFORM);	fprintf('iModel.LS_IPARAM_NLP_CR_ALG_REFORM=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_DERIV_DIFFTYPE);	fprintf('iModel.LS_IPARAM_NLP_DERIV_DIFFTYPE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_ITRLMT);	fprintf('iModel.LS_IPARAM_NLP_ITRLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_LINEARITY);	fprintf('iModel.LS_IPARAM_NLP_LINEARITY=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_LINEARZ);	fprintf('iModel.LS_IPARAM_NLP_LINEARZ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_MAXLOCALSEARCH);	fprintf('iModel.LS_IPARAM_NLP_MAXLOCALSEARCH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_PRELEVEL);	fprintf('iModel.LS_IPARAM_NLP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_PRINTLEVEL);	fprintf('iModel.LS_IPARAM_NLP_PRINTLEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_QUADCHK);	fprintf('iModel.LS_IPARAM_NLP_QUADCHK=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_SOLVE_AS_LP);	fprintf('iModel.LS_IPARAM_NLP_SOLVE_AS_LP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_SOLVER);	fprintf('iModel.LS_IPARAM_NLP_SOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_STARTPOINT);	fprintf('iModel.LS_IPARAM_NLP_STARTPOINT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_SUBSOLVER);	fprintf('iModel.LS_IPARAM_NLP_SUBSOLVER=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_USE_CRASH);	fprintf('iModel.LS_IPARAM_NLP_USE_CRASH=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_USE_SELCONEVAL);	fprintf('iModel.LS_IPARAM_NLP_USE_SELCONEVAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_USE_SLP);	fprintf('iModel.LS_IPARAM_NLP_USE_SLP=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_NLP_USE_STEEPEDGE);	fprintf('iModel.LS_IPARAM_NLP_USE_STEEPEDGE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_OBJSENSE);	fprintf('iModel.LS_IPARAM_OBJSENSE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SOLVER_IPMSOL);	fprintf('iModel.LS_IPARAM_SOLVER_IPMSOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SOLVER_IUSOL);	fprintf('iModel.LS_IPARAM_SOLVER_IUSOL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SOLVER_RESTART);	fprintf('iModel.LS_IPARAM_SOLVER_RESTART=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SOLVER_TIMLMT);	fprintf('iModel.LS_IPARAM_SOLVER_TIMLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SOLVER_USECUTOFFVAL);	fprintf('iModel.LS_IPARAM_SOLVER_USECUTOFFVAL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SPLEX_DPRICING);	fprintf('iModel.LS_IPARAM_SPLEX_DPRICING=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SPLEX_ITRLMT);	fprintf('iModel.LS_IPARAM_SPLEX_ITRLMT=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SPLEX_PPRICING);	fprintf('iModel.LS_IPARAM_SPLEX_PPRICING=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_LP_PRELEVEL);	fprintf('iModel.LS_IPARAM_LP_PRELEVEL=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SPLEX_REFACFRQ);	fprintf('iModel.LS_IPARAM_SPLEX_REFACFRQ=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_SPLEX_SCALE);	fprintf('iModel.LS_IPARAM_SPLEX_SCALE=%d, nErr=%d\n',par,nErr);
[par,nErr]=mxlindo('LSgetModelIntParameter',iModel,LS_IPARAM_VER_NUMBER);	fprintf('iModel.LS_IPARAM_VER_NUMBER=%d, nErr=%d\n',par,nErr);

[nErr]=mxlindo('LSdeleteEnv',iEnv);



%%    
function myCleanupFun(iEnv)
    fprintf('Destroying LINDO environment\n');
    [nErr]=mxlindo('LSdeleteEnv',iEnv); 