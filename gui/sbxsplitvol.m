function sbxsplitvol(fname,vol)
% split a volume-imaging file into individual .sbx datafiles that can then
% be analysed in the regular pipeline
%
%   fname -   filename (without suffix)
%   vol   -   total number of planes

tic
% load metainfo contained in corresponding .mat file
info = get_sbx_info(fname);
% load frames and check whether 1 or 2 PMTs were recorded
if info.channels ~= 1
    frames = squeeze(sbxgrabframe(fname,1,-1));
else
    error('Functionality for 2-channel recording not implemented yet.');
end
% create new datafiles - one per plane
fids = cell(vol,1);
for i=1:vol
    plane_fname = [fname,'_p' num2str(i) '.sbx'];
    meta_fname = [fname,'_p' num2str(i) '.mat'];
    info.plane = i; 
    save(meta_fname,'info');
    fids{i} = fopen(plane_fname,'w');
    % terminate if one of the files can't be created
    if fids{i} == -1
        warning('File could not be created.');
        break;
    end
end

% write frames to corresponding new datafiles
k = 0;
for j=0:info.max_idx-1
    fwrite(fids{mod(j,vol)+1},intmax('uint16')-frames(:,:,j+1)','uint16'); % the +1 is just to get around matlab indexing stupidity
    if mod(j,vol)+1 == 1
        k = k+1;
    end
end

% close new datafiles
for i=1:vol
    fclose(fids{i});
end
toc

end