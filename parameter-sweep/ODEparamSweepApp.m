function varargout = ODEparamSweepApp(varargin)
% ODEPARAMSWEEPAPP MATLAB code for ODEparamSweepApp.fig
%      ODEPARAMSWEEPAPP, by itself, creates a new ODEPARAMSWEEPAPP or raises the existing
%      singleton*.
%
%      H = ODEPARAMSWEEPAPP returns the handle to a new ODEPARAMSWEEPAPP or the handle to
%      the existing singleton*.
%
%      ODEPARAMSWEEPAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ODEPARAMSWEEPAPP.M with the given input arguments.
%
%      ODEPARAMSWEEPAPP('Property','Value',...) creates a new ODEPARAMSWEEPAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the App before ODEparamSweepApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ODEparamSweepApp_OpeningFcn via varargin.
%
%      *See UI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2013-2015 The MathWorks, Inc.

% Edit the above text to modify the response to help ODEparamSweepApp

% Last Modified by GUIDE v2.5 01-Jan-2018 17:05:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ODEparamSweepApp_OpeningFcn, ...
    'gui_OutputFcn',  @ODEparamSweepApp_OutputFcn, ...
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


% --- Executes just before ODEparamSweepApp is made visible.
function ODEparamSweepApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ODEparamSweepApp (see VARARGIN)

% Choose default command line output for ODEparamSweepApp
handles.output = hObject;
title('  ');

handles.serialHistory.UserData.useFileHistory=1;  % Set to 0, unless on a workstation
handles.serialHistory.UserData.changeDefaultSizes=0; % Changes UI values based on number of workers

lD=ODEparamSweeplimsDefaults(handles);
if handles.checkbox2==1
    thisVar='a';
else
    thisVar='n';
end
handles.hNumEdit.UserData=lD.h.defaultVal;
handles.maxNEdit.UserData=lD.(thisVar).defaultVal;

handles.hNumEdit.String =num2str(handles.hNumEdit.UserData);
handles.maxNEdit.String =num2str(handles.maxNEdit.UserData);

handles.serialHistory.UserData.percNow=cpuThrottleCheck;
handles.serialHistory.UserData.percLast=handles.serialHistory.UserData.percNow;

% Update handles structure
guidata(hObject, handles);

movegui(hObject, 'center');

%Update parallel information
resetKey(hObject, eventdata,handles,0,0);
updateParallel(hObject, eventdata,handles);
%updateHistory(handles);

% UIWAIT makes ODEparamSweepUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ODEparamSweepApp_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in StartButton.
function StartButton_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to StartButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hadError=0;

set(handles.serialButton  , 'enable', 'off');
set(handles.parforButton, 'enable', 'off');
set(handles.parfevalButton  , 'enable', 'off');
set(handles.checkbox2   , 'enable', 'off');
set(handles.maxNEdit   , 'enable', 'off');
set(handles.hNumEdit   , 'enable', 'off');
set(handles.StartButton   , 'enable', 'off');
set(handles.checkbox3   , 'enable', 'off');
set(handles.compareCodeButton   , 'enable', 'off');


rtyps={'serialTime','parforTime','parfevalTime'};
for tt=1:length(rtyps)
    handles.(rtyps{tt}).FontWeight='normal';
end

guidata(hObject, handles);
drawnow

try
    needsToLoop=1;
    
    while needsToLoop
        set(handles.checkbox3   , 'enable', 'off');
        
        button_state = get(hObject,'Value');
        
        [fh,th,isParallel]=getRunOption(hObject, eventdata,handles);
        skipIt=0;
        
        if isParallel
            try
                p=gcp;
                if isempty(p)
                    % This is necessary if preferences do not start a pool when
                    % needed
                    p=parpool;
                end
                updateParallel(hObject, eventdata,handles);
                
                if isempty(p)
                    updateParallel(hObject, eventdata,handles,'Error: Unable to start a pool of workers');
                    skipIt=1;
                    needsToLoop=0;
                end
                
            catch
                disp(lasterr) %#ok<LERR>
                updateParallel(hObject, eventdata,handles,'Error: Unable to start a pool of workers, see session');
                skipIt=1;
                needsToLoop=0;
            end
        end
        
        if ~skipIt
            resetKey(hObject, eventdata,handles,1,1);
            updateParallel(hObject, eventdata,handles);
            
            drawnow
            
            [nVals,aVals,hVals,thisSfile,thisPfile,percNow]=getNAH(handles);
            
            
            handles.serialHistory.UserData.percLast=handles.serialHistory.UserData.percNow;
            handles.serialHistory.UserData.percNow=percNow;
            
            if button_state == get(hObject,'Max')
                set(hObject,'String', 'Running')
                set(handles.StartButton   , 'enable', 'off');
                guidata(hObject, handles);
                updateParallel(hObject, eventdata,handles);
                
                try
                    L=1;
                    showTruss=0;
                    
                    p=gcp('nocreate');
                    
                    t = tic;
                    peakVals=fh(nVals,hVals,aVals,L,showTruss, handles.TopAxes); %#ok<NASGU
                    et = toc(t);
                    
                    if strcmp(th,'serialTime') || strcmp(p.Cluster.Profile,'local');
                        percNowNew=cpuThrottleCheck;
                    else
                        percNowNew=percNow;
                    end
                    
                    if percNowNew == percNow
                        if strcmp(th,'serialTime')
                            thisFile=thisSfile;
                        else
                            thisFile=thisPfile;
                        end
                        
                        if ~exist(thisFile,'file') && handles.serialHistory.UserData.useFileHistory
                            save(thisFile,'peakVals','nVals','hVals','aVals','L')
                        end
                        
                        handles.(th).UserData=[handles.(th).UserData et];
                        handles.(th).FontWeight='bold';
                        
                        % augment and save current data here
                        dh=strrep(th,'Time','Data');
                        tmpD=handles.(th).UserData; %#ok<NASGU>
                        eval([dh '=tmpD;']);
                        save(thisFile,dh,'-append');
                        
                        updateHistory(handles);
                        drawnow
                        eMsg2=[];
                    else
                        eMsg2='Power mode changed';
                    end
                    
                    if strcmp(th,'parfevalTime')
                        set(hObject,'String', 'paused');
                        set(handles.checkbox3   , 'enable', 'on');
                        pause(1.5);
                        set(handles.checkbox3   , 'enable', 'off');
                    end
                    
                    set(hObject,'String', 'Start');
                    updateParallel(hObject, eventdata,handles, eMsg2);
                catch
                    eMsg=lasterr; %#ok<LERR>
                    updateParallel(hObject, eventdata,handles,eMsg);
                    set(hObject,'String', 'Start');
                    needsToLoop=0; %#ok<NASGU>
                    hadError=1;
                end
            else % Button state not at max
                set(hObject,'String', 'Start');
                return
            end
            
            % moved call to udpateParallel above
            drawnow
            
            set(handles.TopAxes,'Visible','on')
            guidata(hObject, handles);
            
            if handles.checkbox3.Value==1 && strcmp(th,'parfevalTime');
                needsToLoop=1;
            else
                needsToLoop=0;
            end
        else  % skipIt
            set(handles.serialButton  , 'enable', 'on');
            set(handles.parforButton, 'enable', 'on');
            set(handles.parfevalButton  , 'enable', 'on');
            set(handles.checkbox2   , 'enable', 'on');
            set(handles.maxNEdit   , 'enable', 'on');
            set(handles.hNumEdit   , 'enable', 'on');
            set(handles.StartButton   , 'enable', 'on');
            set(handles.checkbox3   , 'enable', 'on');
            set(handles.compareCodeButton   , 'enable', 'on');
        end
    end
    
    set(handles.serialButton  , 'enable', 'on');
    set(handles.parforButton, 'enable', 'on');
    set(handles.parfevalButton  , 'enable', 'on');
    set(handles.checkbox2   , 'enable', 'on');
    set(handles.maxNEdit   , 'enable', 'on');
    set(handles.hNumEdit   , 'enable', 'on');
    set(handles.StartButton   , 'enable', 'on');
    set(handles.checkbox3   , 'enable', 'on');
    set(handles.compareCodeButton   , 'enable', 'on');
    
    drawnow
    
    if hadError
        eMsg=lasterr; %#ok<LERR>
        updateParallel(hObject, eventdata,handles,eMsg);
        set(hObject,'String', 'Start');
        needsToLoop=0; %#ok<NASGU>
    end
    
catch
    lasterr %#ok<LERR>
    fprintf(1,'\nApp terminated\n');
    return
end


function maxNEdit_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to maxNEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxNEdit as text
%        str2double(get(hObject,'String')) returns contents of maxNEdit as a double

lD=ODEparamSweeplimsDefaults(handles);

if handles.checkbox2==1
    thisVar='a';
else
    thisVar='n';
end

val = str2double(handles.maxNEdit.String);
if isempty(val)
    val=NaN;
end

if ~isnan(val)
    val = max(val,lD.(thisVar).valLims(1));
    val = min(val,lD.(thisVar).valLims(2));
    val = round(val);
end

if ~isnan(val) && val~=handles.maxNEdit.UserData
    handles.maxNEdit.String=num2str(val);
    
    % Reset data if change is made
    resetKey(hObject, eventdata,handles,0,0);
    updateParallel(hObject, eventdata,handles);
else
    handles.maxNEdit.String=num2str(handles.maxNEdit.UserData);
end
handles.maxNEdit.UserData=str2double(handles.maxNEdit.String);
guidata(hObject, handles);


function hNumEdit_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to maxNEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lD=ODEparamSweeplimsDefaults(handles);

val = str2double(handles.hNumEdit.String);
if isempty(val)
    val=NaN;
end

if ~isnan(val)
    val = max(val,lD.h.valLims(1));
    val = min(val,lD.h.valLims(2));
    val = round(val);
end

if ~isnan(val) && val~=handles.hNumEdit.UserData
    handles.hNumEdit.String=num2str(val);
    
    % Reset data if change is made
    resetKey(hObject, eventdata,handles,0,0)
    updateParallel(hObject, eventdata,handles);
else
    handles.hNumEdit.String=num2str(handles.hNumEdit.UserData);
    
end
handles.hNumEdit.UserData=str2double(handles.hNumEdit.String);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function maxNEdit_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to maxNEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function hNumEdit_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to maxNEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in compareCodeButton.
function compareCodeButton_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to compareCodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fh,~,isParallel]=getRunOption(hObject, eventdata,handles);
if isParallel
    visdiff('paramSweepSerial.m',[char(fh) '.m'])
else
    edit('paramSweepSerial.m');
end


% --- Executes when selected object is changed in resultsPanel.
function resultsPanel_SelectionChangeFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to the selected object in resultsPanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

updateParallel(hObject, eventdata,handles);

% Reset data during calculations, etc
function resetKey(hObject, ~, handles,leaveSerial,leaveParallel)

if ~leaveSerial
    handles.serialTime.String='';
    handles.serialTime.UserData=[];
    handles.serialHistory.String='';
end

if ~leaveParallel
    handles.parforTime.String='';
    handles.parforTime.UserData=[];
    handles.parforHistory.String='';
    
    handles.parfevalTime.String='';
    handles.parfevalTime.UserData=[];
    handles.parfevalHistory.String='';
end

handles.StartButton.String='Start';
guidata(hObject, handles);

cla(handles.TopAxes);
drawnow;


%Update display about matlabpool or other message
function updateParallel(hObject, eventdata, handles,overrideMsg)

oldText=handles.matlabpoolText.String;
percNow=handles.serialHistory.UserData.percNow;

noOverRide=1;

if nargin==4
    if ~isempty(overrideMsg)
        noOverRide=0;
    end
end

if noOverRide
    p=gcp('nocreate');
    if percNow~=0 
        percStr=sprintf(', Local processor at %d%%',percNow);
    else
        percStr='';
    end
    if ~isempty(p)
        newText=sprintf('Pool of %d workers (%s)%s',p.NumWorkers, p.Cluster.Profile,percStr);
    else
        newText=sprintf('Pool of workers not started%s',percStr);
    end
    handles.matlabpoolText.ForegroundColor=[0 0 0];
else
    newText=overrideMsg;
    if strfind(lower(overrideMsg),'error')
        handles.matlabpoolText.ForegroundColor=[1 0 0];
    else
        handles.matlabpoolText.ForegroundColor=[0 0 0];
    end
end

handles.matlabpoolText.String=newText;
if ~strcmp(oldText,newText)
    if ~isempty(oldText)
        resetKey(hObject, eventdata,handles,0,0);
        guidata(hObject, handles);
    end
end


function parSerButtonGroup_SelectionChangeFcn(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to the selected object in parSerButtonGroup
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
updateParallel(hObject, eventdata,handles);

function [fh,th,isParallel]=getRunOption(hObject, eventdata,handles)

pSG=get(handles.parSerButtonGroup);
pSGSO=get(pSG.SelectedObject);
runOption=pSGSO.String;

switch(runOption)
    case 'parfor'
        isParallel=1;
        fh=@paramSweepParallel;
        th='parforTime';
        resetKey(hObject, eventdata,handles,1,1);
        
    case 'for (serial)'
        isParallel=0;
        fh=@paramSweepSerial;
        th='serialTime';
        resetKey(hObject, eventdata,handles,1,1);
        
    case 'parfeval'
        isParallel=1;
        fh=@paramSweepParfeval;
        th='parfevalTime';
        resetKey(hObject, eventdata,handles,1,1);
        
    otherwise
        error('unrecognized string from radio buttons');
end

guidata(hObject,handles);
drawnow


function checkbox2_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

lD=ODEparamSweeplimsDefaults(handles);


if get(hObject,'Value')==1
    handles.maxNText.String='num cross sections';
    handles.maxNEdit.UserData=lD.a.defaultVal;
else
    handles.maxNText.String='num segment choice';
    handles.maxNEdit.UserData=lD.n.defaultVal;
end

handles.maxNEdit.String=num2str(handles.maxNEdit.UserData);

resetKey(hObject, eventdata,handles,0,0);



% --- Executes on button press in looper
function checkbox3_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


function lD=ODEparamSweeplimsDefaults(handles)
%% NOTE: DO NOT CHANGE THESE: WILL BREAK ASSUMPTIONS OF LOAD/SAVE

lD.a.valLims=[3 30];
lD.a.range=[.2 .25];

lD.n.valLims=[2 30];
lD.n.range=[2 22];  % range(1) + valLime(2) needs to be <= range(2)

lD.h.valLims=[3 30];
lD.h.range=[.2 .5];

% defaults for actual values
lD.a.staticValue=mean(lD.a.range);
lD.n.staticValue=mean(lD.n.range);

%% Below this line can be changed as needed

p=gcp('nocreate');
if isempty(p)
    theseWkrs=0;
else
    theseWkrs=p.NumWorkers;
end

% Defaults for number of values (applies only at startup in current code)
if handles.serialHistory.UserData.changeDefaultSizes && theseWkrs<16
    lD.a.defaultVal=4;  % Should match UI if handles.checkbox2==1
    lD.n.defaultVal=4;  % Should match UI if handles.checkbox2==0
    lD.h.defaultVal=4;
else
    lD.a.defaultVal=6;%24;  % Should match UI if handles.checkbox2==1
    lD.n.defaultVal=3;% 12;  % Should match UI if handles.checkbox2==0
    lD.h.defaultVal=7;% 24;
end



function [nVals,aVals,hVals,thisSfile,thisPfile,percNow]=getNAH(handles)
lD=ODEparamSweeplimsDefaults(handles);
if handles.checkbox2.Value==0
    numN=str2double(handles.maxNEdit.String);
    nVals=lD.n.range(1)+(0:( numN-1));
    aVals=lD.a.staticValue;
    numA=1;
else
    nVals=lD.n.staticValue;
    numA=str2double(handles.maxNEdit.String);
    aVals=linspace(lD.a.range(1),lD.a.range(2),numA);
    numN=1;
end
numH=str2double(handles.hNumEdit.String);
hVals=linspace(lD.h.range(1),lD.h.range(2),numH);

percNow=cpuThrottleCheck;

percNowString=sprintf('cpu%03i_',percNow);


aMode=handles.checkbox2.Value;
[~,thisHost]=system('hostname');  % Note: you might need to updsate this for Linux
thisSfile=sprintf('%s_cs%i_a%03i_h%03i_n%03i_%sS.mat',deblank(thisHost),aMode,numA,numH,numN,percNowString);

percNowStringP=[];

p=gcp('nocreate');


thisPfile=[];
if ~isempty(p)
    if strcmp(p.Cluster.Profile,'local')
        percNowStringP=percNowString;
    end
    
    thisPfile=sprintf('%s_cs%i_a%03i_h%03i_n%03i_%s%s_%i.mat',deblank(thisHost),aMode,numA,numH,numN,percNowStringP,p.Cluster.Profile,p.NumWorkers);
end


thisSfile=fullfile('.',thisSfile);
if ~isempty(thisPfile)
    thisPfile=fullfile('.',thisPfile);
end




function updateHistory(handles)

[~,~,~,thisSfile,thisPfile]=getNAH(handles);

if exist(thisSfile,'file');
    X=load(thisSfile);
else
    X=[];
end

if exist(thisPfile,'file');
    X2=load(thisPfile);
else
    X2=[];
end



lst={'serialTime','parforTime','parfevalTime'};

if isempty(X)
    X=X2;
else
    if ~isempty(X2)
        for ll=2:length(lst)
            xlst=lst{ll};
            xlst=strrep(xlst,'Time','Data');
            if isfield(X2, xlst)
                X.(xlst)=X2.(xlst);
            end
        end
    end
end

for xx=1:length(lst)
    if isempty(handles.(lst{xx}).UserData)
        dLst=strrep(lst{xx},'Time','Data');
        if isfield(X,dLst)
            handles.(lst{xx}).UserData = X.(dLst);
        end
    end
end

if ~isempty(handles.serialTime.UserData)
    serialData=handles.serialTime.UserData;
    speedRef=mean(serialData);
else
    serialData=[];
    speedRef=[];
end

for xx=1:length(lst)
    tth=lst{xx};
    
    tthH=strrep(tth,'Time','History');
    
    thisLng=length(handles.(tth).UserData);
    if thisLng>0
        lclT=handles.(tth).UserData(end);
        if ~isempty(serialData) && ~strcmp(tth,'serialTime');
            lastAvgTxt=sprintf('%0.1fs %1.1fx',lclT,serialData(end)/lclT);
        else
            lastAvgTxt=sprintf('%0.1fs',lclT);
        end
        
        handles.(tth).String=sprintf('%s',lastAvgTxt);
        thisAvg=mean(handles.(tth).UserData);
        if ~isempty(speedRef) && ~strcmp(tth,'serialTime');
            handles.(tthH).String=sprintf('%0.1fs %1.1fx (%i)',thisAvg,speedRef/thisAvg,thisLng);
        else
            handles.(tthH).String=sprintf('%0.1fs \t\t (%i)',thisAvg,thisLng);
        end
    end
end


% --- Executes during object creation, after setting all properties.
function resultsPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resultsPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
