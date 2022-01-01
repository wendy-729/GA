function [new_schedule] = rightShift1(schedule,ef,es,ls,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i)
%活动按最晚完成时间升序排
new_schedule=schedule;
est=es;
lst=ls;
[~,al]=sort(ef,'descend');
for i=1:actNo-1
    act=al(i);
    act1=al(i+1);
    if ef(act)==ef(act1)
        if es(act)<es(act1)
            al(i)=act1;
            al(i+1)=act;
        end
    end
end
al=al';
for i=al
    if implement(i)==1
        for j=1:nrpr_i(i)
            p=pred_i(i,j);
            if implement(p)==1
%                 est(i) = max(est(i), new_schedule(p)+d(p,i));
                if est(i)<new_schedule(p)+duration(p)
                    est(i)=new_schedule(p)+duration(p);
                end
            end
        end
        for j=1:nrsu_i(i)
            s=su_i(i,j);
            if implement(s)==1
%                 lst(i) = min(lst(i), new_schedule(s)-d(i,s));  
                if lst(i)>new_schedule(s)-duration(i)
                    lst(i)=new_schedule(s)-duration(i);
                end
            end
        end

        tf=lst-est;
%         [best_time]=bestPosition(new_schedule,lst,tf,i,resNo,duration,req,deadline,implement,actNo);
        
        [best_time,cb]=bestPosition(new_schedule,lst,tf,i,resNo,duration,req,deadline,cost,implement,actNo);
        new_schedule(i)=best_time;
%         new_schedule(actNo+1)=objEvaluate(implement,new_schedule,actNo,resNo,duration,req,deadline,cost);
        new_schedule(actNo+1)=cb;
    end
end
        
