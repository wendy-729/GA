function [best_schedule,cb,est,lst] = improvement1(prList,es,ls,duration,su,pred,nrpr,best_schedule,best_chrom,nrsu,resNo,c,req,deadline)
est=es;
lst=ls;
% count=0; 
actNo=length(duration);
cb=best_chrom(actNo+1);
for i=prList
if best_chrom(i)==1
    schedule=best_schedule;
    
    improvement=0;
    % i的紧前活动
    for j=1:nrpr(i)     
        p=pred(i,j);
        if best_chrom(p)==1
            est(i)=max(est(i),schedule(p)+duration(p));
        end
    end
    % i的紧后活动
    for s=1:nrsu(i)
%       disp('紧后')
        sc=su(i,s);
        if best_chrom(sc)==1  
            lst(i)=min(lst(i),schedule(sc)-duration(i));
        end
    end
    for t=est(i):lst(i)
        schedule(i)=t;
        PM=objEvaluate(best_chrom,schedule,actNo,resNo,duration,req,deadline, c);
        if PM<cb
            cb=PM;
            best_time=t;
            improvement=1;
        end
    end
    if improvement==1
        best_schedule(i)=best_time;     
    end
end
end