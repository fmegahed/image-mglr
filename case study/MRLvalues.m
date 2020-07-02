clear all; close all; clc; warning off;
load baselineValues
load UCLValue
s=rows*cols;
Nom=imread('Nom.jpg');
Nomd=double(Nom);

ra1=randsample(2:30,20);
counter=0;
for lc=1:length(ra1)
    counter=counter+1;
    I=imread(['Normal' num2str(ra1(lc)) '.png']);
    if isgray(I)==0
        I=rgb2gray(I);
    end
    I=imadjust(I);
    Im=Nomd-double(I);
    I=zeros(rows*sizes(1),cols*sizes(2));
    I(1:pixs(1),1:pixs(2))=Im;
    for i=1:rows
        for j=1:cols
            tem=I((i-1)*sizes(1)+1:i*sizes(1),(j-1)*sizes(2)+1:j*sizes(2));
            mu(i,j,counter)=mean(tem(:));
        end
    end
    mu_sta(counter,:)=reshape(mu(:,:,counter),1,s);
    if counter>m
        mflag=counter-m;
        mu_tem=mu_sta(mflag+1:counter,:);
    else
        mflag=0;
        mu_tem=mu_sta(1:counter,:);
    end
    mu_est=zeros(counter-mflag,s);
    sta_retro=zeros(counter-mflag,1);
    for counter_retro=mflag+1:counter
        mu_est(counter_retro-mflag,:)=sum(mu_tem(counter_retro-mflag:counter-mflag,:),1)/(counter-counter_retro+1);
        sta_retro(counter_retro-mflag)=1/2*(counter-counter_retro+1)*(mu_est(counter_retro-mflag,:)-mu_each)/cov_each*(mu_est(counter_retro-mflag,:)-mu_each)';
    end
    ratio(counter)=max(sta_retro);
end

ra2=randsample(8,8);
flag=0;
for lc=1:length(ra2)
    counter=counter+1;
    I=imread(['Fail' num2str(ra2(lc)) '.png']);
    if isgray(I)==0
        I=rgb2gray(I);
    end
    I=imadjust(I);
    Im=Nomd-double(I);
    I=zeros(rows*sizes(1),cols*sizes(2));
    I(1:pixs(1),1:pixs(2))=Im;
    for i=1:rows
        for j=1:cols
            tem=I((i-1)*sizes(1)+1:i*sizes(1),(j-1)*sizes(2)+1:j*sizes(2));
            mu(i,j,counter)=mean(tem(:));
        end
    end
    mu_sta(counter,:)=reshape(mu(:,:,counter),1,s);
    if counter>m
        mflag=counter-m;
        mu_tem=mu_sta(mflag+1:counter,:);
    else
        mflag=0;
        mu_tem=mu_sta(1:counter,:);
    end
    mu_est=zeros(counter-mflag,s);
    sta_retro=zeros(counter-mflag,1);
    for counter_retro=mflag+1:counter
        mu_est(counter_retro-mflag,:)=sum(mu_tem(counter_retro-mflag:counter-mflag,:),1)/(counter-counter_retro+1);
        sta_retro(counter_retro-mflag)=1/2*(counter-counter_retro+1)*(mu_est(counter_retro-mflag,:)-mu_each)/cov_each*(mu_est(counter_retro-mflag,:)-mu_each)';
    end
    [max_sta,index]=max(sta_retro);
    ratio(counter)=max_sta;
    if max_sta > UCL && flag==0
        fault_time=mflag+index-20-1;
        muest=mu_est(index,:);
        flag=1;
    end
end
save('MRLmeanshift','ratio', 'UCL','fault_time','mu_each','muest');
x=1:28;
plot(x,ratio,'k');
xlim([1,28]);
xlabel('Image Number');
ylabel('GLR Statistic');
hold on
plot(x,UCL*ones(1,28),':k');
axes('position',[0.22,0.4,0.35,0.35]);
y=1:20;
plot(y,ratio(1:20),'k');
xlim([1,20]);
xlabel('Image Number');
ylabel('GLR Statistic');
hold on
plot(y,UCL*ones(1,20),':k');
figure(2);
y=1:18;
plot(y,mu_each,'-k*','MarkerSize',3);
xlim([1,18]);
xlabel('Region Number');
ylabel('Mean Intensities');
hold on
plot(y,muest,':ko','MarkerSize',3);
legend('in-control mean intensities','estimated mean intensities','Location', 'SouthEast');




