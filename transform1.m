function [rk, sk]=transform1(schedule,implement,actNo,projRelation,deadline,duration,nrpr,nrsu,pred,su)
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
% disp(rk)
[~,rk_sort]=sort(rk,'descend');
% disp(rk_sort)
% 确定sk
for i=1:length(rk_sort)
    act=rk_sort(i);
    if implement(act)==1
        % 计算最早开始和最晚开始时间
        for j=1:nrpr(act)     
            p=pred(act,j);
    %         disp(p)
            if implement(p)==1
                es(act)=max(es(act),schedule(p)+duration(p));
            end
        end
        % i的紧后活动
        for s=1:nrsu(act)
    %       disp('紧后')
            sc=su(act,s);
            if implement(sc)==1  
                ls(act)=min(ls(act),schedule(sc)-duration(act));
            end
        end
        if ls(act)==es(act)
            continue
        end
         sk(act)=(schedule(act)-es(act))/(ls(act)-es(act));
    end
end
    


    
    


