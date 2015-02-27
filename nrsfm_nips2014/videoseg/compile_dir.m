root_dir = [pwd '/'];

cd([root_dir '/videoseg/']);



mex -largeArrayDims parmatV.c
mex -largeArrayDims spmtimesd.c


mex -largeArrayDims compute_Atraj_neighbour.cpp
mex -largeArrayDims compute_tr_affinities_mex.cpp

cd(root_dir);






