% 在算法迭代过程进行局部改进【初始解由随机生成】
clc
clear 
% profile on
% 设置随机数种子，结果复现
global rn_seed; 
rn_seed = 317731;
% 遗传算法参数
para=[100,0.95,0.1];
pop=para(1);
p_cross=para(2);
p_mutation=para(3);
all_obj=[];
%终止条件
end_schedules=5000;
% 480个实例的惩罚成本
fcost='D:\研究生资料\RLP-PS汇总\实验数据集\cost.txt';
costData = initfile(fcost);
fpath_clpex='D:\研究生资料\RLP-PS汇总\实验结果\CPLEX\J30\';
% 活动数量
for actN=[30]
actNumber=num2str(actN);
%% 测试哪一组数据
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0,1.2]
dt=num2str(dtime);
% 读取CPLEX中的最优解
fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
cplex_data=dlmread(fp_cplex);
% cplex求出最优值
opt_index=find(cplex_data(:,4)==2);
% disp(opt_index)
% 遍历每一个实例
% for act=1:10:480
for act=opt_index'
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
%% 所有活动都执行的项目截止日期
[est, all_eft ]= forward(projRelation, duration);
[lst,lft]=backward( projRelation, duration, all_eft(actNo));
sum_tt1=0;
for ii=1:actNo
    sum_tt1=sum_tt1+(lst(ii)-est(ii));
end
sum_tt1=floor(sum_tt1/actNo);
disp(sum_tt1)
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
disp(sum_tt)

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
% 初始化
rkchromosome=rand(pop,actNo);
skchromosome=rand(pop,actNo);
% 首尾虚活动始终为0
rkchromosome(:,1)=0;
rkchromosome(:,actNo) = 0;
skchromosome(:,1)=0;
skchromosome(:,actNo) = 0;
% 产生实施列表
implementList = zeros(pop,actNo+1);
implementList(:,actNo+1)=Inf;
%% 随机生成初始种群
% 所有实施活动置为1
for i=1:pop
    for j=mandatory
        implementList(i,j)=1;
    end
end
% 触发依赖活动的可选活动
choice_depend=depend(:,1);
% 随机确定可选活动
[r,c]=size(choice);
for i=1:pop
    for j=1:r
        if implementList(i,choice(j,1))==1
            index = randi([2 c],1,1);  % 在可选集合中随机选择一个活动
            a = choice(j,index);
            implementList(i,a)=1;
            % 考虑执行的依赖活动触发选择的情况 ，根据可选活动的执行状态更新依赖活动的执行状态
            if any(a==choice_depend)==1
%             if find(choice_depend==a)~=0
                index=find(choice_depend==a);
               for d=depend(index,2:end)     % 更新依赖活动
                    implementList(i,d)=1;
               end 
            end
        end
    end
end
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
%         disp('不可行')
    end
    if implementList(i,actNo+1)<best_chrom(1,actNo+1)
        best_chrom=implementList(i,:);
        best_schedule=schedule;
    end
end 
parent_implementList(1:pop,:)=implementList;
parent_rkchromosome(1:pop,:)=rkchromosome;
parent_skchromosome(1:pop,:)=skchromosome;
%% 迭代，求最好的染色体
tic;
nr_schedules=pop;
count1=0;
count2=0;
count_iter=0;
while nr_schedules<end_schedules   
%% 随机键交叉
    count_iter=count_iter+1;
    child_rkchromosome=rkchromosome;
    child_skchromosome=skchromosome;
    for i=1:2:pop
        if rand>p_cross
            continue;
        end
        % 交叉位置
        pos1=randi(actNo);
        pos2=randi(actNo);
        while pos1==pos2
            pos2=randi(actNo);
        end
        if pos1>pos2
            t=pos1;
            pos1=pos2;
            pos2=t;
        end
        child_rkchromosome(i,pos1:pos2)=rkchromosome(i+1,pos1:pos2);
        child_rkchromosome(i+1,pos1:pos2)=rkchromosome(i,pos1:pos2);
        child_skchromosome(i,pos1:pos2)=skchromosome(i+1,pos1:pos2);
        child_skchromosome(i+1,pos1:pos2)=skchromosome(i,pos1:pos2);
    end
%% 实施列表交叉
    % 初始化实施列表
    child_implement=zeros(pop,actNo+1);
    child_implement(:, actNo+1) = Inf;
    for i=1:pop
        for j=mandatory
            child_implement(i,j)=1;
        end
    end
    for i=1:2:pop   
        if rand>p_cross
            child_implement(i,:)=implementList(i,:);  
            child_implement(i+1,:)=implementList(i+1,:);
            continue;
        end
         [r,~]=size(choice); % 行，列
         b = randi([1 r],1,1);
         for e=1:b
             % 选择中的可选活动
            for j=choice(e,2:end)
                child_implement(i,j)=implementList(i,j);  %女儿
                child_implement(i+1,j)=implementList(i+1,j);   % 儿子
                % 继承依赖活动
                if any(j==choice_depend)==1
                   index=find(choice_depend==j);
                   for d=depend(index,2:end)     % 更新依赖活动
                        child_implement(i,d)=implementList(i,d);
                        child_implement(i+1,d)=implementList(i+1,d); 
                   end
                end
            end
         end
         if b<r
            for c=b+1:r
                e1=choice(c,1);
                % 女儿
                if child_implement(i,e1)==1  % 选择e被触发
                    if implementList(i+1,e1)==1  % 选择e被父亲触发
                        for j=choice(c,2:end)
                            child_implement(i,j)=implementList(i+1,j);
                             % 继承依赖活动
                             if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                                   index=find(choice_depend==j);
                                   for d=depend(index,2:end)    
                                        child_implement(i,d)=implementList(i+1,d);
                                   end 
                             end
                        end
                    else
                        % 在父亲中选择e没有被触发，继承母亲的
                        for j=choice(c,2:end)
                            child_implement(i,j)=implementList(i,j);
                            % 继承依赖活动
%                             if find(choice_depend==j)~=0
                             if any(j==choice_depend)==1
                                index=find(choice_depend==j);
                               for d=depend(index,2:end)    
                                    child_implement(i,d)=implementList(i,d);
                               end 
                             end
                        end
                    end
                end
                % 儿子
                if child_implement(i+1,e1)==1
                    if implementList(i,e1)==1  % 被母亲触发
                        for j=choice(c,2:end)
                            child_implement(i+1,j)=implementList(i,j);
                            % 继承依赖活动
                            if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                                index=find(choice_depend==j);
                               for d=depend(index,2:end)    
                                    child_implement(i+1,d)=implementList(i,d);
                               end 
                            end
                        end
                    else
                        % 在母亲中选择e没有被触发继承父亲的
                        for j=choice(c,2:end)
                            child_implement(i+1,j)=implementList(i+1,j);
                            % 继承依赖活动
                            if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                                index=find(choice_depend==j);
                               for d=depend(index,2:end)    
                                    child_implement(i+1,d)=implementList(i+1,d);
                               end 
                            end
                        end
                    end
                end
            end
         end
    end
%% 随机键和位移键变异
    for i=1:pop
        pro=rand(1,actNo);
        % 变异的位置
        pos_mu=find(pro<p_mutation);
        child_rkchromosome(i,pos_mu)=rand(1,length(pos_mu));
        child_skchromosome(i,pos_mu)=rand(1,length(pos_mu));
    end
    child_rkchromosome(:,1)=0;
    child_skchromosome(:,1)=0; 
    child_rkchromosome(:,end)=0;
    child_skchromosome(:,end)=0; 
%% 实施列表变异
%     child_implement=mutation(child_implement,choice,depend,pop,p_mutation);
    for i=1:pop
        if rand<p_mutation
            [r,c]=size(choice);
             b = randi([1 r],1,1);
             for j=b:r      
                 e=choice(j,1);  % 触发活动
                 if child_implement(i,e)==1  % 如果选择触发
                     pos = randi([2 c],1,1);
                     while child_implement(i,choice(j,pos))==1
                         pos = randi([2 c],1,1);
                     end
                     child_implement(i,choice(j,pos))=1;
                     for p=2:c
                         if p~=pos
                             child_implement(i,choice(j,p))=0;
                         end
                     end
                     % 更新依赖活动的状态
                     [rd,cd]=size(depend);
                     for c_d=1:rd
                        if child_implement(i,depend(c_d,1))==1
                            for d=depend(c_d,2:end)
                                child_implement(i,d)=1;
                            end
                        else
                            for d=depend(c_d,2:end)
                                child_implement(i,d)=0;
                            end
                        end
                     end
                 else
%                    选择没有触发
                    % 如果活动以前触发但现在未触发
                     if all(child_implement(i,choice(j,2:end))==0)==0
                         for p=2:c
                             child_implement(i,choice(j,p))=0;
                         end 
                         % 更新依赖活动的状态
                         [rd,cd]=size(depend);
                         for c_d=1:rd
                            if child_implement(i,depend(c_d,1))==1 
                                for d=depend(c_d,2:end)
                                    child_implement(i,d)=1;
                                end
                            else
                                for d=depend(c_d,2:end)
                                    child_implement(i,d)=0;
                                end
                            end
                         end
                     end
                 end
             end
        end
    end
    parent_rkchromosome(pop+1:end,:)=child_rkchromosome;
    parent_skchromosome(pop+1:end,:)=child_skchromosome;
    parent_implementList(pop+1:end,:)=child_implement;
    % 评估子个体
    flag=0;
    for i=1:pop 
        flag_end=0;
        projRelation_i=projRelation;
        nrpr_i=nrpr;
        nrsu_i=nrsu;
        su_i=su;
        pred_i=pred;
        implement=child_implement(i,:); % 当前染色体
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation_i,nrpr_i,nrsu_i,su_i,pred_i,choiceList,implement,actNo);
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
        rk=child_rkchromosome(i,:);
        sk=child_skchromosome(i,:);
        
%         % 估算
        tt=ls-es;
% %         % 估计最坏的情况下的下界[所有执行的活动]
%         sum_tt=0;
%         for ii=1:actNo
%             if implement(ii)==1
%                 sum_tt=sum_tt+tt(ii);
%             end
%         end
% %         % 向上取整
%         sum_tt=floor(sum_tt/sum(implement(1:actNo)));
%         disp(sum_tt)
        cputime1=toc;
        if count1==0 && (nr_schedules+1>1000 || nr_schedules+1+sum_tt> 1000)
%             disp(nr_schedules)
            count1=count1+1;
            outResults1=[act,best_chrom(actNo+1),cputime1,best_schedule,best_chrom,nr_schedules];
        end
        if count2==0 && (nr_schedules+1>3000  || nr_schedules+1+sum_tt> 3000)
%             disp(nr_schedules)
            count2=count2+1;
            outResults2=[act,best_chrom(actNo+1),cputime1,best_schedule,best_chrom,nr_schedules];
        end
        % 跳出循环
        if nr_schedules+1>end_schedules
            flag=1;
            break;
        end  
       %% 评价个体
        schedule = decoding(implement,es,ls,rk,sk,duration,pred_i,nrpr_i,d);
        if scheduleFeasible(schedule,actNo,nrsu_i,su_i,implement,duration)
            obj=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline,cost);
            implement(actNo+1)=obj;
            child_implement(i,actNo+1)=obj;
        else
            nr_schedules=nr_schedules+1;
            continue
        end
        if implement(actNo+1)<best_chrom(actNo+1)
			best_chrom=implement;
            best_schedule=schedule;
        end
        nr_schedules=nr_schedules+1;
        
        % 进行局部改进
        isflag=1;
        if nr_schedules+sum_tt>end_schedules
            isflag = 0;
        end
        if isflag == 1
            % 局部改进      
            [~,index]=sort(tt);
            prList=index';
            [schedule,cb,es,ls]=improvement1(prList,es,ls,duration,su_i,pred_i,nrpr_i,schedule,implement,nrsu_i,resNo,cost,req,deadline);
            child_implement(i,actNo+1)=cb;

            nr_schedules=nr_schedules+sum_tt;

            if child_implement(i,actNo+1)<best_chrom(1,actNo+1)
                best_chrom=child_implement(i,:);
                best_schedule=schedule;
            end
        end
    end % 实例
    if flag==1
        break
    end
    parent_implementList(pop+1:2*pop,:)=child_implement;
    p=parent_implementList;
%  选择最好的pop个体作为父代
    [~,fitIndex]=sort(parent_implementList(:,actNo+1));
    fitIndex=fitIndex(1:pop);
    implementList=p(fitIndex,:);
    rkchromosome=parent_rkchromosome(fitIndex,:);
    skchromosome=parent_skchromosome(fitIndex,:);
    
    parent_implementList(1:pop,:)=implementList;
    parent_rkchromosome(1:pop,:)=rkchromosome;
    parent_skchromosome(1:pop,:)=skchromosome;
end  % 迭代结束
cputime=toc;
% disp(nr_schedules)
% 输出文件
setName = ['rlp_',num2str(actNo)];
fpathRoot=['C:\Users\ASUS\Desktop\回复审稿人实验\局部改进对比实验结果\J',actNumber,'\'];
% disp(actNumber)
dt=num2str(dtime);
outResults=[act,best_chrom(actNo+1),cputime,best_schedule(1:actNo),best_chrom,nr_schedules];
outFile=[fpathRoot,groupdata,'\',num2str(end_schedules),'sch_',setName,'_dtime_',dt,'_stochastic_iter_para1','.txt'];
outFile1=[fpathRoot,groupdata,'\',num2str(1000),'sch_',setName,'_dtime_',dt,'_stochastic_iter_para1','.txt'];
outFile2=[fpathRoot,groupdata,'\',num2str(3000),'sch_',setName,'_dtime_',dt,'_stochastic_iter_para1','.txt'];
disp(['Instance ',num2str(act),' has been solved.']);
dlmwrite(outFile,outResults, '-append', 'newline', 'pc',  'delimiter', '\t');
dlmwrite(outFile1,outResults1, '-append', 'newline', 'pc',  'delimiter', '\t');
dlmwrite(outFile2,outResults2, '-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[]; 
outResults1=[];
outResults2=[];
end % 实例
end % 终止日期循环
end % 第几组数据
end % 活动数量
