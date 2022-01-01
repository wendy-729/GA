function [rk, sk]=transform(schedule,implement,actNo,projRelation,deadline,duration)
rk=zeros(1,actNo);
sk=zeros(1,actNo);
% 执行的活动
implement_act=find(implement ==1);
[~,partical_al]=sort(schedule(implement_act));

al=implement_act(partical_al);
% disp(al)
% 计算es和ls
[es, ef]= forwardPass( projRelation, duration ,implement);
[ls, lf]= backwardPass(projRelation, duration, deadline,implement);
% 确定每个活动的优先值
m=length(al)-1;
for i=2:length(al)-1
    act=al(i);
    rk(act)=m/length(al);
    m=m-1;
end
% 确定sk
for i=2:length(al)-1
    act=al(i);
    if ls(act)==es(act)
        continue
    end
    sk(act)=(schedule(act)-es(act))/(ls(act)-es(act));
end


    
    


