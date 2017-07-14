function run_volume_analysis()
% prompts user to select files to anlyse and runs splitvol and image
% registration. Set parameters below.

% number of planes
vol = 3;
% number of iterations for image registration
niter = 4;
% whether to split file into planes - set to false if that has already been
% done
splitfile = true;
% delete unaligned split datafiles after completing image registration?
delete_splitorig = false;
% make clip of aligned datafile
makeclip = true;

% prompt user to select files
[fnames,filepath,~] = uigetfile('*.sbx','Please select datafile(s)','MultiSelect','on');

% change pwd to location where user took files
cd(filepath);

% run through each file and carry out analysis for each
nnames = 1;
if iscell(fnames)
    nnames = size(fnames,2);
end
for i=1:nnames
    % remove name suffix 
    if iscell(fnames)
        fname = strsplit(fnames{i},'.');
    else
        fname = strsplit(fnames,'.');
    end
    % run splitvol
    if splitfile
        disp(['Splitting ', num2str(fname{1}),'...']);
        sbxsplitvol(fname{1},vol);     
    end
    for j=1:vol 
        fname_p = [fname{1},'_p' num2str(j)];
        disp(['Aligning ', num2str(fname_p),'...']);
        lf_align_6(fname_p,niter);
        disp('Make video clip for aligned datafile...');
        if makeclip
            sbxmakeclip([fname_p,'_rigid'],1:100);
        end
        disp('Deleting unaligned split datafile...');
        if delete_splitorig
            delete([fname_p,'.sbx']);   % this currently doesn't work as matlab will keep the file open and therefore blocks deletion
            delete([fname_p,'.mat']);
        end
        fname_aligned = [fname_p,'_rigid'];
        roistory_precomp( fname_aligned );
    end
    
end

end