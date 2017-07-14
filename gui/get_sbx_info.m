function metainfo = get_sbx_info(fname)

% read meta-information contained in .mat accompanying a 
mi = load([fname, '.mat']);   % load file information
d = dir([fname '.sbx']);
   
switch mi.info.channels % set number of channels
    case 1
        mi.info.nchan = 2;      % both PMT0 & 1
        factor = 1;
    case 2
        mi.info.nchan = 1;      % PMT 0
        factor = 2;
    case 3
        mi.info.nchan = 1;      % PMT 1
        factor = 2;
end

if(mi.info.scanmode==0)
	mi.info.recordsPerBuffer = mi.info.recordsPerBuffer*2;
end


if isfield(mi.info,'scanbox_version') && mi.info.scanbox_version >= 2
    mi.info.max_idx =  d.bytes/mi.info.recordsPerBuffer/mi.info.sz(2)*factor/4 - 1;
    mi.info.nsamples = (mi.info.sz(2) * mi.info.recordsPerBuffer * 2 * mi.info.nchan);   % bytes per record 
else
    mi.info.max_idx =  d.bytes/mi.info.bytesPerBuffer*factor - 1;
end

metainfo = mi.info;
