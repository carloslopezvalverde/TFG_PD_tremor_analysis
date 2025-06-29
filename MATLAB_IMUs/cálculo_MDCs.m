%% Carlos
load('Data4MDC.mat');

%% POWER DTF
% Power rep
var= P_DTF_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_P_DTF(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% Power dt
var= P_DTF_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_P_DTF(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% Power post
var= P_DTF_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});x
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_P_DTF(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM

%% Band Power
% rep
var= BP_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_BP(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% dt
var= BP_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_BP(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% post
var= BP_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_BP(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM

%% RMS tremor
% rep
var= RMSt_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSt(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% dt
var= RMSt_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSt(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% post
var= RMSt_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSt(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM

%% RMS robust
% rep
var= RMSr_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSr(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% dt
var= RMSr_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSr(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% post
var= RMSr_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_RMSr(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM

%% TPR
% rep
var= TPR_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_TPR(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% dt
var= TPR_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_TPR(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% post
var= TPR_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_TPR(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM

%% Perc Tremor
% rep
var= PRCtr_rep; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_PRCtr(1)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% dt
var= PRCtr_dt; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_PRCtr(2)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM
% post
var= PRCtr_post; 
data = array2table(var, 'VariableNames', {'REP1', 'REP2'});
withinDesign = table([1 2]', 'VariableNames', {'Repetitions'});
rmModel = fitrm(data, 'REP1-REP2~1', 'WithinDesign', withinDesign);
rmANOVA = ranova(rmModel);
disp(rmANOVA);
SEM=sqrt(table2array(rmANOVA(2,3)));
MDC_PRCtr(3)=SEM*1.96*sqrt(2);
clear data rmModel rmANOVA SEM