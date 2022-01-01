function [implement]=resourcePr(choice,depend,actNo,mandatory,req,duration)
%% 初始解 根据每个活动对资源的总需求量选择活动 
implement=zeros(1,actNo+1); 
implement(actNo+1)=Inf; 
for i=mandatory     
    implement(i)=1; 
end
% 触发依赖活动的可选活动
choice_depend=depend(:,1);
% 每个活动对资源的总需求量
sum_req=sum(req,2); 
% disp(sum_req)
% 随机生成一个位置 
[r,~]=size(choice); 
for i=1:r     
    if implement(choice(i,1))==1 
        implement_act=choice(i,2);
        choice_set=choice(i,2:end);
        choice_res=zeros(1,length(choice_set));
        for j=1:length(choice_set)
            % 可选活动的资源需求
            act=choice_set(j);
            res=sum_req(act);
            if any(act==choice_depend)==1
                index=find(choice_depend==act);
                for d=depend(index,2:end)     % 更新依赖活动
                    res=res+sum_req(d);
                end 
            end
            choice_res(j)=res;
        end
%         disp(choice_res)
       [min_req,index]=min(choice_res);
        min_len=length(find(choice_res==min_req));
        if min_len==1           
            implement_act=choice(i,index+1);
        else
            %存在多个则选择工期最短的活动                 
            dur=duration(choice(i,2:end));              
            [min_dur,dur_index]=sort(dur);               
            min_act=min_dur(1);              
            for a=choice(i,2:end)                   
                if duration(a)==min_act                       
                    implement_act=a;
                    break;
                end
            end         
        end 
        implement(implement_act)=1;
        % 依赖活动
        if any(implement_act==choice_depend)==1
            index=find(choice_depend==implement_act);
           for d=depend(index,2:end)     % 更新依赖活动
                implement(d)=1;
           end 
        end
    end
end
