function nei_implement=generateImplement(implement,choice,depend,actNo)
nei_implement=implement;
nei_implement(actNo+1)=Inf;
[r,c]=size(choice);
% �������һ��ѡ��
 b = randi([1 r],1,1);
 for j=b:r      
     e=choice(j,1);  % �����
     if nei_implement(e)==1  % ���ѡ�񴥷�
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
         % �����������״̬
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
%                    ѡ��û�д���
        % ������ǰ����������δ����
         if all(nei_implement(choice(j,2:end))==0)==0
             for p=2:c
                 nei_implement(choice(j,p))=0;
             end 
             % �����������״̬
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