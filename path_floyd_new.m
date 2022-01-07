function d = path_floyd_new( n, w,implement)
d = w;

for k = 1 : n
    % ���ִ�в�������ת
    if implement(k)==1
        for j = 1 : n  % ���
            if d(j,k)==-Inf
				continue
            end
            if implement(j)==1
                for i = 1 : n %�յ�
                    % ���ִ�в�������������ľ���
                    if implement(i)==1
                        d(j,i) = max ( d(j,i), d(j,k) + d(k,i));
                    end
                end
            end
        end
    end
end