function ric=ric_objEvaluate(implement,schedule,actNo,resNo,duration,req,deadline, c)
u=zeros(resNo,deadline);
ric=0;
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
    temp = sum(u(k,:).*u(k,:));
    temp1 = sum(u(k,:));
    ric = ric+c(k)*(deadline*temp)/(temp1*temp1);
end
% %% ·½²î
% mean_k = zeros(1,resNo);
% for k=1:resNo
%     mean_k(k) = mean(u(k,:));
%     for t=1:deadline
%         ric=ric+c(k)*(u(k,t)-mean_k(k))*(u(k,t)-mean_k(k));
%     end
% end
end