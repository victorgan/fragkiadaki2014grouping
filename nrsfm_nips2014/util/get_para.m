function [para]=get_para(video_dir, extension,num,sample_step)

[imnames]          = get_file_list(video_dir,extension);
[p,q,~]            = size(imread(imnames(1).name));

%% Overall Video Stats
para.extension     = extension;                             %% image extension
para.p             = p;                                     %% image height
para.q             = q;                                     %% image width
para.verbose       = 0;                                     %% show middle result
% para.result_dir=setdir([video_dir 'videoseg_keyframe/']);                              
%% Optical Flow & Trajectory
para.flow_dir = [video_dir 'flow/'];                %% Flow directory
if ~exist(para.flow_dir)
    para.flow_dir=[video_dir 'deep_flow/'];
end
para.structure_portion=0;                                   %% Texture threshold1
para.minValue=0.000005;                                            %% Texture threshold2
para.fb_check=0.1;                                          %% ForBackCheck 1
para.fb_check2=0.1;                                           %% ForBackCheck 2
para.g=10;                                                  %% Block Ratio
para.sample_step=sample_step;                                         %% Spatial sample rate
% para.flow=get_para_flow;
% para.flow.flow_dir=para.flow_dir;
para.traj_file=[video_dir 'trajectories' num2str(num) 'samplestep' num2str(para.sample_step) '.mat'];
para.image_smooth_sigma=10;
para.min_tr_len=10;  
%% Affinity on Trajectory
para.aggr=5;                              %% velocity support
para.dist_thresh_x=round(q/6);                              %% spatial neighbour (x)
para.dist_thresh_y=round(p/6);                              %% spatial neighbour (y)

%% Ncut on Trajectory
para.nv_min=5;                                              %% min # eigv
para.nv=50;                                                 %% max # nv                        %% discontinuity threshold
               


           
