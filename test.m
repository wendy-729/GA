clc
clear 
% profile on
% 设置随机数种子，结果复现
global rn_seed; 
rn_seed = 317731;
%终止条件
end_schedules=5000;
% 480个实例的惩罚成本
fcost='D:\研究生资料\RLP-PS汇总\实验数据集\cost.txt';
costData = initfile(fcost);
fpath_clpex='D:\研究生资料\RLP-PS汇总\实验结果\CPLEX\J30\';
% 参数组合
% 遗传算法参数
para=[50,0.95,0.1];
pop=para(1);
p_cross=para(2);
p_mutation=para(3);
% 活动数量
for actN=[60]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
dt=num2str(dtime);
% % 读取CPLEX中的最优解
% fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
% cplex_data=dlmread(fp_cplex);
% % cplex求出最优值
% opt_index=find(cplex_data(:,4)==2);
% 遍历每一个实例
for act=33:33
disp(act)
rng(rn_seed,'twister');
% 惩罚成本
cost=costData(act,:);
actno=num2str(act);
%% 初始化数据
fpath=['D:\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
filename=[fpath,actNumber,'_',actno,'.RCP'];

% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);

fp_choice=['D:\研究生资料\RLP-PS汇总\实验数据集\J',actNumber,'\'];

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
% disp(length(mandatory))
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);
choiceList=unique(choiceList);
choiceList=sort(choiceList);
% 触发依赖活动的可选活动
choice_depend=depend(:,1);
%% 所有活动都执行的项目截止日期
[est, all_eft ]= forward(projRelation, duration);
[lst,lft]=backward( projRelation, duration, all_eft(actNo));
% 项目的截止日期
deadline=floor(dtime*all_eft(actNo));
vl = [1, 3, 4, 5, 6, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 21, 23, 24, 25, 26, 27, 28, 29, 30, 31, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62]
;
implement = zeros(1,actNo);
implement(vl)=1;
schedule =[0, 0, 0, 20, 5, 22, 0, 4, 13, 4, 0, 11, 0, 2, 25, 37, 6, 16, 0, 0, 16, 0, 16, 0, 4, 44, 33, 25, 29, 2, 33, 0, 7, 28, 20, 38, 30, 0, 7, 32, 19, 27, 40, 21, 16, 27, 49, 11, 25, 43, 37, 8, 44, 35, 46, 40, 50, 51, 57, 51, 56, 58]
;
u_kt2=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline, cost);
disp(u_kt2)
end % 活动
end %截止日期
end % 组数
end 
