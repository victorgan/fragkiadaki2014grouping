function tr=computeTrLDOF(imnames,para)

if ~exist(para.traj_file,'file')
    %% compute optical flow
    computeFlowLDOF(imnames,para);
    
    %% link flow fields
   
    tr=linkFlowLDOF(imnames,para);

    save(para.traj_file,'tr')
else
    load(para.traj_file,'tr')
end
