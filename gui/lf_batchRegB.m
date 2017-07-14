fname = 'E:\\20170127\\M01\\M01_003_000';
sample = sbxreadsample(fname,300,1);    
RegTemp = squeeze(mean(sample,length(size(sample))));
[x,finfo] = read_sbx(fname,1,1);

subpixelFactor=100;
skipFactor=1; 
numImages=finfo.max_idx;

mmapfile_sbx = system(sprintf('copy %s.sbx %s_jvmc.sbx',fname,fname));
mmapfile_mat = system(sprintf('copy %s.mat %s_jvmc.mat',fname,fname));
mm = sbxreadmmap(fname,'_jvmc');

dat = squeeze(read_sbx(fname,1,finfo.max_idx));
startingImage=1;    % This not only defines where to start, but will be incremented to find the right images.
itCount=0;

% vectors that hold computed x and y shift in pixels for each frim
dx = zeros(finfo.max_idx,1);
dy = zeros(finfo.max_idx,1);

disp('calculating displacement...');
tic
for j=1:finfo.max_idx,
    [out1,out2]=dftregistration(ifft2(RegTemp),ifft2(dat(:,:,j)),subpixelFactor);
    dx(j) = out1(3);
    dy(j) = out1(4); 
end
toc
disp('shifting frames...');
tic
for i=1:finfo.max_idx
    shiftres = circshift(dat(:,:,i),[int16(-dx(i)),int16(-dy(i))]);
    mm.Data.img(1,:,:,i) = intmax('uint16')-shiftres';
end
toc

%clear('itCount','i','j','out1','out2')

% tic
% for i=1:5000,
%     imageCount=(i-1)+startingImage;
%     imwrite(registeredStack(:,:,i),['registered_' int2str(imageCount)]...
%         ,'png','bitdepth',16);
% end
% toc