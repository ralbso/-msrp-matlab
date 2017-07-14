function varargout = roistory(varargin)
% ROISTORY MATLAB code for roistory.fig
%      ROISTORY, by itself, creates a new ROISTORY or raises the existing
%      singleton*.
%
%      H = ROISTORY returns the handle to a new ROISTORY or the handle to
%      the existing singleton*.
%
%      ROISTORY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROISTORY.M with the given input arguments.
%
%      ROISTORY('Property','Value',...) creates a new ROISTORY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roistory_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roistory_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roistory

% Last Modified by GUIDE v2.5 19-Sep-2016 15:32:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roistory_OpeningFcn, ...
                   'gui_OutputFcn',  @roistory_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roistory is made visible.
function roistory_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roistory (see VARARGIN)

    % Choose default command line output for roistory
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);


% UIWAIT makes roistory wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roistory_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes on button press in btnLoad.
function btnLoad_Callback(hObject, eventdata, handles)
% hObject    handle to btnLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [fn,pathname] = uigetfile('*.sbx');
    cd(pathname);
    fn = strtok(fn,'.');
    
    handles.floodcenter = [];
    handles.fn = fn;
    handles.sel = 'btMeanImage';

    disp([fn,'.rsc'])

    handles.npixels = 250;

    handles.lxcorrc = [];
    
    if exist([fn,'.rsc'],'file')
        load([fn,'.rsc'],'-mat','meanref','ccimage','pcaimage','cc_local','mean_brightness')
    else
        disp(['Could not find ',fn,'.rsc. Please carry out precomputation first.'])
    end
    
    % save individual images in handles structure
    handles.m = meanref;
    handles.ccimage = ccimage;
    handles.pcaimage = pcaimage;
    handles.lxcorr = cc_local;
    handles.mean_brightness = mean_brightness;

    % display mean image
    axis([0,1,0,1]);
    drawnow
    handles.im = imagesc(0,[0,1]);
    axis tight;
    zoom off;
    pan off;

    %handles.im = imagesc(meanref);
    % colormap gray
    hold on;
    % create overlay images (each pixel has 3 values --> RGB
    handles.im_mask = image(bsxfun(@times,ones(size(handles.m)),reshape([0,0,1],[1,1,3])));
    handles.im_flood = image(bsxfun(@times,ones(size(handles.m)),reshape([1,0,0],[1,1,3])));
    handles.roimove = image(bsxfun(@times,ones(size(handles.m)),reshape([0,1,0],[1,1,3])));
    %set(handles.im_mask,'visible','off');
    set(handles.im_flood,'visible','off');
    set(handles.roimove,'visible','off')
    try
        load([fn '.segment'],'-mat');
        handles.mask = mask;
    catch
        handles.mask = zeros(size(handles.m));
    end
    
    handles.roimask = zeros(size(handles.m));
    drawfgim(handles);
    draw_image(handles);
    %set(handles.im,'Cdata',meanref);
    colormap(gray);
    axis off;
    handles.txtStatus.String = max(handles.mask(:));
    % attach button down callbacks to image and mask
    set(handles.im_mask,'ButtonDownFcn',@(x,y) figure1_ButtonDownFcn(x,y,handles));
    set(handles.im_flood,'ButtonDownFcn',@(x,y) im_flood_ButtonDownFcn(x,y));
    set(handles.roimove,'ButtonDownFcn',@(x,y) roimove_ButtonDownFcn(x,y,handles));
    hold off;
    guidata(hObject, handles);

function im_flood_ButtonDownFcn(hObject, eventdata)
    handles = guidata(hObject);
    newmask = handles.floodmap < handles.npixels;    
    newmask(handles.mask>0)=0;
    handles.mask = handles.mask + (max(handles.mask(:))+1)*newmask;
    handles.floodcenter = [];
    guidata(hObject,handles);
    drawfgim(handles);
    drawfloodim(handles);
    handles.txtStatus.String = max(handles.mask(:));
    set(handles.im_flood,'Visible','off');

    

% --- Executes when selected object is changed in bgDisplay.
function bgDisplay_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bgDisplay 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles.sel = get(eventdata.NewValue,'Tag');
guidata(hObject, handles);
draw_image(handles)

function draw_image(handles)
    switch handles.sel % Get Tag of selected object.
        case 'btMeanImage'
            dispimg = handles.m;
        case 'btnXcorrr'
            dispimg = handles.ccimage;
        case 'rbPCA'
            dispimg = handles.pcaimage;
        colormap(gray);
        axis off;
        guidata(hObject, handles);
    end
    if ~isempty(handles.lxcorrc)
        dispimg = pastexcorr(dispimg,handles);
    end
    set(handles.im,'Cdata',dispimg);
    
% overlay the local xray image over the axis where the cursor is hovering
function dispimg = pastexcorr(dispimg,handles)
    sz = size(handles.lxcorr,3);
    % mostly thefactor comes out as 2
    %thefactor = round(size(dispimg,2)/size(handles.lxcorr,2));
    %thefactor = 2;

    handles.lxcorrc = max(handles.lxcorrc,1);
    handles.lxcorrc(1) = min(handles.lxcorrc(1),size(dispimg,2));
    handles.lxcorrc(2) = min(handles.lxcorrc(2),size(dispimg,1));
    % dx: distance in pixels of the selected coordinate from 0/0
    dx = -floor(handles.lxcorrc(2:-1:1))+sz;
    dx(1) = dx(1) - 1;
    dx(2) = dx(2) - 1;
    %theim = theim;
    % shift window where we want to paste xray into so that it starts at
    % 0/0
    dispimg = circshift(dispimg,dx);

    % pull out data from precomputed xray matrix
    %R = squeeze(handles.lxcorr(max(floor(handles.lxcorrc(2)/thefactor),1),...
    %                         max(floor(handles.lxcorrc(1)/thefactor),1),:,:));
     R = squeeze(handles.lxcorr(max(floor(handles.lxcorrc(2)),1),...
                                max(floor(handles.lxcorrc(1)),1),:,:));
    % double resolution  and convolve image with a .5,1,.5 kernel --> 
    % edge detection?
    %if thefactor == 2
    %R2 = zeros(size(R,1)*2-1,size(R,2)*2-1);
    %R2(1:2:end,1:2:end) = R;
    R2 = conv2([.5,1,.5],[.5,1,.5],R,'same');
    A = R(2:end-1,2:end-1);
    %end
    %A = imresize(R,thefactor);
    R(ceil(end/2),ceil(end/2)) = 0;
    rg = (1:size(A,1));
    dispimg(rg+floor(sz/2),rg+floor(sz/2)) = A/(max(R(:))+.01);
    % shift window back to its original position
    dispimg = circshift(dispimg,-dx);

% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles = guidata(hObject);


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% method adapted from Patrick Mineault's segmentflood function 
% https://xcorr.net/about/
    handles = guidata(hObject);
    if handles.cbMoveroi.Value == 0
        switch handles.bgSelect.SelectedObject.Tag 
            case 'rbFloodfill'
                a = get(handles.axes1,'CurrentPoint');
                a = round(a(1,1:2)');
                handles.lxcorrc = a;
                handles.floodcenter = max(a,1);
                B = computefloodim(handles);
                handles.floodmap = B;

                guidata(hObject, handles);
                %drawMask(handles);
                drawfloodim(handles);
            case 'rbPolygon'
                h = impoly;
                wait(h);
                m = h.createMask(handles.im);
                handles.mask = handles.mask + (max(handles.mask(:))+1)*m;
                delete(h);
                handles.txtStatus.String = max(handles.mask(:));
                guidata(hObject, handles);
                drawfgim(handles)
            case 'rbEllipse'
                h = imellipse;
                wait(h);
                m = h.createMask(handles.im);
                handles.mask = handles.mask + (max(handles.mask(:))+1)*m;
                delete(h);
                handles.txtStatus.String = max(handles.mask(:));
                guidata(hObject, handles);
                drawfgim(handles)
            case 'radiobutton9'
                h = imrect;
                wait(h);
                m = h.createMask(handles.im);
                handles.mask = handles.mask + (max(handles.mask(:))+1)*m;
                delete(h);
                handles.txtStatus.String = max(handles.mask(:));
                guidata(hObject, handles);
                drawfgim(handles)
            case 'imFreehand'
                h = imfreehand;
                wait(h);
                m = h.createMask(handles.im);
                handles.mask = handles.mask + (max(handles.mask(:))+1)*m;
                delete(h);
                handles.txtStatus.String = max(handles.mask(:));
                guidata(hObject, handles);
                drawfgim(handles)
        end
    else
        %selectRoi(hObject,handles);
        a = get(handles.axes1,'CurrentPoint');
        a = round(a(1,1:2)');    
        selroi = handles.mask(a(2),a(1));
        if selroi > 0
            % copy selected roi to roimask and delete it from the overall
            % mask
            handles.roimask = zeros(size(handles.mask));
            handles.roimask(handles.mask==selroi) = selroi;
            handles.mask(handles.mask==selroi) = 0;
            drawfgim(handles);
            set(handles.roimove,'Visible','on');
            drawroimask(handles);
            guidata(hObject,handles);
        end
    end
    
function selectRoi(hObject,handles)
    % determine which roi was clicked and isolate it by writing it into a
    % separate mask so we can move it individually
    % get current point coordinates and determine which roi was clicked
    a = get(handles.axes1,'CurrentPoint');
    a = round(a(1,1:2)');    
    selroi = handles.mask(a(2),a(1));
    if selroi > 0
        % copy selected roi to roimask and delete it from the overall
        % mask
        handles.roimask = zeros(size(handles.mask));
        handles.roimask(handles.mask==selroi) = selroi;
        handles.mask(handles.mask==selroi) = 0;
        drawfgim(handles);
        set(handles.roimove,'Visible','on');
        drawroimask(handles);
        guidata(hObject,handles);
    end
    
function roimove_ButtonDownFcn(hObject, eventdata, handles)
    handles = guidata(hObject);
    selroi = max(handles.roimask(:));
    handles.mask(handles.roimask==selroi) = selroi;
    set(handles.roimove,'Visible','off');
    drawfgim(handles);
    guidata(hObject,handles);
   
function B = computefloodim(handles)
    % compute outline of putative ROI from seedpoint
    theim = zeros(size(handles.m));
    theim = pastexcorr(theim,handles);
    thecen = round(handles.floodcenter(2:-1:1));
    set(handles.im_flood,'Visible','on');
    theim_mask = zeros(size(handles.m));
    %theim_mask(thecen(1)-30:thecen(1)+30,thecen(2)-30:thecen(2)+30) = 1;
    %theim = handles.ccimage.*(handles.mask==0);
    %theim = theim.*theim_mask;
    [~,B] = regiongrowing(theim,thecen(1),thecen(2),nnz(theim(:)));

function drawfgim(handles)
    themask = handles.mask > 0;
    set(handles.im_mask,'AlphaData',.5*(themask));
    
function drawroimask(handles)
    rmask = handles.roimask > 0;
    set(handles.roimove,'AlphaData',.5*(rmask));
    
function drawfloodim(handles)
    if ~isempty(handles.floodcenter)
        %Flood fill
        floodim = handles.floodmap<handles.npixels;
        set(handles.im_flood,'AlphaData',.5*(floodim));
    end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cblxcorr.Value == 1
    a = get(handles.axes1,'CurrentPoint');
    handles.lxcorrc = round(a(:,1:2)');
    guidata(hObject, handles);
    draw_image(handles);
else
    handles.lxcorrc = [];
end
% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
    %	VerticalScrollCount: signed integer indicating direction and number of clicks
    %	VerticalScrollAmount: number of lines scrolled for each click
    % handles    structure with handles and user data (see GUIDATA)
    handles.npixels = max(10,handles.npixels - (eventdata.VerticalScrollAmount*eventdata.VerticalScrollCount)*15);
    guidata(hObject,handles);
    drawfloodim(handles);


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    zoom off;
    pan off;
    mask = handles.mask;
    %create vertices from mask
    vert = cell(max(mask(:)),1);
    for ii = 1:max(mask(:))
        try
            vert{ii} = mask2poly(mask==ii,'Inner','MinDist');
        catch me
            vert{ii} = [];
        end
    end

    save([strtok(handles.fn,'.') '.segment'],'mask','vert');
    fprintf('Saved segments\n');


% --- Executes on button press in btnUndo.
function btnUndo_Callback(hObject, eventdata, handles)
% hObject    handle to btnUndo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
themax = max(handles.mask(:));
handles.mask(handles.mask==themax) = 0;
guidata(hObject,handles);
handles.txtStatus.String = max(handles.mask(:));
drawfgim(handles);
drawfloodim(handles);


% --- Executes on button press in btnExtract.
function btnExtract_Callback(hObject, eventdata, handles)
% hObject    handle to btnExtract (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % draw ring around each ROI to carry out neuropil subtraction
    allmasks_bin = handles.mask > 0;
    se=strel('disk',7); % <-- configure size here
    for j = 1:max(max(handles.mask))
        cur_roi = handles.mask==j;
        if max(max(cur_roi)) > 0
            handles.np_masks{j} = (imdilate(cur_roi,se)-allmasks_bin)>0;
            p=regionprops(handles.np_masks{j});
            handles.np_outlines{j}=p.BoundingBox;
        else
            disp(j);
            handles.np_masks{j} = zeros(size(handles.mask));
        end
            
    end
    guidata(hObject,handles);
    
    
    
    % Extract brightness values
    % read data from .sbx file
    img_data = sbxgrabframe(handles.fn,1,-1);
    % for now we assume there is only a single channel
    img_data = squeeze(img_data);
    % determine number of frames
    numImages = size(img_data,3);
    
    roiValues_norm = zeros(numImages,max(max(handles.mask)));
    roiValues_normby = zeros(numImages,max(max(handles.mask)));
    roiValues = zeros(numImages,max(max(handles.mask)));
    
    c = 0;
    for i=1:numImages
        c=c+1;
        if (rem(i,100)==0)
            fprintf('extracting %d/%d (%d%%)\n',i,numImages,round(100*(i./numImages)));
        end;
        % imageToMeasure=uint16(imread([readInDirectory 'registered_' int2str(i)],'png'));
        imageToMeasure = img_data(:,:,i);
        
        for j = 1:max(max(handles.mask))
            cur_roi = handles.mask == j;
            if max(max(cur_roi)) > 0
                roi_outline = find(handles.mask==j);
                [xc,yc] = ind2sub([512,796], roi_outline);
                xa=ceil(min(xc));
                xb=floor(max(xc));
                ya=ceil(min(yc));
                yb=floor(max(yc));
                roiValues(i,j)=mean(mean(imageToMeasure(xa:xb,ya:yb).*uint16(cur_roi(xa:xb,ya:yb))));
                if 1 % normalize?   % <---- neuropil correction
                    neuropil_outline = find(handles.np_masks{j}==1);
                    [xc,yc] = ind2sub([512,796], neuropil_outline);
                    xanp=ceil(min(xc));
                    xbnp=floor(max(xc));
                    yanp=ceil(min(yc));
                    ybnp=floor(max(yc));
                    m=mean(trimmean(imageToMeasure(xanp:xbnp,yanp:ybnp).*uint16(handles.np_masks{j}(xanp:xbnp,yanp:ybnp)),10));
                    roiValues_normby(i,j)=m;

                    % -----------------
                    roiValues_norm(i,j)=roiValues(i,j) - m.*.75; % <---- configure neuropil correction method here
                    % -----------------

                end
            end      
        end
    end
    %save([handles.fn '.sig'],'roiValues_norm','roiValues_normby','roiValues');
    csvwrite([handles.fn '.sig'],[roiValues_norm,roiValues_normby,roiValues]);
    csvwrite([handles.fn '.bri'],[handles.mean_brightness]);
    
    disp('done');

% --- Executes on button press in cblxcorr.
function cblxcorr_Callback(hObject, eventdata, handles)
% hObject    handle to cblxcorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cblxcorr


% --- Executes on button press in btDown.
function btDown_Callback(hObject, eventdata, handles)
% hObject    handle to btDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if handles.cbMoveroi.Value == 0
    handles.mask = circshift(handles.mask,1,1);
    drawfgim(handles);
    draw_image(handles);
else
    handles.roimask = circshift(handles.roimask,1,1);
    drawroimask(handles)
end
guidata(hObject,handles);


% --- Executes on button press in btLeft.
function btLeft_Callback(hObject, eventdata, handles)
% hObject    handle to btLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if handles.cbMoveroi.Value == 0
    handles.mask = circshift(handles.mask,-1,2);
    drawfgim(handles);
    draw_image(handles);
else
    handles.roimask = circshift(handles.roimask,-1,2);
    drawroimask(handles)
end
guidata(hObject,handles);


% --- Executes on button press in btRight.
function btRight_Callback(hObject, eventdata, handles)
% hObject    handle to btRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if handles.cbMoveroi.Value == 0
    handles.mask = circshift(handles.mask,1,2);
    drawfgim(handles);
    draw_image(handles);
else
    handles.roimask = circshift(handles.roimask,1,2);
    drawroimask(handles)
end
guidata(hObject,handles);


% --- Executes on button press in btUp.
function btUp_Callback(hObject, eventdata, handles)
% hObject    handle to btUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
if handles.cbMoveroi.Value == 0
    handles.mask = circshift(handles.mask,-1,1);
    drawfgim(handles);
    draw_image(handles);
else
    handles.roimask = circshift(handles.roimask,-1,1);
    drawroimask(handles)
end
guidata(hObject,handles);


% --- Executes on button press in cbMoveroi.
function cbMoveroi_Callback(hObject, eventdata, handles)
% hObject    handle to cbMoveroi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbMoveroi
