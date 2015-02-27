%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Copyright � 2011,2012  Yuchao Dai, Hongdong Li, Mingyi He
%     This file is part of NRSFM_DLH.
% 
%     NRSFM_DLH is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     NRSFM_DLH is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with NRSFM_DLH.  If not, see <http://www.gnu.org/licenses/>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function Initialization
%         Set the path of yalmip and SDPT3, should be modified to your
%         comupter local setting.
%
%Reference: Yuchao Dai, Hongdong Li, Mingyi He: A simple prior-free method
%for non-rigid structure-from-motion factorization. CVPR 2012: 2018-2025
%Author: Yuchao Dai
%Contact Information: daiyuchao@gmail.com, yuchao.dai@anu.edu.au,
%hongdong.li@anu.edu.au
%Last update: 2012-10-01
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
home_dir=[pwd '/'];
addpath(genpath([home_dir 'yalmip/']));
addpath(genpath([home_dir 'SDPT3-4.0/']));
% addpath('/work2/katef/Code/VideoReconstruction/yalmip/')
% addpath('/work2/katef/Code/VideoReconstruction/SDPT3-4.0/')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/extras')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/operators')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/solvers')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/usertest')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules/global')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules/moment')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules/parametric')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules/robust')
% % addpath('/work2/katef/Code/VideoReconstruction/yalmip/modules/sos')
% addpath('C:\Users\yuchao\Documents\MATLAB\work\SeDuMi_1_1')
% addpath('C:\Users\yuchao\Documents\MATLAB\work\SDPT3-4.0')
% addpath('D:\MATLAB\R2008a\work\lmirank')
% addpath('D:\MATLAB\R2008a\work\csdp6.1.0winp4')
% addpath('D:\MATLAB\R2008a\work\csdp6.1.0winp4\bin')
% addpath('D:\MATLAB\R2008a\work\csdp6.1.0winp4\matlab')

%sdpsettings('solver','csdp')
%sdpsettings('solver','lmirank')
%sdpsettings('solver','sedumi','sedumi.eps',1e-9)
sdpsettings('solver','sdpt3')
%Set SDP solver to "sedumi" or "sdpt3"
sdpsettings('usex0',1)
