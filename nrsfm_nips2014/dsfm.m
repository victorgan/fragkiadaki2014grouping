function [Shape, Shat, translation, scale,  Rsh, R_Recover, Shape_nonmetric] = ...
    dsfm_Marques_latest(W,H,maxIter,MaxIterInner)
%W: the measurement matrix
%H: present entries indicator
%K: the rank
if ~exist('maxIter','var')
    maxIter=1;
end

if ~exist('maxIter','var')
    maxIterInner=7;
end

W_espilon=100;
R_espilon=2;
nPose = size(W,1)/2;     %Number of frames
nPts = size(W,2);        %Number of points
fprintf('number of frames %d number of points %d \n',nPose,nPts);
Wori=W;
W_k=Wori;
W_prev=Wori;
iteration=0;
while iteration<maxIter
    iteration=iteration+1;
    progress('Iteration' ,iteration,maxIter)
    %% Centeralize the measurements
    
    if sum(sum(H==0))==0||(iteration>1)
        translation = full(mean(W_k,2));
        if 0
            tr_centerofmass=Z2tr(translation,[imnames.t]');
            plot_trajectory_labels(tr_centerofmass,1,imnames(1:10:end),1,[],0,6);
        end
        W = W_k - translation*ones(1,size(W,2));
        scale=max(max(abs(W)));
        W=W/scale;
    else
        
        scale=max(max(abs(W_k.*H)));
        Wtmp=W_k/scale;
        
      
        [~,U,V]=matrix_completion(Wtmp,H,4,2,4);
        
        error=sum(sum(abs(H.*(Wtmp-U*V'))));
        fprintf('Error of the observed entries when searching for translation:%f',error);
        W4K=scale*(U*V');
        %     %% reprojection of missing data
        if 0
            Wout=W4K;
            tr_out=Z2tr(Wout,[imnames.t]')';
            plot_trajectory_labels(tr_out,ones(length(tr_out),1),imnames(1:5:end),...
                2,[],0,6);
        end
        translation = full(mean(W4K,2));
        if 0
            tr_centerofmass=Z2tr(translation,[imnames.t]');
            plot_trajectory_labels(tr_centerofmass,1,imnames(1:5:end),1,[],0,6);
        end
        W = W_k - translation*ones(1,nPts);
        scale=max(max(abs(W.*H)));
        W=W/scale;
    end
    
    
    
    %% bilinear factorization
    if (sum(sum(H==0))==0)  || (iteration>1)
      %  disp('SVD, no missing entries')
        K=1;
        if (2*nPose>nPts)
            [U,D,V] = svd(W,0);
        else
            [V,D,U] = svd(W',0);
        end
        for i = 1:size(U,2)
            if(U(1,i) < 0)
                U(:,i) = -U(:,i);
            end
        end
        PI_Hat = U(:,1:3*K)*sqrt(D(1:3*K,1:3*K));
    else
        disp('bilinear factorization with missing data')
        [~,U,V]=matrix_completion(W,H,3,2);
        W=U*V';
        %sum(sum(((W_in-W).*H)))
        for i = 1:size(U,2)
            if(U(1,i) < 0)
                U(:,i) = -U(:,i);
            end
        end
        PI_Hat=U;
    end
    Shape_nonmetric=V;
    %% Solve all the G_k or Q_k
    R_Recover_prev=PI_Hat;
    inner_iteration=0;
    while inner_iteration<MaxIterInner
        
        inner_iteration=inner_iteration+1;
     %   disp('recovering rotation matrix')
        K=1;
        A = zeros(2*nPose,(3*K)*(3*K));
        A_Hat = zeros(2*nPose,(3*K)*(3*K+1)/2);
        
        %orthogonality constraints at each frame
        for f=1:nPose
            PI_Hat_f = PI_Hat(2*f-1:2*f,:);
            %Here we use the relationship that vec(ABA^T) = (A\odotA)vec(B)
            AA = kron(PI_Hat_f,PI_Hat_f);
            A(2*f-1,:) = AA(1,:) - AA(4,:);
            A(2*f-0,:) = AA(2,:);
            count = 0;
            for i=1:3*K
                for j=i:3*K
                    count = count+1;
                    if(i==j)
                        A_Hat(2*f-1,count)=A(2*f-1,(3*K)*(i-1)+j);
                        A_Hat(2*f-0,count)=A(2*f-0,(3*K)*(i-1)+j);
                    else
                        A_Hat(2*f-1,count)=A(2*f-1,(3*K)*(i-1)+j)+A(2*f-1,(3*K)*(j-1)+i);
                        A_Hat(2*f-0,count)=A(2*f-0,(3*K)*(i-1)+j)+A(2*f-0,(3*K)*(j-1)+i);
                    end
                end
            end
        end
        
        [U_A, D_A, V_A] = svd(A_Hat);
        
        %Fix the sign of V_A1
        for i = 1:size(V_A,2)
            if(V_A(1,i) < 0)
                V_A(:,i) = -V_A(:,i);
            end
        end
        
        G = Estimate_G_k_Brand(A_Hat,PI_Hat);

        %G = Estimate_G_k(PI_Hat,V_A,count,K);
        %Recover the rotations, R_Recover 2F*3, Rsh 2F*3F
        [R_Recover Rsh] = Recover_Rotation(PI_Hat,G);
        
        % find the scalars per frame
%         gama=ones(nPose,2);
%         for t=1:nPose
%             R_c=R_Recover(2*(t-1)+1:2*(t-1)+2,:);
%            
%             gama(t,1)=R_c(1,:)*R_c(2,:)';
%             gama(t,2)=R_Recover(2*(t-1)+2,:)*G*G'*R_Recover(2*(t-1)+2,:)';
%             
%         end
        
        %% Recovery of the deformable shape- Pseudo-inverse method
      %  disp('recovering rigid shape - Pseudo-inverse')
        S_PI = pinv(R_Recover)*W;
        
        
        R=W*pinv(S_PI);
        
        R_residual=norm(R_Recover-R_Recover_prev,'fro');
%         fprintf('R_residual:%f',R_residual);
%         pause(1);
        if R_residual<R_espilon||(inner_iteration>MaxIterInner)
            break;
        else
            R_Recover_prev=R_Recover;
            PI_Hat=R;
            for i = 1:size(PI_Hat,2)
                if(PI_Hat(1,i) < 0)
                    PI_Hat(:,i) = -PI_Hat(:,i);
                end
            end
        end
        
        
    end
    if 0
        close all
        h=figure(1);clf;
        set(h,'Position',[800 800 800 800]);
        for t=1:1%nPose
            plot3(Shape((t-1)*3+1,:),Shape((t-1)*3+2,:),Shape((t-1)*3+3,:),'*r');
            drawnow;
            pause(0.1)
        end
    end
    
    Shape = S_PI;
    
    
    W_k=((R_Recover*S_PI)*scale+translation*ones(1,nPts)).*(H==0)+...
        Wori.*H;
    
    ResidualW=norm(W_prev-W_k,'fro')^2;
%     fprintf('\nResidualW:%f \n',ResidualW);
%     pause(1);
    if ResidualW<W_espilon
        break;
    else
        W_prev=W_k;
    end
    
end

Shat.PI=S_PI;
