function [best_time,CB]=bestPosition(schedule,lst,ff,act,resNo,duration,req,deadline,cost,implement,actNo)
stime=schedule;
CB=schedule(actNo+1);
best_time=schedule(act);
for t=1:ff(act)
    temp=schedule(act)+t;
    if temp>lst(act)
        temp=lst(act);
    end
    stime(act)=temp;
    u_kt2=objEvaluate(implement,stime,actNo,resNo,duration,req,deadline,cost);
    PM=u_kt2;
    if PM<=CB
        CB=PM;
        best_time=temp;
    end
end
