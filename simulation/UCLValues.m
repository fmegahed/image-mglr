clc;clear all;warning off all;fclose all;
load baselineValues
s=rows*cols;
k=4.67;
UCL=Sta_mu+k*Sta_std;
nos=1000;
kk=1;
Nom=imread('Nonwoven_Nom.bmp');
Nomd=double(Nom);
while kk==1
    jj=1;
    RL=zeros(1,nos);
    while jj<=nos
        counter=0;
        flag=1;
        while flag==1
            Im=imnoise(Nom,'Poisson');
            Im=Nomd-double(Im);
            I=zeros(rows*sizes(1),cols*sizes(2));
            I(1:pixs(1),1:pixs(2))=Im;
            counter=counter+1;
            for i=1:rows
                for j=1:cols
                    tem=I((i-1)*sizes(1)+1:i*sizes(1),(j-1)*sizes(2)+1:j*sizes(2));
                    mu(i,j,counter)=mean(tem(:));
                end
            end
            if counter>m
                mflag=counter-m;
                mu_tem=mu(:,:,mflag+1:counter);
            else
                mflag=0;
                mu_tem=mu(:,:,1:counter);
            end
            mu_est=zeros(rows,cols,counter-mflag);
            counter_est=zeros(counter-mflag,s);
            sta_retro=zeros(counter-mflag,1);
            for counter_retro=mflag+1:counter
                for i=1:rows
                    for j=1:cols
                        mu_est(i,j,counter_retro-mflag)=sum(mu_tem(i,j,counter_retro-mflag:counter-mflag))/(counter-counter_retro+1);
                    end
                end
                counter_est(counter_retro-mflag,:)=reshape(mu_est(:,:,counter_retro-mflag),1,s);
                sta_retro(counter_retro-mflag)=1/2*(counter-counter_retro+1)*(counter_est(counter_retro-mflag,:)-mu_each)/cov_each*(counter_est(counter_retro-mflag,:)-mu_each)';
            end
            if max(sta_retro)>UCL
                flag=0;
                RL(jj)=counter;
                clc;
                fprintf('The Current ARL = %6.4f, MRL = %6.4f, after %d simulations',mean(RL(1:jj)),median(RL(1:jj)),jj);
                jj=jj+1;
            end
        end
    end
    medianRL=median(RL);
    if medianRL<146
        k=k+0.005*(150-medianRL);
        UCL=Sta_mu+k*Sta_std;
        kk=0;
    elseif medianRL>154
        k=k-0.005*(medianRL-150);
        UCL=Sta_mu+k*Sta_std;
        kk=0;
    end
    kk=kk+1;
end
save('UCLValue','nos','k','UCL','medianRL');
