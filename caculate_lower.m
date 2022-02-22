% 下界 只考虑必须执行活动
clc
clear 
% profile on
% 设置随机数种子，结果复现
global rn_seed; % random number seed; 
rn_seed = 317731;

% 480个实例的惩罚成本
fcost='D:\研究生资料\RLP-PS汇总\实验数据集\cost.txt';
costData = initfile(fcost);
% 读取CPLEX的求解结果
fpath_clpex='D:\研究生资料\RLP-PS汇总\实验结果\CPLEX\J30\';
% 活动数量
for actN=[30]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
%% 输出文件路径
setName = ['rlp_',num2str(actN)];
fpathRoot=['C:\Users\ASUS\Desktop\'];
dt=num2str(dtime);
act_count=0;

% 读取CPLEX中的最优解
fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
cplex_data=dlmread(fp_cplex);
% cplex求出最优值
opt_index=find(cplex_data(:,4)==1);
% disp(opt_index)
% 遍历每一个实例
for act=opt_index'
% for act=1:480
% disp(act)
rng(rn_seed,'twister');
act_count=act_count+1;
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
%% 所有活动都执行的项目截止日期
[est, all_eft ]= forward(projRelation, duration);
% [lst,lft]=backward( projRelation, duration, all_eft(actNo));
% 项目的截止日期
deadline=floor(dtime*all_eft(actNo));
tic
% 平均资源需求
avg_res=zeros(1,resNo);
for k=1:resNo
    temp_res=0;
    for i=mandatory
        temp_res=temp_res+req(i,k)*duration(i);
    end
    avg_res(k)=temp_res/deadline;
end

ukt=0;
for k=1:resNo
    ukt=ukt+cost(k)*avg_res(k)*avg_res(k)*deadline;
end
ukt=floor(ukt);
cputime = toc;
%% 写入文件
outResults=[act,ukt,cputime];
outFile=[fpathRoot,'lower_m',setName,'_dt_',dt,'_','.txt'];
% % 时间
% outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement];
% outFile=[fpathRoot,num2str(end_time),'s_sch_de_target_ssgs1_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');

outResults=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % 实例
end %截止日期
end % 组数
end % 活动数量