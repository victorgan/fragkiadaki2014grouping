function dirname = setdir(dirname)

if ~exist(dirname, 'dir')
    mkdir(dirname);
end