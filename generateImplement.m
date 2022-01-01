function nei_implement=generateImplement(implement,choice,depend,actNo)
nei_implement=implement;
nei_implement(actNo+1)=Inf;
[r,c]=size(choice);
% 随机生成一个选择
 b = randi([1 r],1,1);
 for j=b:r      
     e=choice(j,1);  % 触发活动
     if nei_implement(e)==1  % 如果选择触发
         pos = randi([2 c],1,1);
         while nei_implement(choice(j,pos))==1
             pos = randi([2 c],1,1);
         end
         nei_implement(choice(j,pos))=1;
         for p=2:c
             if p~=pos
                 nei_implement(choice(j,p))=0;
             end
         end
         % 更新依赖活动的状态
         [rd,cd]=size(depend);
         for c_d=1:rd
            if nei_implement(depend(c_d,1))==1
                for d=depend(c_d,2:end)
                    nei_implement(d)=1;
                end
            else
                for d=depend(c_d,2:end)
                    nei_implement(d)=0;
                end
            end
         end
     else
%                    选择没有触发
        % 如果活动以前触发但现在未触发
         if all(nei_implement(choice(j,2:end))==0)==0
             for p=2:c
                 nei_implement(choice(j,p))=0;
             end 
             % 更新依赖活动的状态
             [rd,cd]=size(depend);
             for c_d=1:rd
                if nei_implement(depend(c_d,1))==1 
                    for d=depend(c_d,2:end)
                        nei_implement(d)=1;
                    end
                else
                    for d=depend(c_d,2:end)
                        nei_implement(d)=0;
                    end
                end
             end
         end
     end
 end