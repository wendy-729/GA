function [best_schedule]=FBHA(best_schedule,schedule,fff,ef,es,ls,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,nrsu_i,pred_i,su_i)
% 向右移动
[new_schedule] = rightShift(fff,schedule,ef,ls,es,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i);
if new_schedule(actNo+1)<best_schedule(actNo+1)
    best_schedule=new_schedule;
end
%% 在总时差内调整
[new_schedule] = rightShift1(new_schedule,ef,es,ls,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i);
if new_schedule(actNo+1)<best_schedule(actNo+1)
    best_schedule=new_schedule;
end
%% 左移动
new_schedule = leftShift(new_schedule,es,ls,implement,resNo,duration,req,deadline,cost,actNo,nrpr_i,pred_i,nrsu_i,su_i);
if new_schedule(actNo+1)<best_schedule(actNo+1)
    best_schedule=new_schedule;
end