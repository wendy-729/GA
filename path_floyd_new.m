function d = path_floyd_new( n, w,implement)
d = w;

for k = 1 : n
    % 活动不执行不考虑中转
    if implement(k)==1
        for j = 1 : n  % 起点
            if d(j,k)==-Inf
				continue
            end
            if implement(j)==1
                for i = 1 : n %终点
                    % 活动不执行不考虑与其他活动的距离
                    if implement(i)==1
                        d(j,i) = max ( d(j,i), d(j,k) + d(k,i));
                    end
                end
            end
        end
    end
end