function roistory_precomp( fn )
% ROISTORY_PRECOMP pre-computes mean images for a given dataset and stores
% it on the drive as a separate file.
% Author: Lukas Fischer
% Created: 09/10/2016


% xcorr choose method
method = 1;

% set sample size for average image
sample_size = 300;
% select PMT
pmt = 1;

if ~exist('fn','var')
    [fn,pathname] = uigetfile('*.sbx');
    fn = strtok(fn,'.');
    cd(pathname);
    fnum = [1,1];
else
    fnum = [1,1];
end



for i=1:fnum(2)
    if fnum(2) > 1
        disp(['processing file ',fnames{i}]);
        fn = fnames{i};
    end
    % read data from .sbx file
    % load metainfo contained in corresponding .mat file
    info = get_sbx_info(fn);
    % read a sample of random images
    idx = floor(rand(1,sample_size)*info.max_idx);
    %idx = floor(rand(1,sample_size)*20000);
    %max_frame = info.max_idx;
    %max_frame = 20000;
    
    % create sample image
    im_stack = zeros(info.sz(1),info.sz(2),sample_size);
    parfor j=1:length(idx)
    %    waitbar(j/length(idx),h);
        q = sbxgrabframe(fn,idx(j),1);
        im_stack(:,:,j) = squeeze(q(pmt,:,:));
    end

    % get mean image
    meanref = squeeze(mean(im_stack,length(size(im_stack))));
    % normalize values to 0-1
    meanref = (meanref-min(meanref(:)))/(max(meanref(:))-min(meanref(:)));
    % make autocorrelation map
    % code from Jakob Voigt's ROImaster software, adapted from
    % http://labrigger.com/blog/2013/06/13/local-cross-corr-images/

    mean_brightness = zeros(info.max_idx,1);
    for i=1:info.max_idx
        q = sbxgrabframe(fn,i,1);
        mean_brightness(i) = mean(mean(q(1,:,:)));
    end
    
    w_global = 1;
    w = 20;
    ymax = size(im_stack,1);
    xmax = size(im_stack,2);
    numFrames = size(im_stack,3);
    ccimage = zeros(ymax,xmax);
    cc_local = zeros(ymax,xmax,w*2+1,w*2+1);

    switch method
        case 1
            % use labrigger-method
            % First calculate global xcorr map
            fprintf('Processing global cross-correlation map');
            parfor y=1+w_global:ymax-w_global

                %if (rem(y,10)==0)
                %    fprintf('%d/%d (%d%%)\n',y,ymax,round(100*(y./ymax)));
                %end;
                for x=1+w_global:xmax-w_global
                    % Center pixel
                    thing1 = reshape(im_stack(y,x,:)-mean(im_stack(y,x,:),3),[1 1 numFrames]); % Extract center pixel's time course and subtract its mean
                    ad_a   = sum(thing1.*thing1,3);    % Auto corr, for normalization laterdf

                    % Neighborhood
                    a = im_stack(y-w_global:y+w_global,x-w_global:x+w_global,:);         % Extract the neighborhood
                    b = mean(im_stack(y-w_global:y+w_global,x-w_global:x+w_global,:),3); % Get its mean
                    thing2 = bsxfun(@minus,a,b);       % Subtract its mean
                    ad_b = sum(thing2.*thing2,3);      % Auto corr, for normalization later

                    % Cross corr
                    ccs = sum(bsxfun(@times,thing1,thing2),3)./sqrt(bsxfun(@times,ad_a,ad_b)); % Cross corr with normalization
                    ccs((numel(ccs)+1)/2) = [];        % Delete the middle point
                    ccimage(y,x) = mean(ccs(:));       % Get the mean cross corr of the local neighborhood
                end
            end      
            % use labrigger-method
            % Initialize and set up parameters
            fprintf('Processing pixel-by pixel xcorr map.');
            parfor y=1+w:ymax-w

                %if (rem(y,10)==0)
                %    fprintf('%d/%d (%d%%)\n',y,ymax,round(100*(y./ymax)));
                %end;
                cc_row = zeros(xmax,w*2+1,w*2+1);
                for x=1+w:xmax-w
                    % Center pixel
                    thing1 = reshape(im_stack(y,x,:)-mean(im_stack(y,x,:),3),[1 1 numFrames]); % Extract center pixel's time course and subtract its mean
                    ad_a   = sum(thing1.*thing1,3);    % Auto corr, for normalization laterdf

                    % Neighborhood
                    a = im_stack(y-w:y+w,x-w:x+w,:);         % Extract the neighborhood
                    b = mean(im_stack(y-w:y+w,x-w:x+w,:),3); % Get its mean
                    thing2 = bsxfun(@minus,a,b);       % Subtract its mean
                    ad_b = sum(thing2.*thing2,3);      % Auto corr, for normalization later

                    % Cross corr
                    ccs = sum(bsxfun(@times,thing1,thing2),3)./sqrt(bsxfun(@times,ad_a,ad_b)); % Cross corr with normalization
                    cc_row(x,:,:) = ccs;
                    ccs((numel(ccs)+1)/2) = [];        % Delete the middle point 
                end
                cc_local(y,:,:,:) = cc_row;
            end      
    end

    m=mean(ccimage(:));
    ccimage(1,:)=m;
    ccimage(end,:)=m;
    ccimage(:,1)=m;
    ccimage(:,end)=m;

    pcaimage=ccimage;

    %disp('computing PCA ROI prediction');
    % make PCA composite, this seems to display good roi candidates
    %stack_v=zeros(numFrames,size(im_stack,1)*size(im_stack,2));
    %for i=1:numFrames;
    %    x=im_stack(:,:,i);
    %    stack_v(i,:)=x(:);
    %end
    %stack_v=stack_v-mean(im_stack(:));
    %[coeff, score] = pca(stack_v,'Economy','on','NumComponents',100);
    %imcomponents=reshape(coeff',100,size(im_stack,1),size(im_stack,2));
    %pcaimage=(squeeze(mean(abs(imcomponents(1:100,:,:)))));


    % save individual images in handles structure
    try
        save([fn '.rsc'],'meanref','ccimage','pcaimage','cc_local','mean_brightness','-append');
    catch
        save([fn '.rsc'],'meanref','ccimage','pcaimage','cc_local','mean_brightness','-v7.3');
    end
end

end

