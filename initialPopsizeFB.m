function [implementList, rkchromosome, skchromosome]=initialPopsizeFB(choice,depend,actNo,mandatory,req,duration,projRelation,nrpr,nrsu,su,pred,choiceList,resNo,cost,pop,deadline)
%% ��Ⱥ��ʼ��
% ��ʼ��
rkchromosome=rand(pop,actNo);
skchromosome=rand(pop,actNo);
% ��β��ʼ��Ϊ0
rkchromosome(:,1)=0;
rkchromosome(:,actNo) = 0;
skchromosome(:,1)=0;
skchromosome(:,actNo) = 0;
% ����ʵʩ�б�
implementList = zeros(pop,actNo+1);
implementList(:,actNo+1)=Inf;
% ���ɳ�ʼ��
implement=resourcePr(choice,depend,actNo,mandatory,req,duration);
implementList(1,:)=implement;
for i=2:pop
    implementList(i,:)=generateImplement(implement,choice,depend,actNo);
end
% ����������Ŀ�ṹ
for i=1:pop
    nei_implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,nei_implement,actNo);
    [est,eft] = forwardPass( projRelation_i, duration ,nei_implement);
    [lst,lft] = backwardPass( projRelation_i, duration, deadline,nei_implement);
    est(actNo)=deadline;
    eft(actNo)=deadline;
    fff=freeFloat(est,eft,actNo,nrsu_i,su_i,nei_implement,deadline);
%     disp(fff)
    CB=objEvaluate(nei_implement,est,actNo,resNo,duration,req,deadline,cost);
    schedule=est';
    schedule(actNo+1)=CB;
    
    best_schedule=zeros(1,actNo+1);
    best_schedule(actNo+1)=Inf;
    [best_schedule]=FBHA(best_schedule,schedule,fff,eft,est,lst,nei_implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,nrsu_i,pred_i,su_i);
    
    nei_implement(actNo+1)=best_schedule(actNo+1);
    implementList(i,:)=nei_implement;
    % �����ȼƻ�ת��ΪSK��RK
%      [rk, sk]=transform1(best_schedule(1:actNo),nei_implement,actNo,projRelation_i,deadline,duration,nrpr_i,nrsu_i,pred_i,su_i);
    [rk, sk]=transform(best_schedule(1:actNo),nei_implement,actNo,projRelation_i,deadline,duration);
    rkchromosome(i,:)=rk;
    skchromosome(i,:)=sk;
end


