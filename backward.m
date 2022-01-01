function [ lst, lft ] = backward( projRelation, duration, lftn )

activities=length(duration); %活动数量
lst=zeros(activities,1);
lft=zeros(activities,1);

lst(activities)=lftn;
lft(activities)=lftn;  %设定最后一个虚活动的lst,lft

for i=activities-1:-1:1  %对于每个活动
    lft(i)=lst(projRelation(i,2));
    if projRelation(i,1)>1
        
        for j=3:projRelation(i,1)+1 %每个活动的紧后活动
            if lft(i)>lst(projRelation(i,j))
                lft(i)=lst(projRelation(i,j));
            end
        end
    end
    
    lst(i)=lft(i)-duration(i);
    
end


end

