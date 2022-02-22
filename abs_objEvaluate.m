function u_kt2=abs_objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline, c)
u=zeros(resNo,deadline);
u_kt2=0;
for i=1:actNo
    if implement(i)==1
        for k=1:resNo
            for t=(schedule(i)+1):(schedule(i)+duration(i))
                u(k,t)=u(k,t)+req(i,k);
            end
        end
    end
end
% disp(u)
for k=1:resNo
    for t=2:schedule(actNo)+1
        temp = u(k,t)-u(k,t-1);
        if  u(k,t)-u(k,t-1)<0
             temp = u(k,t-1)-u(k,t);
        end
        u_kt2=u_kt2+c(k)*temp;
    end
    u_kt2 = u_kt2+c(k)*u(k,1);
end
end