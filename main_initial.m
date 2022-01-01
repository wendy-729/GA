% 在算法迭代结束后进行局部改进【初始解由启发式算法生成】 
% 目标函数为绝对值
% 每一组中抽
clc
clear 
% profile on
% 设置随机数种子，结果复现
global rn_seed; 
rn_seed = 317731;
%终止条件
end_schedules=5000;
% 480个实例的惩罚成本
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
for actN=[30]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0,1.2]
dt=num2str(dtime);
% % 读取CPLEX中的最优解
% fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
% cplex_data=dlmread(fp_cplex);
% % cplex求出最优值
% opt_index=find(cplex_data(:,4)==2);
% 遍历每一个实例
for act=1:2:480
% disp(act)
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
%% 只考虑必须执行活动估计局部改进的进度计划数量
mandatory_implement=zeros(1,actNo);
mandatory_implement(mandatory)=1;
[projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,mandatory_implement,actNo);
[esm, efm]= forwardPass( projRelation_i, duration ,mandatory_implement);
[lsm, lfm]= backwardPass(projRelation_i, duration, deadline,mandatory_implement);  
sum_tt=0;
for ii=1:actNo
    if mandatory_implement(ii)==1
        sum_tt=sum_tt+(lsm(ii)-esm(ii));
    end
end
sum_tt=floor(sum_tt/sum(mandatory_implement));
%% 初始种群
% 最好的项目结构
best_chrom=zeros(1,actNo+1);
best_chrom(1,actNo+1)=Inf;
% 最好的个体
best_schedule=zeros(1,actNo);

% 随机位移键
parent_implementList=zeros(2*pop,actNo+1);
parent_rkchromosome=zeros(2*pop,actNo);
parent_skchromosome=zeros(2*pop,actNo);
%% 启发式算法生成初始解
[initial_vl, initial_rk, initial_sk]=initialPopsizeFB(choice,depend,actNo,mandatory,req,duration,projRelation,nrpr,nrsu,su,pred,choiceList,resNo,cost,pop,deadline);
implementList=initial_vl;
rkchromosome=initial_rk;
skchromosome=initial_sk;
% 评估初始解
for i=1:pop
    implement=implementList(i,1:actNo); % 当前染色体
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    % 计算节点间的距离矩阵
    weigth_arc=zeros(actNo,actNo)-Inf;
    for a=1:actNo-1
        if implement(a)==1
            for j=1:nrsu_i(a)
                if implement(su_i(a,j))==1
                    weigth_arc(a,su_i(a,j))=0;
                    weigth_arc(a,su_i(a,j))=weigth_arc(a,su_i(a,j))+duration(a);
                end
            end
        end
    end
    d = path_floyd( actNo, weigth_arc,implement);
    % 最早开始时间和最晚开始时间
    [es, ef]= forwardPass( projRelation_i, duration ,implement);
    [ls, lf]= backwardPass(projRelation_i, duration, deadline,implement);  
    rk=rkchromosome(i,:);
    sk=skchromosome(i,:);
    schedule= decoding(implement,es,ls,rk,sk,duration,pred_i,nrpr_i,d);

    % 判断进度计划可行性
    if scheduleFeasible(schedule,actNo,nrsu_i,su_i,implement,duration)
        implementList(i,actNo+1)=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline,cost);
    else
        implementList(i,actNo+1)=Inf;
    end
    if implementList(i,actNo+1)<best_chrom(1,actNo+1)
        best_chrom=implementList(i,:);
        best_schedule=schedule;
        best_ls=ls;
        best_es=es;
        best_nrpr=nrpr_i;
        best_nrsu=nrsu_i;
        best_su=su_i;
        best_pred=pred_i;
    end
end 

% cputime=toc;
% disp(cb)
% 输出文件
setName = ['rlp_',num2str(actNo)];
fpathRoot=['D:\研究生资料\RLP-PS汇总\第五次投稿-Annals of Operations Research\ANOR大修\初始解\u_kt\J',actNumber,'\',groupdata,'\'];
% disp(actNumber)
dt=num2str(dtime);
outResults=[act,best_chrom(actNo+1),best_schedule,best_chrom(1:actNo)];
outFile=[fpathRoot,num2str(end_schedules),'sch_',setName,'_dtime_',dt,'.txt'];
disp(['Instance ',num2str(act),' has been solved.']);
dlmwrite(outFile,outResults, '-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[]; 
end % 实例
end % 终止日期循环
end % 第几组数据
end % 活动数量

