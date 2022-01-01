function feasible=projectFeasible(implement,choice,depend)
feasible1=1;
feasible=0;
% 随机确定可选活动
[r,c]=size(choice);
[rd,cd]=size(depend);
for i=1:r
    if implement(choice(i,1))==1
        a=implement(choice(i,2:end));
%         disp(length(a(a==1)))
        if length(a(a==1))~=1
            feasible1=0;
            break
        end
    end
end
% 依赖活动
feasible2=1;
for i=1:rd
    if implement(depend(i,1))==1
        a=implement(depend(i,2:end));
        if length(a(a==1))~=cd-1
            feasible2=0;
            break
        end
    end
end
if feasible1+feasible2==2
    feasible=1;
else
    feasible=0;
end
% if feasible==0
% %     disp(feasible1)
% %     disp(choice)
% %     disp(implement)
% %     disp(feasible2)
% end
