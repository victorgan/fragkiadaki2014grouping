%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = Estimate_G_k_Brand(A_Hat,PI_Hat)

[U_A, D_A, V_A] = svd(A_Hat);

%Fix the sign of V_A1
for i = 1:size(V_A,2)
    if(V_A(1,i) < 0)
        V_A(:,i) = -V_A(:,i);
    end
end

leasteig=V_A(:,end);
Q_Hat=[leasteig(1:3,1) [leasteig(2); leasteig(4:5)] [leasteig(3);leasteig(5);leasteig(6)]];
%traing=max(triang,triang');
% Q_Hat=reshape(leasteig,3,3);
%         [q1,w,q2]=svd(ww);
%Estimate G through SDP and nonlinear optimization
[U_Hat D_Hat V_Hat] = svd(Q_Hat);

G_Hat = U_Hat(:,1:3)*sqrt(D_Hat(1:3,1:3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Nonlinear optimization
options = optimoptions(@fminunc,'Diagnostics','off','MaxIter',4000,'TolFun',1e-12,'TolX',1e-12,'Algorithm','quasi-newton','Display','off');
%options = optimset('Diagnostics','off','MaxFunEval',200000,'MaxIter',4000,'TolFun',1e-12,'TolX',1e-12,'Algorithm','levenberg-marquardt');
%opts = optimset('Algorithm','interior-point');
[G, fval] = fminunc(@evalQ_regularization,G_Hat,options,PI_Hat);  %fminunc  fminsearch