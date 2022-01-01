function [new_schedule] = rightShift(ff,schedule,ef,ls,es,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i)
%活动按最晚完成时间升序排
new_schedule=schedule;
[~,al]=sort(ef,'descend');
for i=1:actNo-1
    act=al(i);
    act1=al(i+1);
    if ef(act)==ef(act1)
        if es(act)<es(act1)
            al(i)=act1;
            al(i+1)=act;
        end
        if es(act)==es(act1)
            if ff(act)<ff(act1)
                al(i)=act1;
                al(i+1)=act;
            end
        end
    end
end
% 降序，结果更差'
al=al';
for i=al
    if implement(i)==1 && ff(i)~=0
        for j=1:nrpr_i(i)
            p=pred_i(i,j);
            if implement(p)==1
%                 est(i) = max(est(i), new_schedule(p)+d(p,i));
                if es(i)<new_schedule(p)+duration(p)
                    es(i)=new_schedule(p)+duration(p);
                end
            end
        end
        for j=1:nrsu_i(i)
            s=su_i(i,j);
            if implement(s)==1
%                 lst(i) = min(lst(i), new_schedule(s)-d(i,s));  
                if ls(i)>new_schedule(s)-duration(i)
                    ls(i)=new_schedule(s)-duration(i);
                end
            end
        end
        ef=es+duration;
        temp_es=Inf;
%         disp(ff(i))
        for j=1:nrsu_i(i)
            % 紧后活动
            jinhou=su_i(i,j);
            if implement(jinhou)==1
                temp_es=min(temp_es,es(jinhou));
            end
        end
        ff(i)=temp_es-ef(i);
        [best_time,cb]=bestPosition(new_schedule,ls,ff,i,resNo,duration,req,deadline,cost,implement,actNo);
        new_schedule(i)=best_time;
        new_schedule(actNo+1)=cb;
        
%         [best_time]=bestPosition(new_schedule,ls,ff,i,resNo,duration,req,deadline,implement,actNo);
%        
%         new_schedule(i)=best_time;
%         new_schedule(actNo+1)=objEvaluate(implement,new_schedule,actNo,resNo,duration,req,deadline,cost);
    end
end
        
