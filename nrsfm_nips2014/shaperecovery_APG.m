function S = shaperecovery_APG(W,R,S0,H,para,imnames,scale,translation)


[F, P] = size(W);
F = F/2;  %Frames
r=1;
sv = r+1;
max_inner_iter=7000;






Lf=1;
mu_k=norm(R'*(H.*W),'fro');
eta_mu = 0.25;             %0.25
eta_tau=0.25;
mu_th = 1e-10;             %threshold on mu
mu_th=10^(-4)*mu_k;
tolerance = 1e-5;            %Threshold
%Transform from 3F*P matrix X_k to F*3P matrix X_sharp_k [X Y Z]
X_sharp_k = [S0(1:3:end,:) S0(2:3:end,:) S0(3:3:end,:)];
X_sharp_kminus1=X_sharp_k;
n1=size(X_sharp_k,1);
n2=size(X_sharp_k,2);



outer_iteration = 1;
for l=1:20
    t_k=1;
    t_kminus1=1;
    tau_k=Lf;
    if(~outer_iteration)
        break;
    end
    % disp('Outer loop count')
    progress('continuation iter',l,20);
    fprintf('\n')
    %decrease mu in each iteration

    mu_k=max(0.7*mu_k,mu_th);
    fprintf('mu:%f \n',mu_k);
    if (mu_k == mu_th)
        outer_iteration = 0;
    end
    
    Energy_Residual = [];
    non_converged = 1;
    k = 1;
    
    
    while(non_converged)&&(k<max_inner_iter)
        % progress('iter',k,max_inner_iter);

  
        Y_k=X_sharp_k+((t_kminus1-1)/t_k)*(X_sharp_k-X_sharp_kminus1);
        g_sharp=gradf(Y_k);
        
   
        G=computeG(Y_k,tau_k,g_sharp);
        
        [G_shrink,sv]=matrix_shrinkage(G,mu_k/tau_k,sv);

        %fprintf('\n sv:%d \n',sv);
        
        %record the last X_sharp
        X_sharp_kminus1 = X_sharp_k;
        X_sharp_k=G_shrink;
        t_kminus1=t_k;
        t_k=(1+sqrt(1+4*(t_k)^2))/2;
        
        
        %Evaluate the residual: according to whether the S matrix is
        %changing
        Energy_Residual(k) = norm(X_sharp_k - X_sharp_kminus1,'fro')/max(1,norm(X_sharp_k,'fro'));
        progress('res:',Energy_Residual(k),tolerance)
      
        if(Energy_Residual(k) < tolerance)
            non_converged = 0;
        end
        
        k = k + 1;
        
    end
end

S=unsharpen(X_sharp_k);


    function eval=Peval(X,mu)
        eval=mu*trace(sqrt(X'*X));
    end
    function  G=computeG(Y_k,tau_k,gradY)
        %G=Y-tau^_1gradf(Y)
        if nargin<3
            G=Y_k-tau_k^(-1)*gradf(Y_k);
        else
            G=Y_k-tau_k^(-1)*gradY;
        end
    end

    function  Q=computeQ(X,G,mu,tau,gradffrob2,f,pevalx)
      
        if nargin<7
            Q=tau/2*norm(X-G,'fro')^2+Peval(X,mu)+f-(1/(2*tau))*gradffrob2;
        else
            Q=tau/2*norm(X-G,'fro')^2+pevalx+f-(1/(2*tau))*gradffrob2;
        end
    end

    function g_sharp=gradf(Y_k)
        % Compute gradient g(S^k_sharp)
        Y_k=unsharpen(Y_k);
        
     
        g_data = R'*(H.*(R*Y_k - W));
        
        
        g=g_data;
        
        g_sharp=sharpen(g);
        
        
    end


    function [X_shrink,sv,nuclearG]=matrix_shrinkage(X,thrsh,sv)
        if sv>min(n1,n2)
            sv=min(n1,n2);
        end
        OK = 0;
        while ~OK
            [U,Sigma,V] = lansvd(X,sv,'L');
            OK = (Sigma(sv,sv) <= thrsh) || ( sv == min(n1,n2) );
            sv = min(2*sv, min(n1,n2));
        end
        sigma = diag(Sigma);
        r = sum(sigma > thrsh);
        U = U(:,1:r); V = V(:,1:r);
        sigma = sigma(1:r) - thrsh;
        S = diag(sigma);
        sv = r + 1;
        X_shrink = U*S*V';
        nuclearG=sum(abs(sigma));
    end

    function x_sharp=sharpen(x)
        x_sharp = [x(1:3:end,:) x(2:3:end,:) x(3:3:end,:)];
    end

    function x=unsharpen(x_sharp)
        x = zeros(3*F,P);
        x(1:3:end,:) = x_sharp(:,1:P);
        x(2:3:end,:) = x_sharp(:,P+1:2*P);
        x(3:3:end,:) = x_sharp(:,2*P+1:3*P);
    end
end
