function ref = sbxmakeref(fname,N,pmt)
% read a random set of N images in the stack of pmt (1-green, 2-red)

info = get_sbx_info(fname);

frame = sbxgrabframe(fname,1,1);
ref = zeros([size(frame,2) size(frame,3) N]);
idx = floor(rand(1,N)*info.max_idx);

for j=1:length(idx)
    q = sbxgrabframe(fname,idx(j),1);
    ref(:,:,j) = squeeze(q(pmt,:,:));
end
