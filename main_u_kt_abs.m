% ������Ŀ�꺯����õĽ��ȼƻ�����һ��ͳһ��ָ�����
% 20211222
% Ŀ�꺯������
clc
clear
fcost='D:\�о�������\RLP-PS����\ʵ�����ݼ�\cost.txt';
costData = dlmread(fcost);
var_set = zeros(1,240);
u_kt2_set = zeros(240,1);
var_set_abs =  zeros(1,480);
abs_ukt_set = zeros(240,1);
% �����
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
dt=num2str(dtime);
% ��ȡ�õ��Ľ��ȼƻ�
fpath =['D:\�о�������\RLP-PS����\����\����ʵ����final\GA1\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
data = dlmread(fpath);
fpath_abs = ['C:\Users\ASUS\Desktop\GA_abs\J',actNumber,'\',groupdata,'\','5000sch_rlp_',num2str(actN+2),'_dtime_',dt,'.txt'];
data_abs = dlmread(fpath_abs);
% ����ÿһʵ��
count = 0;
for act=1:2:480
    count = count+1;
% for act=opt_index'
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
choice = dlmread(choicename);
depend = dlmread(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = dlmread(mandatoryname);
% disp(length(mandatory))
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = dlmread(choiceListname);
choiceList=unique(choiceList);
choiceList=sort(choiceList);
% ����������Ŀ�ѡ�
choice_depend=depend(:,1);
%% ���л��ִ�е���Ŀ��ֹ����
[est, all_eft ]= forward(projRelation, duration);
[lst,lft]=backward( projRelation, duration, all_eft(actNo));
% ��Ŀ�Ľ�ֹ����
deadline=floor(dtime*all_eft(actNo));
setName = ['rlp_',num2str(actNo)];

schedule = data(act, 4:3+actN+2);
vl = data(act, 36:35+actN+2);
obj = ric_objEvaluate(vl,schedule,actNo,resNo,duration,req,deadline, cost);
% disp(obj)
% var_set(count)=variance;
u_kt2_set(count) = obj;

% ������Դ��ʹ�����ľ���ֵ
schedule_abs = data_abs(count, 4:3+actN+2);
vl_abs = data_abs(count, 36:35+actN+2);
obj_abs = ric_objEvaluate(vl_abs,schedule_abs,actNo,resNo,duration,req,deadline, cost);

% var_set_abs(count) = variance_abs;
abs_ukt_set(count) = obj_abs;

% u_kt_set(act) = u_kt;
% u_ktt_set(act) = u_ktt;
% ��Դʹ������ƽ��

end %ʵ��

end % ��ֹ����
end % ����
end % �����
