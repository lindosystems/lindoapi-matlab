
%N = [50 100 500];
N = [5000]; 
%1031 1034 1001 1007 1013 
S = [1027 1029 2007 2017 3017 4017 5017 6017 7017 8017] 
szCoreFile = 'Z:/prob/lp/smps/swright/20term/20.cor';
szTimeFile = 'Z:/prob/lp/smps/swright/20term/20.tim';
szStocFile = 'Z:/prob/lp/smps/swright/20term/20.sto';

for i=1:length(N),
    for j=1:length(S),
      %  LMtestSP2(szCoreFile,szTimeFile,szStocFile, N(i), N(i)/10, S(j));
    end;
end;


szCoreFile = 'Z:/prob/lp/smps/swright/gbd/gbd-sw.cor';
szTimeFile = 'Z:/prob/lp/smps/swright/gbd/gbd-sw.tim';
szStocFile = 'Z:/prob/lp/smps/swright/gbd/gbd-sw.sto';
for i=1:length(N),
    for j=1:length(S),
        %LMtestSP2(szCoreFile,szTimeFile,szStocFile, N(i), N(i)/10, S(j));
    end;
end;

szCoreFile = 'Z:/prob/lp/smps/swright/lands/lands-sw.cor';
szTimeFile = 'Z:/prob/lp/smps/swright/lands/lands-sw.tim';
szStocFile = 'Z:/prob/lp/smps/swright/lands/lands-sw.sto';
for i=1:length(N),
    for j=1:length(S),
        %LMtestSP2(szCoreFile,szTimeFile,szStocFile, N(i), N(i)/10, S(j));
    end;
end;


szCoreFile = 'Z:/prob/lp/smps/swright/ssn/ssn.cor';
szTimeFile = 'Z:/prob/lp/smps/swright/ssn/ssn.tim';
szStocFile = 'Z:/prob/lp/smps/swright/ssn/ssn.sto';
for i=1:length(N),
    for j=1:length(S),
        LMtestSP2(szCoreFile,szTimeFile,szStocFile, N(i), N(i)/10, S(j));
    end;
end;


szCoreFile = 'Z:/prob/lp/smps/swright/storm/storm-sw.cor';
szTimeFile = 'Z:/prob/lp/smps/swright/storm/storm-sw.tim';
szStocFile = 'Z:/prob/lp/smps/swright/storm/storm-sw.sto';
for i=1:length(N),
    for j=1:length(S),
        LMtestSP2(szCoreFile,szTimeFile,szStocFile, N(i), N(i)/10, S(j));
    end;
end;