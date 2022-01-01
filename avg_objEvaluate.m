function u_kt2=avg_objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline, c)
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
% for k=1:resNo
%     for t=2:deadline
%         temp =( u(k,t)-u(k,t-1))*(u(k,t)-u(k,t-1));
% %         if  u(k,t)-u(k,t-1)<0
% %              temp = u(k,t-1)-u(k,t);
% %         end
%         u_kt2=u_kt2+c(k)*temp;
%     end
%     u_kt2 = u_kt2+c(k)*(u(k,1)*u(k,1)+u(k,deadline)*u(k,deadline));
% end
mean_u = zeros(1,resNo);
for k=1:resNo
    mean_u(k)= mean(u(k,:));
end
for k=1:resNo
   for t=1:deadline
        u_kt2=u_kt2+c(k)*(u(k,t)-mean_u(k)*(u(k,t)-mean_u(k)));
    end
end
end