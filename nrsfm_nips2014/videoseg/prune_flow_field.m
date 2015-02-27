function [ON]=prune_flow_field(I1,I2,Ff,Fb,para,debug)
[p,q,~]=size(I1);

ON=zeros(p,q);
ON(para.g:end-para.g,para.g:end-para.g)=1;


% %structure check
structureness=compute_image_texturedness(I1,para.image_smooth_sigma);
avg_structureness=mean(structureness(:));
Off1=structureness<max(para.structure_portion*avg_structureness,para.minValue);
% Off1=zeros(size(ON));



%%forward-backward check
[Ys_ori,Xs_ori]=ndgrid([1:p],[1:q]);
Xs_new=Xs_ori+Ff(:,:,1);
Ys_new=Ys_ori+Ff(:,:,2);
flo_back_interp(:,:,1) = interp2(Fb(:,:,1), Xs_new, Ys_new);
flo_back_interp(:,:,2) = interp2(Fb(:,:,2), Xs_new, Ys_new);
Off2=sqrt((Ff(:,:,1)+flo_back_interp(:,:,1)).^2+...
    (Ff(:,:,2)+flo_back_interp(:,:,2)).^2)>...
    para.fb_check*sqrt(Ff(:,:,1).^2+Ff(:,:,2).^2+flo_back_interp(:,:,1).^2+...
    flo_back_interp(:,:,2).^2)+para.fb_check2;
if debug>3
    figure(2),
    subplot(2,2,1);
    imshow(I1)
    subplot(2,2,2);
    imagesc(sqrt((Ff(:,:,1)+flo_back_interp(:,:,1)).^2+(Ff(:,:,2)+flo_back_interp(:,:,2)).^2));
    axis image;
    subplot(2,2,3);
    imagesc(sqrt(Ff(:,:,1).^2+Ff(:,:,2).^2+flo_back_interp(:,:,1).^2+flo_back_interp(:,:,2).^2));
    axis image;
    subplot(2,2,4);
    imagesc(sqrt((Ff(:,:,1)+flo_back_interp(:,:,1)).^2+(Ff(:,:,2)+flo_back_interp(:,:,2)).^2)>...
        para.fb_check*sqrt(Ff(:,:,1).^2+Ff(:,:,2).^2+flo_back_interp(:,:,1).^2+flo_back_interp(:,:,2).^2)+para.fb_check2);
    axis image;
    title('forward backward check->high values indicate problem')
end

ON=ON.*(Off2==0).*(Off1==0);



end




