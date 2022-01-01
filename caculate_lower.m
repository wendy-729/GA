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
% 活动数量
for actN=[30]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
%% 输出文件路径
setName = ['rlp_',num2str(actN)];
fpathRoot=['C:\Users\ASUS\Desktop\实验结果\GA\J',actNumber,'\'];
dt=num2str(dtime);
act_count=0;

% 遍历每一个实例
for act=1:1
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

end % 实例
end %截止日期
end % 组数
end % 活动数量