function [ est, eft ] = forwardPass( projRelation, duration ,implement)
act=length(duration);
est = zeros(act,1);
eft = zeros(act,1);
% 设置 第一个活动的紧后活动的est eft
for i=2:projRelation(1,1)+1
    if implement(projRelation(1,i))==1
        eft(projRelation(1,i))=est(1)+duration(projRelation(1,i));
    end
end
for i=2:act-1
    if implement(i)==1 % 如果活动实施
        for j=2:projRelation(i,1)+1  % 活动的紧后活动
            if implement(projRelation(i,j))==1
                if eft(i)>est(projRelation(i,j))
                    est(projRelation(i,j))=eft(i);
                    eft(projRelation(i,j))=est(projRelation(i,j))+duration(projRelation(i,j));
                end
            end
        end
    end
end
        
    