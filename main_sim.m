% ���㷨�������̽��оֲ��Ľ�����ʼ��������ʽ�㷨���ɡ�
clc
clear 
% profile on
% ������������ӣ��������
global rn_seed; % random number seed; 
rn_seed = 317731;
% �Ŵ��㷨����
para=[50,0.9,0.1];
pop=para(1);
p_cross=para(2);
p_mutation=para(3);
all_obj=[];
%��ֹ����
end_schedules=5000;
% 480��ʵ���ĳͷ��ɱ�
% fcost='E:\zlw\ʵ�����ݼ�\cost.txt';
fcost='D:\�о�������\RLP-PS����\ʵ�����ݼ�\cost.txt';
costData = initfile(fcost);
% fpath_clpex='D:\�о�������\RLP-PS����\ʵ����\CPLEX\J30\';
% �����
count_sim = 0;
schedule_set = zeros(1000,32);
vl_set = zeros(1000,32);
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
dt=num2str(dtime);
% % ��ȡCPLEX�е����Ž�
% fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
% cplex_data=dlmread(fp_cplex);
% % cplex�������ֵ
% opt_index=find(cplex_data(:,4)==2);
% disp(opt_index)
% ����ÿһ
for act=6:6
% for act=opt_index'
disp(act)
rng(rn_seed,'twister');
% �ͷ��ɱ�
cost=costData(act,:);
actno=num2str(act);
%% ��ʼ������
% fpath=['E:\zlw\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
fpath=['D:\�о�������\RLP-PS����\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
filename=[fpath,actNumber,'_',actno,'.RCP'];

% ��ȡ��Ŀ����ṹ
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);

fp_choice=['D:\�о�������\RLP-PS����\ʵ�����ݼ�\J',actNumber,'\'];
% fp_choice=['E:\zlw\ʵ�����ݼ�\J',actNumber,'\'];
% fp_choice=['E:\zlw\����ʵ��\���ݼ�\J',actNumber,'\'];

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
%  % ����������¾ֲ��Ľ������Ľ��ȼƻ����������л��ִ�С�
% sum_tt=0;
% for ii=1:actNo
%     sum_tt=sum_tt+(lst(ii)-est(ii));
% end
% sum_tt=floor(sum_tt/actNo);
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
% disp(implementList(:,actNo+1))
% disp(skchromosome)

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
        count_sim = count_sim+1;
%         disp(length(schedule))
%         disp(schedule_set(count_sim,:))
        schedule_set(count_sim,:)=schedule;
        vl_set(count_sim,:)=implement(1:actNo);
    else
        implementList(i,actNo+1)=Inf;
%         disp('������')
    end
    if implementList(i,actNo+1)<best_chrom(1,actNo+1)
        best_chrom=implementList(i,:);
        best_schedule=schedule;
    end
end 
% disp(best_chrom(:,actNo+1))
parent_implementList(1:pop,:)=implementList;
parent_rkchromosome(1:pop,:)=rkchromosome;
parent_skchromosome(1:pop,:)=skchromosome;
%% ����������õ�Ⱦɫ��
tic;
nr_schedules=pop;
count1=0;
count2=0;
while nr_schedules<end_schedules
%% ���������
    child_rkchromosome=rkchromosome;
    child_skchromosome=skchromosome;
    for i=1:2:pop
        if rand>p_cross
            continue;
        end
        % ����λ��
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
%% ʵʩ�б���
    % ��ʼ��ʵʩ�б�
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
         [r,~]=size(choice); % �У���
         b = randi([1 r],1,1);
         for e=1:b
             % ѡ���еĿ�ѡ�
            for j=choice(e,2:end)
                child_implement(i,j)=implementList(i,j);  %Ů��
                child_implement(i+1,j)=implementList(i+1,j);   % ����
                % �̳������
                if any(j==choice_depend)==1
                   index=find(choice_depend==j);
                   for d=depend(index,2:end)     % ���������
                        child_implement(i,d)=implementList(i,d);
                        child_implement(i+1,d)=implementList(i+1,d); 
                   end
                end
            end
         end
         if b<r
            for c=b+1:r
                e1=choice(c,1);
                % Ů��
                if child_implement(i,e1)==1  % ѡ��e������
                    if implementList(i+1,e1)==1  % ѡ��e�����״���
                        for j=choice(c,2:end)
                            child_implement(i,j)=implementList(i+1,j);
                             % �̳������
                             if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                                   index=find(choice_depend==j);
                                   for d=depend(index,2:end)    
                                        child_implement(i,d)=implementList(i+1,d);
                                   end 
                             end
                        end
                    else
                        % �ڸ�����ѡ��eû�б��������̳�ĸ�׵�
                        for j=choice(c,2:end)
                            child_implement(i,j)=implementList(i,j);
                            % �̳������
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
                % ����
                if child_implement(i+1,e1)==1
                    if implementList(i,e1)==1  % ��ĸ�״���
                        for j=choice(c,2:end)
                            child_implement(i+1,j)=implementList(i,j);
                            % �̳������
                            if any(j==choice_depend)==1
%                             if find(choice_depend==j)~=0
                                index=find(choice_depend==j);
                               for d=depend(index,2:end)    
                                    child_implement(i+1,d)=implementList(i,d);
                               end 
                            end
                        end
                    else
                        % ��ĸ����ѡ��eû�б������̳и��׵�
                        for j=choice(c,2:end)
                            child_implement(i+1,j)=implementList(i+1,j);
                            % �̳������
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
%% �������λ�Ƽ�����
    for i=1:pop
        pro=rand(1,actNo);
        % �����λ��
        pos_mu=find(pro<p_mutation);
        child_rkchromosome(i,pos_mu)=rand(1,length(pos_mu));
        child_skchromosome(i,pos_mu)=rand(1,length(pos_mu));
    end
    child_rkchromosome(:,1)=0;
    child_skchromosome(:,1)=0; 
    child_rkchromosome(:,end)=0;
    child_skchromosome(:,end)=0; 
%% ʵʩ�б����
%     child_implement=mutation(child_implement,choice,depend,pop,p_mutation);
    for i=1:pop
        if rand<p_mutation
            [r,c]=size(choice);
             b = randi([1 r],1,1);
             for j=b:r      
                 e=choice(j,1);  % �����
                 if child_implement(i,e)==1  % ���ѡ�񴥷�
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
                     % �����������״̬
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
%                    ѡ��û�д���
                    % ������ǰ����������δ����
                     if all(child_implement(i,choice(j,2:end))==0)==0
                         for p=2:c
                             child_implement(i,choice(j,p))=0;
                         end 
                         % �����������״̬
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
    % �����Ӹ���
    flag=0;
    for i=1:pop 
        flag_end=0;
        projRelation_i=projRelation;
        nrpr_i=nrpr;
        nrsu_i=nrsu;
        su_i=su;
        pred_i=pred;
        implement=child_implement(i,:); % ��ǰȾɫ��
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation_i,nrpr_i,nrsu_i,su_i,pred_i,choiceList,implement,actNo);
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
        rk=child_rkchromosome(i,:);
        sk=child_skchromosome(i,:);
        
         tt=ls-es;
         % �����������µ��½�[����ִ�еĻ]
        sum_tt=0;
        for ii=1:actNo
            if implement(ii)==1
                sum_tt=sum_tt+tt(ii);
            end
        end
        sum_tt=floor(sum_tt/sum(implement(1:actNo)));
        
        cputime1=toc;
        if count1==0 && (nr_schedules+1>=1000||nr_schedules+1+sum_tt>=1000)
%             disp(nr_schedules)
            count1=count1+1;
            outResults1=[act,best_chrom(actNo+1),cputime1,best_schedule,best_chrom,nr_schedules];
        end
        if count2==0 && (nr_schedules+1>=3000||nr_schedules+1+sum_tt>=3000)
%             disp(nr_schedules)
            count2=count2+1;
            outResults2=[act,best_chrom(actNo+1),cputime1,best_schedule,best_chrom,nr_schedules];
        end
        if nr_schedules+1>=end_schedules|| nr_schedules+sum_tt+1>end_schedules
            flag_end=1;
        end
        if flag_end==1
            flag=1;
            break
        end    
         %% ���۸���
        schedule = decoding(implement,es,ls,rk,sk,duration,pred_i,nrpr_i,d);
        if scheduleFeasible(schedule,actNo,nrsu_i,su_i,implement,duration)
            implement(actNo+1)=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline,cost);
            count_sim = count_sim+1;
            schedule_set(count_sim,:)=schedule;
            vl_set(count_sim,:)=implement(1:actNo);
        else
            nr_schedules=nr_schedules+1;
            continue
        end
        nr_schedules=nr_schedules+1;
        % �ֲ��Ľ�
       
        [~,index]=sort(tt);
        prList=index';
        [schedule,cb,es,ls]=improvement1(prList,es,ls,duration,su_i,pred_i,nrpr_i,schedule,implement,nrsu_i,resNo,cost,req,deadline);
        count_sim = count_sim+1;
        schedule_set(count_sim,:)=schedule;
        vl_set(count_sim,:)=implement(1:actNo);
        child_implement(i,actNo+1)=cb;
        
        nr_schedules=nr_schedules+sum_tt;

        if child_implement(i,actNo+1)<best_chrom(1,actNo+1)
            best_chrom=child_implement(i,:);
            best_schedule=schedule;
        end
        if  nr_schedules+1>=end_schedules||nr_schedules+1+sum_tt>=end_schedules
            flag=1;
            break;
        end
    end 
    if flag==1
        break
    end
    parent_implementList(pop+1:2*pop,:)=child_implement;
    p=parent_implementList;
%  ѡ����õ�pop������Ϊ����
    [~,fitIndex]=sort(parent_implementList(:,actNo+1));
    fitIndex=fitIndex(1:pop);
    implementList=p(fitIndex,:);
    rkchromosome=parent_rkchromosome(fitIndex,:);
    skchromosome=parent_skchromosome(fitIndex,:);
    
    parent_implementList(1:pop,:)=implementList;
    parent_rkchromosome(1:pop,:)=rkchromosome;
    parent_skchromosome(1:pop,:)=skchromosome;
end  % ��������
% disp(best_chrom(actNo+1))
cputime=toc;
% ����ļ�
setName = ['rlp_',num2str(actNo)];
fpathRoot=['C:\Users\ASUS\Desktop\RLP-PS-SIM\J',actNumber,'\'];
% fpathRoot=['E:\zlw\����ʵ��\ʵ����\GA\J',actNumber,'\'];
% disp(actNumber)
dt=num2str(dtime);

 outResults= schedule_set;
 
% outResults=[act,best_chrom(actNo+1),cputime,best_schedule,best_chrom,nr_schedules];
outFile=[fpathRoot,groupdata,'\',num2str(end_schedules),'sch_',setName,'_dtime_correct_',dt,'.txt'];

outFile1=[fpathRoot,groupdata,'\',num2str(1000),'sch_',setName,'_dtime_vl_',dt,'.txt'];
% outFile2=[fpathRoot,groupdata,'\',num2str(3000),'sch_',setName,'_dtime_correct_',dt,'.txt'];
disp(['Instance ',num2str(act),' has been solved.']);
dlmwrite(outFile,outResults, '-append', 'newline', 'pc',  'delimiter', '\t');
dlmwrite(outFile1,vl_set, '-append', 'newline', 'pc',  'delimiter', '\t');
% dlmwrite(outFile2,outResults2, '-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[]; 
outResults1=[];
% outResults2=[];
end % ʵ��
end % ��ֹ����ѭ��
end % �ڼ�������
end % �����
