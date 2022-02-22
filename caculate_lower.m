% �½� ֻ���Ǳ���ִ�л
clc
clear 
% profile on
% ������������ӣ��������
global rn_seed; % random number seed; 
rn_seed = 317731;

% 480��ʵ���ĳͷ��ɱ�
fcost='D:\�о�������\RLP-PS����\ʵ�����ݼ�\cost.txt';
costData = initfile(fcost);
% ��ȡCPLEX�������
fpath_clpex='D:\�о�������\RLP-PS����\ʵ����\CPLEX\J30\';
% �����
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
%% ����ļ�·��
setName = ['rlp_',num2str(actN)];
fpathRoot=['C:\Users\ASUS\Desktop\'];
dt=num2str(dtime);
act_count=0;

% ��ȡCPLEX�е����Ž�
fp_cplex=[fpath_clpex,'sch_rlp_32_dtime_',dt,'.txt'];
cplex_data=dlmread(fp_cplex);
% cplex�������ֵ
opt_index=find(cplex_data(:,4)==1);
% disp(opt_index)
% ����ÿһ��ʵ��
for act=opt_index'
% for act=1:480
% disp(act)
rng(rn_seed,'twister');
act_count=act_count+1;
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
%% ���л��ִ�е���Ŀ��ֹ����
[est, all_eft ]= forward(projRelation, duration);
% [lst,lft]=backward( projRelation, duration, all_eft(actNo));
% ��Ŀ�Ľ�ֹ����
deadline=floor(dtime*all_eft(actNo));
tic
% ƽ����Դ����
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
%% д���ļ�
outResults=[act,ukt,cputime];
outFile=[fpathRoot,'lower_m',setName,'_dt_',dt,'_','.txt'];
% % ʱ��
% outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement];
% outFile=[fpathRoot,num2str(end_time),'s_sch_de_target_ssgs1_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');

outResults=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % ʵ��
end %��ֹ����
end % ����
end % �����