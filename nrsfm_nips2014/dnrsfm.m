function [S,Shat, translation, scale,  Rsh, R_Recover] = ...
    dnrsfm_latest(W,H,K,imnames,para)
%W: the measurement matrix
%H: present entries indicator
%K: the rank bound

K_tot=3;
nPose = size(W,1)/2;     %Number of frames
nPts = size(W,2);        %Number of points
fprintf('number of frames %d number of points %d \n',nPose,nPts);
Wori=W;
W_k=Wori;

%% Centeralize the measurements

if (sum(sum(H==0))==0)
    translation = full(mean(W_k,2));
    W = W_k - translation*ones(1,size(W_k,2));
    scale=max(max(abs(W)));
    W=W/scale;
else
    
    disp('SfM for finding translation');
    scale=max(max(abs(W_k.*H)));
    Wtmp=W_k/scale;
    [~,U,V]=matrix_completion(Wtmp,H,4,2,4);
    %         error=sum(sum(abs(H.*(Wtmp-U*V'))));
    %         fprintf('Error of the observed entries when searching for translation:%f',error);
    W4K=scale*(U*V');
    translation = full(mean(W4K,2));
    if 0
        tr_centerofmass=Z2tr(translation,[imnames.t]);
        plot_trajectory_labels(tr_centerofmass,1,imnames,1,[],0,6);
    end
    W = W_k - translation*ones(1,nPts);
    scale=max(max(abs(W.*H)));
    W=W/scale;
end



%% bilinear factorization

disp('bilinear factorization with missing data')
yy=min(size(W,1),size(W,2));

[~,U,V]=matrix_completion(W,H,min(yy,3*K),2,min(yy,3*K)+2);

W=U*V';
if size(U,2)~=K_tot
    [U, ~, ~] = svds(W,K_tot);
    U=U(:,1:K_tot);
end
for i = 1:size(U,2)
    if(U(1,i) < 0)
        U(:,i) = -U(:,i);
    end
end
PI_Hat=U;


%% Solve all the G_k or Q_k
disp('recovering rotation matrix')

A = zeros(2*nPose,(K_tot)*(K_tot));
A_Hat = zeros(2*nPose,(K_tot)*(K_tot+1)/2);

%orthogonality constraints at each frame
for f=1:nPose
    PI_Hat_f = PI_Hat(2*f-1:2*f,:);
    %Here we use the relationship that vec(ABA^T) = (A\odotA)vec(B)
    AA = kron(PI_Hat_f,PI_Hat_f);
    A(2*f-1,:) = AA(1,:) - AA(4,:);
    A(2*f-0,:) = AA(2,:);
    count = 0;
    for i=1:K_tot
        for j=i:K_tot
            count = count+1;
            if(i==j)
                A_Hat(2*f-1,count)=A(2*f-1,(K_tot)*(i-1)+j);
                A_Hat(2*f-0,count)=A(2*f-0,(K_tot)*(i-1)+j);
            else
                A_Hat(2*f-1,count)=A(2*f-1,(K_tot)*(i-1)+j)+A(2*f-1,(K_tot)*(j-1)+i);
                A_Hat(2*f-0,count)=A(2*f-0,(K_tot)*(i-1)+j)+A(2*f-0,(K_tot)*(j-1)+i);
            end
        end
    end
end

% [U_A, D_A, V_A] = svd(A_Hat);
%
% %Fix the sign of V_A1
% for i = 1:size(V_A,2)
%     if(V_A(1,i) < 0)
%         V_A(:,i) = -V_A(:,i);
%     end
% end

%Estimate G through SDP and nonlinear optimization

%G = Estimate_G_k(PI_Hat,V_A,count,Krot);
G = Estimate_G_k_Brand(A_Hat,PI_Hat);

%Recover the rotations, R_Recover 2F*3, Rsh 2F*3F
[R_Recover Rsh] = Recover_Rotation(PI_Hat,G);






% initialize from the rigid shape
S0=repmat(pinv(R_Recover)*W,size(W,1)/2,1);

if 0
    close all
    figure(1);clf;
    plot3(S0(1,:),S0(2,:),S0(3,:),'*r');
    axis equal
    drawnow;
    
end


S = shaperecovery_APG(W,Rsh,S0,H);
Shat = S_to_Shat(S,K);                   % Transform to K basis form

if 0
    Shat=S;
    close all
    figure(1);clf;
    for t=1:nPose
        plot3(Shat((t-1)*3+1,:),Shat((t-1)*3+2,:),Shat((t-1)*3+3,:),'*r');
        drawnow;
        pause(0.5)
        view(0,90);
    end
end



