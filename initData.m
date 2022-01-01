function [projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename)
% dlmread(filename)将 ASCII 分隔的数值数据文件读取到矩阵 M
projNetwork=dlmread(filename);
% 活动数量
actNo=projNetwork(1,1);
% 资源数量
resNo=projNetwork(1,2);
% 资源的供应量
resNumber = projNetwork(2,1);
% 资源需求量
req=projNetwork(3:end,2:1+resNo);
% 工期
duration = projNetwork(3:end,1);
% 紧后活动的数量和编号
projRelation = projNetwork(3:end,resNo+2:end);
%紧后活动数量数组 nrsu
nrsu = projRelation(:,1);
% 紧后活动的编号
su = projRelation(:,2:end);
% 紧前活动数量
nrpr = zeros(actNo,1);
max_nrpr = 0;
for i = 1:actNo
    for j = 1:nrsu(i)
%         disp(su(i,j))
        nrpr(su(i,j)) = nrpr(su(i,j))+1;
        if max_nrpr < nrpr(su(i,j))
            max_nrpr = nrpr(su(i,j));
        end
    end
end
%紧前活动矩阵pred
pred = zeros(actNo,max_nrpr);
counter = zeros(actNo,1);
for i=1:actNo
    for j=1:nrsu(i)
        counter(su(i,j))=counter(su(i,j))+1;
        pred(su(i,j),counter(su(i,j)))=i;
    end
end