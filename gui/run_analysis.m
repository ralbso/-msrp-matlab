function run_analysis()
% prompts user to select files to anlyse and runs splitvol and image
% registration. Set parameters below.

% number of iterations for image registration
niter = 4;
% delete unaligned split datafiles after completing image registration?
delete_splitorig = false;
% make clip of aligned datafile
makeclip = true;

% prompt user to select files
[fnames,filepath,~] = uigetfile('*.sbx','Please select datafile(s)','MultiSelect','on');

% change pwd to location where user took files
cd(filepath);

% run through each file and carry out analysis for each
for i=1:size(fnames,1)
    % remove name suffix 
    if iscell(fnames)
        fname = strsplit(fnames{i},'.');
    else
        fname = strsplit(fnames,'.');
    end 
    fname = fname{1};
    disp(['Aligning ', fname,'...']);
    lf_align_6(fname,niter);
    disp('Deleting unaligned split datafile...');
    if delete_splitorig
        delete([fname_p,'.sbx']);   % this currently doesn't work as matlab will keep the file open and therefore blocks deletion
        delete([fname_p,'.mat']);
    end
    fname_aligned = [fname,'_rigid'];
    disp('Make video clip for aligned datafile...');
    if makeclip
        sbxmakeclip(fname_aligned,1:100);
    end
    roistory_precomp( fname_aligned );
    
end

end