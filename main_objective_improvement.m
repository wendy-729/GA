% 将两个目标函数获得的进度计划用用一个统一的指标衡量
% 20211229
% 目标函数仿真
clc
clear
fcost='D:\研究生资料\RLP-PS汇总\实验数据集\cost.txt';
costData = dlmread(fcost);
var_set = zeros(1,240);
u_kt2_set = zeros(240,1);
var_set_abs =  zeros(1,480);
abs_ukt_set = zeros(240,1);
all_improvement = zeros(240,1);
% 活动数量
for actN=[30]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
dt=num2str(dtime);
% 读取得到的进度计划
fpath =['D:\研究生资料\RLP-PS汇总\大修\大修实验结果final\GA1\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
data = dlmread(fpath);
fpath_abs = ['D:\研究生资料\RLP-PS汇总\第五次投稿-Annals of Operations Research\ANOR大修\GA_abs\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
data_abs = dlmread(fpath_abs);
% 遍历每一实例
count = 0;
for act=1:2:480
    count = count+1;
% for act=opt_index'
% 惩罚成本
cost=costData(act,:);
actno=num2str(act);
%% 初始化数据
% fpath=['E:\zlw\实验数据集\PSPLIB\j',actNumber,'\J'];
fpath=['D:\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
filename=[fpath,actNumber,'_',actno,'.RCP'];

% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);

fp_choice=['D:\研究生资料\RLP-PS汇总\实验数据集\J',actNumber,'\'];
% fp_choice=['E:\zlw\实验数据集\J',actNumber,'\'];
% fp_choice=['E:\zlw\大修实验\数据集\J',actNumber,'\'];

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = dlmread(choicename);
depend = dlmread(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = dlmread(mandatoryname);
% disp(length(mandatory))
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = dlmread(choiceListname);
choiceList=unique(choiceList);
choiceList=sort(choiceList);
% 触发依赖活动的可选活动
choice_depend=depend(:,1);
%% 所有活动都执行的项目截止日期
[est, all_eft ]= forward(projRelation, duration);
[lst,lft]=backward( projRelation, duration, all_eft(actNo));
% 项目的截止日期
deadline=floor(dtime*all_eft(actNo));
setName = ['rlp_',num2str(actNo)];
% %% 资源使用量平方初始解
% f = ['D:\研究生资料\RLP-PS汇总\第五次投稿-Annals of Operations Research\ANOR大修\初始解\u_kt\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
% initial_data = dlmread(f);
% initial_u_kt = initial_data(count,2);
% %资源使用量平方
% schedule = data(act, 4:3+actN+2);
% vl = data(act, 36:35+actN+2);
% u_kt_data = data(act,2);
% if u_kt_data<initial_u_kt
%     improvement1 = (initial_u_kt-u_kt_data)/initial_u_kt;
% else
%     improvement1 = 0;
% end
% 
% 
% u_kt2_set(count) = improvement1;
% 
% % 计算资源的使用量的绝对值
% schedule_abs = data_abs(count, 4:3+actN+2);
% vl_abs = data_abs(count, 36:35+actN+2);
% obj_abs = objEvaluate(vl_abs,schedule_abs,actNo,resNo,duration,req,deadline, cost);
% 
% if obj_abs<initial_u_kt
%     improvement2 = (initial_u_kt-obj_abs)/initial_u_kt;
% else
%     improvement2 = 0;
% end
% 
% abs_ukt_set(count) = improvement2;
% avg_improvement = (improvement1+improvement2)/2;
% all_improvement(count) = avg_improvement;

%% 资源绝对值初始解
f = ['D:\研究生资料\RLP-PS汇总\第五次投稿-Annals of Operations Research\ANOR大修\初始解\abs_u_kt\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
initial_data = dlmread(f);
initial_u_kt = initial_data(count,2);

% 计算资源的使用量的绝对值
schedule_abs = data_abs(count, 4:3+actN+2);
vl_abs = data_abs(count, 36:35+actN+2);
obj_abs = data_abs(count,2);
% obj_abs = objEvaluate(vl_abs,schedule_abs,actNo,resNo,duration,req,deadline, cost);

if obj_abs<initial_u_kt
    improvement2 = (initial_u_kt-obj_abs)/initial_u_kt;
else
    improvement2 = 0;
end

abs_ukt_set(count) = improvement2;

%资源使用量平方
schedule = data(act, 4:3+actN+2);
vl = data(act, 36:35+actN+2);
% u_kt_data = data(act,2);
u_kt_data = abs_objEvaluate(vl,schedule,actNo,resNo,duration,req,deadline, cost);
if u_kt_data<initial_u_kt
    improvement1 = (initial_u_kt-u_kt_data)/initial_u_kt;
else
    improvement1 = 0;
end


u_kt2_set(count) = improvement1;


avg_improvement = (improvement1+improvement2)/2;
all_improvement(count) = avg_improvement;
end %实例

end % 截止日期
end % 组数
end % 活动数量
