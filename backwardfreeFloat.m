function bff=backwardfreeFloat(ls,lf,actNo,nrpr,pred,implement)
bff=zeros(1,actNo);
for i=2:actNo
    if implement(i)
        temp_es=-Inf;
        for j=1:nrpr(i)
            % ½ôºó»î¶¯
            jinqian=pred(i,j);
            if implement(jinqian)==1
                temp_es=max(temp_es,lf(jinqian));
            end
        end
%         disp(temp_es)
%         disp(i)
        bff(i)=ls(i)-temp_es;
%         disp(bff(i))
%         disp('----------------')
    end
end
% ff(actNo)=deadline-ef(actNo);
        