function [ lst, lft ] = backward( projRelation, duration, lftn )

activities=length(duration); %�����
lst=zeros(activities,1);
lft=zeros(activities,1);

lst(activities)=lftn;
lft(activities)=lftn;  %�趨���һ������lst,lft

for i=activities-1:-1:1  %����ÿ���
    lft(i)=lst(projRelation(i,2));
    if projRelation(i,1)>1
        
        for j=3:projRelation(i,1)+1 %ÿ����Ľ���
            if lft(i)>lst(projRelation(i,j))
                lft(i)=lst(projRelation(i,j));
            end
        end
    end
    
    lst(i)=lft(i)-duration(i);
    
end


end

