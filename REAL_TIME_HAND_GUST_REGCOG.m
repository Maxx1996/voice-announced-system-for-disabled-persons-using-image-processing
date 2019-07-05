function varargout = REAL_TIME_HAND_GUST_REGCOG(varargin)
% REAL_TIME_HAND_GUST_REGCOG MATLAB code for REAL_TIME_HAND_GUST_REGCOG.fig
%      REAL_TIME_HAND_GUST_REGCOG, by itself, creates a new REAL_TIME_HAND_GUST_REGCOG or raises the existing
%      singleton*.
%
%      H = REAL_TIME_HAND_GUST_REGCOG returns the handle to a new REAL_TIME_HAND_GUST_REGCOG or the handle to
%      the existing singleton*.
%
%      REAL_TIME_HAND_GUST_REGCOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REAL_TIME_HAND_GUST_REGCOG.M with the given input arguments.
%
%      REAL_TIME_HAND_GUST_REGCOG('Property','Value',...) creates a new REAL_TIME_HAND_GUST_REGCOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before REAL_TIME_HAND_GUST_REGCOG_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to REAL_TIME_HAND_GUST_REGCOG_OpeningFcn via varargin.
%
 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @REAL_TIME_HAND_GUST_REGCOG_OpeningFcn, ...
                   'gui_OutputFcn',  @REAL_TIME_HAND_GUST_REGCOG_OutputFcn, ...
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


% --- Executes just before REAL_TIME_HAND_GUST_REGCOG is made visible.
function REAL_TIME_HAND_GUST_REGCOG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to REAL_TIME_HAND_GUST_REGCOG (see VARARGIN)

% Choose default command line output for REAL_TIME_HAND_GUST_REGCOG
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
axes(handles.axes1);
imshow('SS.jpg')

% UIWAIT makes REAL_TIME_HAND_GUST_REGCOG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = REAL_TIME_HAND_GUST_REGCOG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%menciptakan object akuisisi dari web-cam
%s=connect_bluetooth;

vidDevice = imaq.VideoDevice('winvideo', 1, 'YUY2_640x480', ...
'ROI', [1 1 640 480], ...
'ReturnedColorSpace', 'rgb');

%  object video player original
hVideoIn = vision.VideoPlayer;
hVideoIn.Name = 'Original Video';
hVideoIn.Position = [30 100 640 480];

% object video player fingers tracking
hVideoOut = vision.VideoPlayer;
hVideoOut.Name = 'Fingers Tracking Video';
hVideoOut.Position = [700 100 640 480];

%  blob analysis
hblob = vision.BlobAnalysis('AreaOutputPort', false, ...  
                                'CentroidOutputPort', true, ... %  
                                'BoundingBoxOutputPort', true', ... %  
                                'MinimumBlobArea', 800, ... % 
                                'MaximumBlobArea', 3000, ... %  
                                'MaximumCount', 10); %  
                             
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ...%%Set Red box handling%%
                                        'CustomBorderColor', [1 0 0], ...
                                        'Fill', true, ...
                                        'FillColor', 'Custom', ...
                                        'CustomFillColor', [1 0 0], ...
                                        'Opacity', 0.4);
                                    
%  text inserter 1   

htextins = vision.TextInserter('Text', 't: %2d', ... % Set text for number of blobs
                                    'Location',  [12 20], ...
                                    'Color', [0 1 0], ... // red color
                                    'FontSize', 16);
                               
                               
                                
                         
                                
%  text inserter 2                                
htextinsCent = vision.TextInserter('Text', ' , Y:%4d', ... % set text for centroid
                                    'LocationSource', 'Input port', ...
                                    'Color', [1 4 0], ... // yellow color
                                    'FontSize', 1);

%%%%%%%%%%%%%%%%%%%%%%%%% Program Inti %%%%%%%%%%%%%%%%%%%%%%%%%
nFrames = 0;
while (nFrames <= 800) %  200 Frame  
    rgbData = step(vidDevice); % frame
    rgbData = flipdim(rgbData,2);  
    data = rgbData;
    
    % Skin Segmentation
    diff_im = imsubtract(data(:,:,1), rgb2gray(data)); % grayscale
    diff_im = medfilt2(diff_im, [3 3]); %filtering
    diff_im = imadjust(diff_im); % color-maping  
    level = graythresh(diff_im); %  otsu methode
    bw = im2bw(diff_im,level); %  binary image
    bwfill = medfilt2(imfill(bw,'holes'), [3 3]);  
    
    % Fingers Extraction
    se1 = strel('disk',28);
    kikis = imerode(bwfill,se1);
    
    se2 = strel('disk',40);
    tebalin = imdilate(kikis,se2);    
    
    hasil = imsubtract(bwfill,tebalin);
    se3 = strel('disk',5);
    jari = imerode(hasil,se3);
    jari = im2bw(jari);
    
    % Representation
    [centroid, bbox] = step(hblob, jari); %% %  bounding box dari blobs
    centroid = uint16(centroid); %   centroid
    data(1:40,1:250,:) = 0; % black label on the top corner of the video player fingers tracker
    vidIn = step(hshapeinsRedBox, data, bbox); %  
    for object = 1:1:length(bbox(:,1)) %Give Coodinate on box
        centX = centroid(object,1); centY = centroid(object,2);
        vidIn = step(htextinsCent, vidIn, [centX centY], [centX-6 centY-9]); 
    end
    finger=uint8(length(bbox(:,1)))
    [vidIn] = step(htextins, vidIn, uint8(length(bbox(:,1)))); %% counting the no of box
    rgb_Out = vidIn;
        
        if (finger==5)
            
             diary = 'i need water';
     
     
 
    NET.addAssembly('System.Speech');
    Speaker = System.Speech.Synthesis.SpeechSynthesizer;
    if ~isa(diary,'cell')
        diary = {diary};
    end
    for k=1:length(diary)
        Speaker.Speak (diary{k});
    end
        elseif(finger==7)
             diary = 'i need help';
     
     
 
    NET.addAssembly('System.Speech');
    Speaker = System.Speech.Synthesis.SpeechSynthesizer;
    if ~isa(diary,'cell')
        diary = {diary};
    end
    for k=1:length(diary)
        Speaker.Speak (diary{k});
    end
    
        end
        
            
     
    step(hVideoIn, rgbData); % 
    step(hVideoOut, rgb_Out); % 
    nFrames = nFrames + 1;
end

%release semua object video
release(hVideoOut);
release(hVideoIn);
release(vidDevice);
