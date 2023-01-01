function LSopts = LMoptions(which,LSopts)
% LMoptions: Get or update solver 'options' structure
% 
% Usage:  
%         LSopts = LMoptions(which)
  
% Copyright (c) 2001-2022
%
% LINDO Systems, Inc.            312.988.7422
% 1415 North Dayton St.          info@lindo.com
% Chicago, IL 60622              http://www.lindo.com

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2,
    LSopts={};
end    
if strcmp(which,'linprog'),
    % linprog options
    if ~isfield(LSopts,'Algorithm'), LSopts.Algorithm='dual-simplex'; end
    if ~isfield(LSopts,'Diagnostics'), LSopts.Diagnostics='off'; end
    if ~isfield(LSopts,'Display'), LSopts.Display='iter'; end
    if ~isfield(LSopts,'LargeScale'), LSopts.LargeScale='on'; end
    if ~isfield(LSopts,'Preprocess'), LSopts.Preprocess='basic'; end
    if ~isfield(LSopts,'MaxIter'), LSopts.MaxIter=2^31; end
    if ~isfield(LSopts,'MaxTime'), LSopts.MaxTime=2^31; end
    if ~isfield(LSopts,'Simplex'), LSopts.Simplex='off'; end
    if ~isfield(LSopts,'TolCon'), LSopts.TolCon=1e-7; end
    if ~isfield(LSopts,'TolFun'), LSopts.TolFun=1e-7; end
elseif strcmp(which,'intlinprog'),
    % intlinprog options
    if ~isfield(LSopts,'BranchingRule'), LSopts.BranchingRule = 'maxpscost'; end;
    if ~isfield(LSopts,'CutGeneration'), LSopts.CutGeneration = 'basic'; end;
    if ~isfield(LSopts,'CutGenMaxIter'), LSopts.CutGenMaxIter = 10; end;
    if ~isfield(LSopts,'Display'), LSopts.Display = 'iter'; end;
    if ~isfield(LSopts,'Heuristics'), LSopts.Heuristics = 'rss'; end;
    if ~isfield(LSopts,'HeuristicsMaxNodes'), LSopts.HeuristicsMaxNodes = 50; end;
    if ~isfield(LSopts,'IPPreprocess'), LSopts.IPPreprocess = 'basic'; end;
    if ~isfield(LSopts,'LPMaxIter'), LSopts.LPMaxIter = 2^31; end;
    if ~isfield(LSopts,'LPPreprocess'), LSopts.LPPreprocess = 'basic'; end;
    if ~isfield(LSopts,'MaxNodes'), LSopts.MaxNodes = 1e7; end;
    if ~isfield(LSopts,'MaxNumFeasPoints'), LSopts.MaxNumFeasPoints = Inf; end;
    if ~isfield(LSopts,'MaxTime'), LSopts.MaxTime = 7200; end;
    if ~isfield(LSopts,'NodeSelection'), LSopts.NodeSelection = 'simplebestproj'; end;
    if ~isfield(LSopts,'ObjectiveCutOff'), LSopts.ObjectiveCutOff = Inf; end;
    if ~isfield(LSopts,'OutputFcn'), LSopts.OutputFcn = []; end;
    if ~isfield(LSopts,'PlotFcns'), LSopts.PlotFcns = []; end;
    if ~isfield(LSopts,'RelObjThreshold'), LSopts.RelObjThreshold = 1e-4; end;
    if ~isfield(LSopts,'RootLPAlgorithm'), LSopts.RootLPAlgorithm = 'dual-simplex'; end;
    if ~isfield(LSopts,'RootLPMaxIter'), LSopts.RootLPMaxIter = 3e4; end;
    if ~isfield(LSopts,'TolCon'), LSopts.TolCon = 1e-4; end;
    if ~isfield(LSopts,'TolFunLP'), LSopts.TolFunLP = 1e-7; end;
    if ~isfield(LSopts,'TolGapAbs'), LSopts.TolGapAbs = 0; end;
    if ~isfield(LSopts,'TolGapRel'), LSopts.TolGapRel = 1e-4; end;
    if ~isfield(LSopts,'TolInteger'), LSopts.TolInteger = 1e-5; end;
elseif strcmp(which,'lindo'),
    % Lindo specific options
    if ~isfield(LSopts,'nMethod'), LSopts.nMethod=0; end
    if ~isfield(LSopts,'iDefaultLog'), LSopts.iDefaultLog=1; end
    if ~isfield(LSopts,'presolve'), LSopts.presolve=1; end
    if ~isfield(LSopts,'mipduals'), LSopts.mipduals=0; end
    if ~isfield(LSopts,'B'), LSopts.B=[]; end
    if ~isfield(LSopts,'setEnvParams'), LSopts.setEnvParams=0; end    
    if ~isfield(LSopts,'IUSOL'), LSopts.IUSOL=-1; end
    if ~isfield(LSopts,'IPMSOL'), LSopts.IPMSOL=-1; end
    if ~isfield(LSopts,'numAltOpt'), LSopts.numAltOpt=0; end  
    if ~isfield(LSopts,'outFormat'), LSopts.outFormat='mps'; end  
    if ~isfield(LSopts,'SOLVE_DUAL'), LSopts.SOLVE_DUAL=-1; end  
    if ~isfield(LSopts,'saveBas'), LSopts.saveBas=0; end  
    if ~isfield(LSopts,'saveSol'), LSopts.saveSol=0; end  
    if ~isfield(LSopts,'SCALE'), LSopts.SCALE=-1; end 
    if ~isfield(LSopts,'CBFREQ'), LSopts.CBFREQ=-1; end   
    if ~isfield(LSopts,'FP_MODE'), LSopts.FP_MODE=-1; end   
else
    fprintf('Solver type is not recognized\n');
    return;
end

% overrides
if isfield(LSopts,'Display') && strcmp(LSopts.Display,'final'),
    LSopts.iDefaultLog = 0;
end
