% ���㷨������������оֲ��Ľ�����ʼ��������ʽ�㷨���ɡ� 
% Ŀ�꺯��Ϊ����ֵ
% ÿһ���г�
clc
clear 
% profile on
% ������������ӣ��������
global rn_seed; 
rn_seed = 317731;
%��ֹ����
end_schedules=5000;
% 480��ʵ���ĳͷ��ɱ�
% 480��ʵ���ĳͷ��ɱ�
fcost='D:\�о�������\RLP-PS����\ʵ�����ݼ�\cost.txt';
costData = initfile(fcost);
fpath_clpex='D:\�о�������\RLP-PS����\ʵ����\CPLEX\J30\';
% �������
% �Ŵ��㷨����
para=[50,0.95,0.1];
pop=para(1);
p_cross=para(2);
p_mutation=para(3);
% �����
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0,1.2]
dt=num2str(dtime);
% % ��ȡCPLEX�е����Ž�
% fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
% cplex_data=dlmread(fp_cplex);
% % cplex�������ֵ
% opt_index=find(cplex_data(:,4)==2);
% ����ÿһ��ʵ��
for act=1:2:480
% disp(act)
rng(rn_seed,'twister');
% �ͷ��ɱ�
cost=costData(act,:);
actno=num2str(act);
%% ��ʼ������
fpath=['D:\�о�������\RLP-PS����\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
filename=[fpath,actNumber,'_',actno,'.RCP'];

% ��ȡ��Ŀ����ṹ
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);

fp_choice=['D:\�о�������\RLP-PS����\ʵ�����ݼ�\J',actNumber,'\'];

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
% ����������Ŀ�ѡ�
choice_depend=depend(:,1);
%% ���л��ִ�е���Ŀ��ֹ����
[est, all_eft ]= forward(projRelation, duration);
[lst,lft]=backward( projRelation, duration, all_eft(actNo));
% ��Ŀ�Ľ�ֹ����
deadline=floor(dtime*all_eft(actNo));
%% ֻ���Ǳ���ִ�л���ƾֲ��Ľ��Ľ��ȼƻ�����
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
%% ��ʼ��Ⱥ
% ��õ���Ŀ�ṹ
best_chrom=zeros(1,actNo+1);
best_chrom(1,actNo+1)=Inf;
% ��õĸ���
best_schedule=zeros(1,actNo);

% ���λ�Ƽ�
parent_implementList=zeros(2*pop,actNo+1);
parent_rkchromosome=zeros(2*pop,actNo);
parent_skchromosome=zeros(2*pop,actNo);
%% ����ʽ�㷨���ɳ�ʼ��
[initial_vl, initial_rk, initial_sk]=initialPopsizeFB(choice,depend,actNo,mandatory,req,duration,projRelation,nrpr,nrsu,su,pred,choiceList,resNo,cost,pop,deadline);
implementList=initial_vl;
rkchromosome=initial_rk;
skchromosome=initial_sk;
% ������ʼ��
for i=1:pop
    implement=implementList(i,1:actNo); % ��ǰȾɫ��
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    % ����ڵ��ľ������
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
    % ���翪ʼʱ�������ʼʱ��
    [es, ef]= forwardPass( projRelation_i, duration ,implement);
    [ls, lf]= backwardPass(projRelation_i, duration, deadline,implement);  
    rk=rkchromosome(i,:);
    sk=skchromosome(i,:);
    schedule= decoding(implement,es,ls,rk,sk,duration,pred_i,nrpr_i,d);

    % �жϽ��ȼƻ�������
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
% ����ļ�
setName = ['rlp_',num2str(actNo)];
fpathRoot=['D:\�о�������\RLP-PS����\�����Ͷ��-Annals of Operations Research\ANOR����\��ʼ��\u_kt\J',actNumber,'\',groupdata,'\'];
% disp(actNumber)
dt=num2str(dtime);
outResults=[act,best_chrom(actNo+1),best_schedule,best_chrom(1:actNo)];
outFile=[fpathRoot,num2str(end_schedules),'sch_',setName,'_dtime_',dt,'.txt'];
disp(['Instance ',num2str(act),' has been solved.']);
dlmwrite(outFile,outResults, '-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[]; 
end % ʵ��
end % ��ֹ����ѭ��
end % �ڼ�������
end % �����

