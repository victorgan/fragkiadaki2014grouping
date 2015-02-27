function [dir_name]=get_dir_name2(full_name)
ind=strfind(full_name,'/');
dir_name=full_name(ind(end-1)+1:end-1);