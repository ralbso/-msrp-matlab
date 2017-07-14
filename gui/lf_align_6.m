function lf_align_6(fname,niter)
% Rigid alignment for .sbx files. Includes functionality to separate out
%   individual planes from volume imaging and store it in individual files
%   fname -     filename (without suffix)
%   niter -     number of iterations for alignment (recommended: 4)
%   plane -     which plane to image
%   vol   -     total number of planes

    tic
    % load metainfo contained in corresponding .mat file
    info = get_sbx_info(fname);
    % load frames and check whether 1 or 2 PMTs were recorded
    sample = sbxmakeref(fname,300,1);    
    ref = squeeze(mean(sample,length(size(sample))));
 
    us = zeros(info.max_idx,1);
    vs = zeros(info.max_idx,1);

    system(sprintf('copy %s.sbx %s_rigid.sbx',fname,fname));
    system(sprintf('copy %s.mat %s_rigid.mat',fname,fname));
    mm = sbxreadmmap([fname,'_rigid']);

    %data_original = zeros(size(z,2),size(z,3),info.max_idx);
    %data_aligned = zeros(size(z,2),size(z,3),info.max_idx);
    % run through indices and apply shift
    A = squeeze(sbxread(fname,1,info.max_idx));
    parfor i=1:info.max_idx 
        [u,v] = fftalign(A(:,:,i),ref);
        us(i) = u;
        vs(i) = v;
    end
    
    for i=1:info.max_idx
        shiftres = circshift(A(:,:,i),[us(i),vs(i)]);
        mm.Data.img(1,:,:,i) = intmax('uint16')-shiftres';
    end
    
    disp(sqrt(mean(sum([us,vs].^2,2))));
    us0=us;
    vs0=vs;
    for i=1:niter
        ref2 = mean(squeeze(mm.Data.img(1,:,:,1:300)),3);
        us = zeros(info.max_idx,1);
        vs = zeros(info.max_idx,1);
        parfor j=1:info.max_idx
            A = squeeze(mm.Data.img(1,:,:,j));
            [u,v] = fftalign(A,ref2);
            us(j) = u;
            vs(j) = v;
            
        end
        for j=1:info.max_idx
            shiftres = circshift(squeeze(mm.Data.img(1,:,:,j)),[us(j),vs(j)]);
            mm.Data.img(1,:,:,j) = intmax('uint16')-shiftres;
        end
        
%
        disp(sqrt(mean(sum([(us0-us),(vs0-vs)].^2,2))));
        us0=us;
        vs0=vs;
    end
    toc
 
end
