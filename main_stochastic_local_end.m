% �ֲ��Ľ������
clc
clear 
% profile on
% ������������ӣ��������
global rn_seed; % random number seed; 
rn_seed = 317731;
% �Ŵ��㷨����
para=[50,0.95,0.1];
pop=para(1);
p_cross=para(2);
p_mutation=para(3);
% 480��ʵ���ĳͷ��ɱ�
fcost='D:\�о�������\RLP-PS����\ʵ�����ݼ�\cost.txt';
fpath_clpex='D:\�о�������\RLP-PS����\ʵ����\CPLEX\J60\';
costData = initfile(fcost);
% �����
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
dt=num2str(dtime);
% % ��ȡCPLEX�е����Ž�
% fp_cplex=[fpath_clpex,'sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
% cplex_data=dlmread(fp_cplex);
% % cplex�������ֵ
% opt_index=find(cplex_data(:,4)==2);
% % disp(opt_index)
% ����ÿһ��ʵ��
for act=1:480
% for act=opt_index'
% for act=1:10:600
%��ֹ����
end_schedules=5000;
disp(act)
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
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);
choiceList=unique(choiceList);
choiceList=sort(choiceList);
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
% disp((lsm-esm)')
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
best_es=zeros(1,actNo);
best_ls=zeros(1,actNo);
% ���λ�Ƽ�
parent_implementList=zeros(2*pop,actNo+1);
parent_rkchromosome=zeros(2*pop,actNo);
parent_skchromosome=zeros(2*pop,actNo);
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
%% ������ɳ�ʼ��Ⱥ
% ����ʵʩ���Ϊ1
for i=1:pop
    for j=mandatory
        implementList(i,j)=1;
    end
end
% ����������Ŀ�ѡ�
choice_depend=depend(:,1);
% ���ȷ����ѡ�
[r,c]=size(choice);
for i=1:pop
    for j=1:r
        if implementList(i,choice(j,1))==1
            index = randi([2 c],1,1);  % �ڿ�ѡ���������ѡ��һ���
            a = choice(j,index);
            implementList(i,a)=1;
            % ����ִ�е����������ѡ������ �����ݿ�ѡ���ִ��״̬�����������ִ��״̬
            if any(a==choice_depend)==1
%             if find(choice_depend==a)~=0
                index=find(choice_depend==a);
               for d=depend(index,2:end)     % ���������
                    implementList(i,d)=1;
               end 
            end
        end
    end
end
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
%         disp('������')
    end
    if implementList(i,actNo+1)<best_chrom(1,actNo+1)
        best_chrom=implementList(i,:);
        best_schedule=schedule;
        best_es=es;
        best_ls=ls;
        best_nrpr=nrpr_i;
        best_nrsu=nrsu_i;
        best_su=su_i;
        best_pred=pred_i;
    end
end 
parent_implementList(1:pop,:)=implementList;
parent_rkchromosome(1:pop,:)=rkchromosome;
parent_skchromosome(1:pop,:)=skchromosome;
%% ����������õ�Ⱦɫ��
tic;
nr_schedules=pop;
% end_schedules=end_schedules-sum_tt;
count1=0;
count2=0;
% disp(end_schedules)
iter=0;
while nr_schedules<end_schedules-sum_tt
    iter = iter+1;
%% ���������
    flag = 0;
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
    %% �����Ӹ���
    for i=1:pop 
        projRelation_i=projRelation;
        nrpr_i=nrpr;
        nrsu_i=nrsu;
        su_i=su;
        pred_i=pred;
        implement=child_implement(i,1:actNo); % ��ǰȾɫ��
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
        
        if nr_schedules+sum_tt+1>1000 && count1==0
            count1=count1+1;
            % �ֲ��Ľ�
            chrom=best_chrom;
            impro_lst=best_ls;
            impro_est=best_es;
            tt=impro_lst-impro_est;

            [~,index]=sort(tt);
            prList=index';
            [schedule1,cb,es,ls]=improvement1(prList,impro_est,impro_lst,duration,best_su,best_pred,best_nrpr,best_schedule,best_chrom,best_nrsu,resNo,cost,req,deadline);
            chrom(actNo+1)=cb;
            cputime1=toc;
            outResults1=[act,chrom(actNo+1),cputime1,schedule1,chrom,nr_schedules];
        end
        if nr_schedules+sum_tt+1>3000 && count2==0
            count2=count2+1;
            % �ֲ��Ľ�
            chrom=best_chrom;
            impro_lst=best_ls;
            impro_est=best_es;
            tt=impro_lst-impro_est;
            
            [~,index]=sort(tt);
            prList=index';
            [schedule1,cb,es,ls]=improvement1(prList,impro_est,impro_lst,duration,best_su,best_pred,best_nrpr,best_schedule,best_chrom,best_nrsu,resNo,cost,req,deadline);
            chrom(actNo+1)=cb;
            cputime1=toc;
            outResults2=[act,chrom(actNo+1),cputime1,schedule1,chrom,nr_schedules];
        end      
        if nr_schedules+1+sum_tt>end_schedules
            flag=1;
            break
        end
        % ����
        schedule= decoding(implement,es,ls,rk,sk,duration,pred_i,nrpr_i,d);
         % �жϽ��ȼƻ�������
        if scheduleFeasible(schedule,actNo,nrsu_i,su_i,implement,duration)
            child_implement(i,actNo+1)=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline,cost);
        else
            child_implement(i,actNo+1)=Inf;
        end
        if child_implement(i,actNo+1)<best_chrom(1,actNo+1)
            best_chrom=child_implement(i,:);
            best_schedule=schedule;
            best_es=es;
            best_ls=ls;
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_su=su_i;
            best_pred=pred_i;
        end
        nr_schedules=nr_schedules+1;
    end 
    if flag==1
        break;
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
%% �ֲ��Ľ�
impro_est=best_es;
impro_lst=best_ls;
% ����ʱ���������С���һ�����ȼƻ����е��жϡ�
tt=impro_lst-impro_est;
[~,index]=sort(tt);
prList=index';
[best_schedule,cb,es,ls]=improvement1(prList,impro_est,impro_lst,duration,best_su,best_pred,best_nrpr,best_schedule,best_chrom,best_nrsu,resNo,cost,req,deadline);
best_chrom(actNo+1)=cb;
cputime=toc;
% ����ļ�
setName = ['rlp_',num2str(actNo)];
fpathRoot=['C:\Users\ASUS\Desktop\����ʵ����final\GA1\J',actNumber,'\'];
% 
dt=num2str(dtime);
outResults=[act,best_chrom(actNo+1),cputime,best_schedule,best_chrom,nr_schedules];
outFile=[fpathRoot,groupdata,'\',num2str(end_schedules),'sch_',setName,'_dtime_end1_',dt,'.txt'];
% 
outFile1=[fpathRoot,groupdata,'\',num2str(1000),'sch_',setName,'_dtime_end1_',dt,'.txt'];
outFile2=[fpathRoot,groupdata,'\',num2str(3000),'sch_',setName,'_dtime_end1_',dt,'.txt'];
disp(['Instance ',num2str(act),' has been solved.']);
dlmwrite(outFile,outResults, '-append', 'newline', 'pc',  'delimiter', '\t');
dlmwrite(outFile1,outResults1, '-append', 'newline', 'pc',  'delimiter', '\t');
dlmwrite(outFile2,outResults2, '-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[]; 
outResults1=[];
outResults2=[];
end % ʵ��
end % ��ֹ����ѭ��
end % �ڼ�������
end % �����
