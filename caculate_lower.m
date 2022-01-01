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
% �����
for actN=[30]
actNumber=num2str(actN);
%% ������һ������
for gd=1:1
groupdata= num2str(gd);
for dtime=[1.0]
%% ����ļ�·��
setName = ['rlp_',num2str(actN)];
fpathRoot=['C:\Users\ASUS\Desktop\ʵ����\GA\J',actNumber,'\'];
dt=num2str(dtime);
act_count=0;

% ����ÿһ��ʵ��
for act=1:1
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

end % ʵ��
end %��ֹ����
end % ����
end % �����