function schedule = decoding(implement,est,lst,rk,sk,duration,pred,nrpr,d)
% disp('implement')
% implement
actNo=length(duration);
schedule = zeros(1,actNo);
es=est;
ls=lst;
act=1:actNo;

[~,sort_rk]=sort(rk,'descend');
% 活动列表
act_sort=act(sort_rk);
% disp(act_sort)
% scheduled=[1];
% disp(implement(11))
for i=1:actNo-1
    index=act_sort(i);
    if implement(index)==1     
        if index==1
            continue
        end
        schedule(index)=ceil(es(index)+sk(index)*(ls(index)-es(index)));
        if schedule(index)>ls(index)
            schedule(index)=ls(index);
        end
        % 更新没有调度的活动
        for j=i+1:actNo-1
            a=act_sort(j);
            if implement(a)==1
                es(a) = max(es(a), schedule(index)+d(index,a));
                ls(a) = min(ls(a), schedule(index)-d(a,index));        
            end
        end
    end
end
% 计算虚终止活动的开始时间
schedule(actNo)=schedule(pred(actNo,1))+duration(pred(actNo,1));
for i=1:nrpr(actNo)
    if implement(pred(actNo,i))==1
        if schedule(actNo)<schedule(pred(actNo,i))+duration(pred(actNo,i))
            schedule(actNo)=schedule(pred(actNo,i))+duration(pred(actNo,i));
        end
    end
end

