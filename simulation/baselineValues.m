function []=baselineValues(pixs,sizes,m,num_images)
rows=ceil(pixs(1)/sizes(1));
cols=ceil(pixs(2)/sizes(2));
s=rows*cols;
Im=imread('Nonwoven.jpg'); %Reading the image
if (isgray(Im)==0)   %Making sure it is grayscale
    Im=rgb2gray(Im);
end
BG=imopen(Im,strel('disk',15)); %Estimating the Value of Background Pixels
Iunfrm=imsubtract(Im,BG); %Create an Image with a Uniform Background
Iadjust=imadjust(Iunfrm); %Adjusting the contrast-see imadjust for details
Ires=imresize(Iadjust,pixs); %Resizing
delete('Nonwoven_Nom.bmp') %Delete Previous Nominal Picture
imwrite(Ires,'Nonwoven_Nom.bmp','bmp'); %Write New Nominal Picture
clear I BG Iunfrm Iadjust Ires
Nom=imread('Nonwoven_Nom.bmp');
Nomd=double(Nom);
pic_sta=zeros(num_images,s);
mu=zeros(rows,cols,num_images);
for pic=1:num_images
    Im=imnoise(Nom,'Poisson');
    Im=Nomd-double(Im);
    I=zeros(rows*sizes(1),cols*sizes(2));
    I(1:pixs(1),1:pixs(2))=Im;
    for i=1:rows
        for j=1:cols
            tem=I((i-1)*sizes(1)+1:i*sizes(1),(j-1)*sizes(2)+1:j*sizes(2));
            mu(i,j,pic)=mean(tem(:));
        end
    end
    pic_sta(pic,:)=reshape(mu(:,:,pic),1,s);
end
mu_each=mean(pic_sta);
cov_each=cov(pic_sta);
mflag=0;
mu_tem=mu(:,:,1:m);
Sta_each=zeros(num_images,1);
for pic=1:num_images
    if pic>m
        mflag=pic-m;
        mu_tem=mu(:,:,mflag+1:pic);
    end
    mu_est=zeros(rows,cols,pic-mflag);
    pic_est=zeros(pic-mflag,s);
    sta_retro=zeros(pic-mflag,1);
    for pic_retro=mflag+1:pic
        for i=1:rows
            for j=1:cols
                mu_est(i,j,pic_retro-mflag)=sum(mu_tem(i,j,pic_retro-mflag:pic-mflag))/(pic-pic_retro+1);
            end
        end
        pic_est(pic_retro-mflag,:)=reshape(mu_est(:,:,pic_retro-mflag),1,s);
        sta_retro(pic_retro-mflag)=1/2*(pic-pic_retro+1)*(pic_est(pic_retro-mflag,:)-mu_each)/cov_each*(pic_est(pic_retro-mflag,:)-mu_each)';
    end
    Sta_each(pic)=max(sta_retro);
end
Sta_mu=mean(Sta_each);
Sta_std=std(Sta_each);
save('baselineValues','num_images','pixs','sizes','rows','cols','m','mu_each','cov_each','Sta_mu','Sta_std');
end


















