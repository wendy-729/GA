function [ est, eft ] = forward( projRelation, duration )

activities=length(duration); %活动数量
est=zeros(activities,1);
eft=zeros(activities,1);
%设置 第一个活动的紧后活动的est eft
for i1=2:projRelation(1,1)+1
    eft(projRelation(1,i1))=est(i1)+duration(projRelation(1,i1));
end

for i=2:activities-1 %从第二个活动开始，第i个活动
    for j=2:projRelation(i,1)+1 %每个活动的紧后活动
        if eft(i)>est(projRelation(i,j))
            est(projRelation(i,j))=eft(i);
            eft(projRelation(i,j))=est(projRelation(i,j))+duration(projRelation(i,j));
        end
    end
end


end

