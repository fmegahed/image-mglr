clc;clear all;warning off all;fclose all;
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
load baselineValues
s=rows*cols;
k=7.2;
UCL=Sta_mu+k*Sta_std;
nos=1000;
kk=1;
while kk==1
    jj=1;
    RL=zeros(1,nos);
    while jj<=nos
        counter=0;
        flag=1;
        while flag==1
            counter=counter+1;
            mu(counter,:)=mvnrnd(mu_each,cov_each,1);
            if counter>m
                mflag=counter-m;
                mu_tem=mu(mflag+1:counter,:);
            else
                mflag=0;
                mu_tem=mu(1:counter,:);
            end
            mu_est=zeros(counter-mflag,s);
            sta_retro=zeros(counter-mflag,1);
            for counter_retro=mflag+1:counter
                mu_est(counter_retro-mflag,:)=sum(mu_tem(counter_retro-mflag:counter-mflag,:),1)/(counter-counter_retro+1);
                sta_retro(counter_retro-mflag)=1/2*(counter-counter_retro+1)*(mu_est(counter_retro-mflag,:)-mu_each)/cov_each*(mu_est(counter_retro-mflag,:)-mu_each)';
            end
            if max(sta_retro)>UCL
                flag=0;
                RL(jj)=counter;
                jj=jj+1;
            end
        end
    end
    medianRL=median(RL);
    if medianRL<146
        k=k+0.001*(150-medianRL);
        UCL=Sta_mu+k*Sta_std;
        kk=0;
    elseif medianRL>154
        k=k-0.001*(medianRL-150);
        UCL=Sta_mu+k*Sta_std;
        kk=0;
    end
    kk=kk+1;
end
save('UCLValue','nos','k','UCL','medianRL');
