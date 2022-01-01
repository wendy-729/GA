function [ lst, lft ] = backwardPass( projRelation, duration, lftn,implement)
act=length(duration);
lst = zeros(act,1);
lft = zeros(act,1);
lst(act)=lftn;
lft(act)=lftn;
for i=act-1:-1:1
    if implement(i)==1
        for s=2:projRelation(i,1)+1
            b=projRelation(i,s);
            if implement(b)==1
                lft(i)=lst(b);
                break
            end
        end
        if projRelation(i,1)>1
            for j=2:projRelation(i,1)+1
                if implement(projRelation(i,j))==1
                    if lft(i)>lst(projRelation(i,j))
                        lft(i)=lst(projRelation(i,j));
                    end
                end
            end
        end
        lst(i)=lft(i)-duration(i);
    end
end
