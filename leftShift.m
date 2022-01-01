function new_schedule = leftShift(schedule,es,ls,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i)
%活动按最晚完成时间升序排
new_schedule=schedule;
est=es;
lst=ls;
lft=lst+duration;
[~,al]=sort(ls);
al=al';
for i=al
    if implement(i)==1 && i~=actNo
        for j=1:nrpr_i(i)
            p=pred_i(i,j);
            if implement(p)==1
                if est(i)<new_schedule(p)+duration(p)
                    est(i)=new_schedule(p)+duration(p);
                end
            end
        end
        for j=1:nrsu_i(i)
            s=su_i(i,j);
            if implement(s)==1
                if lst(i)>new_schedule(s)-duration(i)
                    lst(i)=new_schedule(s)-duration(i);
                end
            end
        end
        lft=lst+duration;
        
        % 动态更新bff
        bff=backwardfreeFloat(lst,lft,actNo,nrpr_i,pred_i,implement);

        [best_time,cb]=leftPosition(new_schedule,bff,est,i,resNo,duration,req,deadline,cost,implement,actNo);
        new_schedule(i)=best_time;
        new_schedule(actNo+1)=cb;
%         [best_time]=leftPosition1(new_schedule,bff,est,i,resNo,duration,req,deadline,cost,implement,actNo);
%         new_schedule(i)=best_time;
%         new_schedule(actNo+1)=objEvaluate(implement,new_schedule,actNo,resNo,duration,req,deadline,cost);
    end
end
        
