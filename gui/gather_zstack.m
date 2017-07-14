function gather_zstack( fname, fpp )
% take .sbx file and parameters of stack recorder using NLW scanbox/knobby
% and create a tif-stack with each frame corresponding to a layer
% 
%   fname   - filename
%   fpp     - frames per plane

info = get_sbx_info(fname);

fid = fopen([fname,'_gathered.sbx'],'w');
copyfile([fname,'.mat'],[fname,'_gathered.mat']);

% calculate the mean of frames of each plane
for i=1:floor(info.max_idx/fpp)
    z_plane_mean = sbxgrabframe(fname,(i-1)*fpp+1,fpp);
    % if multiple channels have been recorded: only use the first one
    if size(z_plane_mean,1) > 1
        warning('current implementation only supports PMT0 channel');
        z_plane_mean = z_plane_mean(1,:,:,:);
    end
    z_plane_mean = squeeze(z_plane_mean);
    z_plane_mean = mean(z_plane_mean,3);
    fwrite(fid,intmax('uint16')-uint16(z_plane_mean)','uint16'); 
end
fclose(fid);

end
