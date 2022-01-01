function d = path_floyd( n, w,implement)
d = w;

for k = 1 : n
    % 活动不执行不考虑中转
    if implement(k)==1
        for j = 1 : n
            if implement(j)==1
                for i = 1 : n
                    % 活动不执行不考虑与其他活动的距离
                    if implement(i)==1
                        d(i,j) = max ( d(i,j), d(i,k) + d(k,j));
                    end
                end
            end
        end
    end
end