function u_kt2=objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline, c)
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
% % 资源的绝对值
% for k=1:resNo
%     for t=2:deadline
%         temp = u(k,t)-u(k,t-1);
%         if  u(k,t)-u(k,t-1)<0
%              temp = u(k,t-1)-u(k,t);
%         end
%         u_kt2=u_kt2+c(k)*temp;
%     end
%     u_kt2 = u_kt2+c(k)*(u(k,1)+u(k,deadline));
% end
% 资源的成本
for k=1:resNo
    for t=1:deadline
        u_kt2=u_kt2+c(k)*u(k,t)*u(k,t);
    end
end
end