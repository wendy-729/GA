function [best_time,CB]=leftPosition(schedule,bff,est,act,resNo,duration,req,deadline,cost,implement,actNo)
stime=schedule;
CB=schedule(actNo+1);
best_time=schedule(act);
for t=1:bff(act)
    temp=schedule(act)-t;
     if temp<est(act)
        temp=est(act);
    end
    stime(act)=temp;
    u_kt2=objEvaluate(implement,stime,actNo,resNo,duration,req,deadline,cost);
    PM=u_kt2;
    if PM<=CB
        CB=PM;
        schedule(actNo+1)=CB;
        best_time=temp;
    end
end