function [image_name,dir_name]=get_image_name(full_name)
% ind=strfind(full_name,'/');
% ind2=strfind(full_name,'.');
% image_name=full_name(ind(end)+1:ind2(end)-1);
% dir_name=full_name(1:ind(end));

[dir_name, image_name] = fileparts(full_name);