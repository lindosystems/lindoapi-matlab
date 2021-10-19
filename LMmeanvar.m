function [dMean,dVar,distName,nErr] = LMmeanvar(distType,dPar)
lindo;
nErr = 0;
dMean =[];
dVar = [];
distName=[];
if distType==LSDIST_TYPE_BETA,
    dMean=dPar(1)/(dPar(1)+dPar(2));
    dVar=(dPar(1)*dPar(2))/(dPar(1)+dPar(2))^2/(dPar(1)+dPar(2)+1); 
    dVar=dVar^.5;
    distName='%-10s: be(%g,%g)';
elseif distType==LSDIST_TYPE_GAMMA,
    dMean=dPar(1)*dPar(2);
    dVar=dPar(1)*dPar(1)*dPar(2); 
    dVar=dVar^.5;    
    distName='%-10s: ga(%g,%g)';
elseif distType==LSDIST_TYPE_UNIFORM,
    dMean=(dPar(1)+dPar(2))/2;
    dVar=(dPar(2)-dPar(1))^2/12; 
    dVar=dVar^.5;       
    distName='%-10s: u(%g,%g)';   
elseif distType==LSDIST_TYPE_NORMAL,
    dMean=dPar(1);
    dVar=dPar(2); 
    distName='%-10s: N(%g,%g)';     
elseif distType==LSDIST_TYPE_DISCRETE,
    dMean=0;
    dVar=0; 
    distName='%-10s: dsc(%g,%g)';        
elseif distType==LSDIST_TYPE_POISSON,
    dMean=dPar(1);
    dVar=dPar(1); 
    distName='%-10s: po(%g,%g)';            
else    
    nErr = LSERR_NOT_SUPPORTED;
    return;
end;