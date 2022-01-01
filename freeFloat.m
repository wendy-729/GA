function ff=freeFloat(es,ef,actNo,nrsu,su,implement,deadline)
ff=zeros(1,actNo);
for i=1:actNo-1
    if implement(i)
        temp_es=Inf;
        for j=1:nrsu(i)
            % ½ôºó»î¶¯
            jinhou=su(i,j);
            if implement(jinhou)==1
                temp_es=min(temp_es,es(jinhou));
            end
        end
        ff(i)=temp_es-ef(i);
    end
end
ff(actNo)=deadline-ef(actNo);
        