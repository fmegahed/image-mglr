clc;clear all;warning off all;fclose all;
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
load baselineValues
load UCLValue
s=rows*cols;
Nom=imread('Nonwoven_Nom.bmp');
Nomd=double(Nom);
Delta= [-10 -5 -3 -2 -1 1 2 3 5 10 -10 -5 -3 -2 -1 1 2 3 5 10 -10 -5 -3 -2 -1 1 2 3 5 10];
SS_Number=20;
fault=[0,0,10,10,125,125];
RL=zeros(1,nos);
ARL=zeros(1,length(Delta));
MRL=zeros(1,length(Delta));
shift=1;
while shift<=length(Delta)
    if shift>10 && shift<=20
        fault(5)=188;
        fault(6)=206;
    elseif shift>=21
        fault(5)=158;
        fault(6)=78;
    end
    fault(1)=Delta(shift);
    jj=1;
    while jj<=nos
        counter=0;
        flag=1;
        FaultPattern=zeros(pixs(1),pixs(2));
        while flag==1
            counter=counter+1;
            if counter>SS_Number && Delta(shift)~=0
                FaultPattern((fault(5)-fault(3)/2):(fault(5)+fault(3)/2),(fault(6)-fault(4)/2):(fault(6)+fault(4)/2))=normrnd(fault(1),fault(2),fault(3)+1,fault(4)+1);
            end
            Im=imnoise(Nom,'Poisson');
            Im=Nomd-double(Im)+FaultPattern;
            I=zeros(rows*sizes(1),cols*sizes(2));
            I(1:pixs(1),1:pixs(2))=Im;
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
            max_sta=max(sta_retro);
            if max_sta>UCL
                if counter<=SS_Number
                    break;
                else
                    flag=0;
                    RL(jj)=counter-SS_Number;
                    clc;
                    fprintf('The Current ARL = %6.4f, MRL = %6.4f, after %d simulations when delta = %6.4f',mean(RL(1:jj)),median(RL(1:jj)),jj,Delta(shift));
                    jj=jj+1;
                end
            end
        end
    end
    if shift>0
        ARL(shift)=mean(RL);MRL(shift)=median(RL);
    end
    shift=shift+1;
end
save('MRL10meanshift','ARL', 'MRL','Delta','SS_Number');