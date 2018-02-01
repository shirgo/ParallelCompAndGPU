function celltowerApp()
% CELLTOWERAPP

% Default Parameter Values
default.towers = [20 40];
default.side   = [10 15];
default.seed   = [5  5 ];
default.tol    = [0.1 0.1];

minTowers=3;
maxTowers=100;

% Initial Parameters

idx  = 2;
serialTime   = nan;
parallelTime = nan;

param.towers = default.towers(idx);
param.side   = default.side(idx);
param.seed   = default.seed(idx);
param.tol    = default.tol(idx);

% Generate Figure
figH = findobj('type', 'figure', 'tag', 'phonetowerGUI');
if ishandle(figH)
   close(figH);
end
figH = figure(...
   'name'                            , 'Phone Tower Location', ...
   'windowstyle'                     ,'normal',...
   'numbertitle'                     , 'off', ...
   'tag'                             , 'phonetowerGUI', ...
   'color'                           , [.8 .8 .8], ...
   'menubar'                         , 'none', ...
   'defaultuicontrolunits'           , 'normalized', ...
   'defaultuicontrolbackgroundcolor' , [.8 .8 .8], ...
   'defaultuicontrolfontunits'       , 'points', ...
   'defaultuicontrolfontsize'        , 11,...
   'position'						 , [ 300 100 600 450]);  % good for 1024x768

axes(...
   'units'           , 'normalized', ...
   'position'        , [.05 .1 .65  .8],...
   'box'             , 'on', ...
   'tag'             , 'mainaxes', ...
   'FontUnits'       , 'normalized');

% placement values 
xb1=.72;  yb1=.80; xbw=.13; ybh=.05;
ybo=.07;

uicontrol(...
   'style'           , 'text', ...
   'horizontalalignment', 'left',...
   'position'        , [xb1 yb1 xbw, ybh], ...
   'fontweight'      , 'bold', ...
   'string'          , 'Seed');
uicontrol(...
   'style'           , 'text', ...
   'horizontalalignment', 'left',...
   'position'        , [xb1 yb1-ybo xbw, ybh], ...
   'fontweight'      , 'bold', ...
   'string'          , 'Towers');
uicontrol(...
   'style'           , 'text', ...
   'horizontalalignment', 'left',...
   'position'        , [xb1 yb1-2*ybo xbw, ybh], ...
   'fontweight'      , 'bold', ...
   'string'          , 'Side');
uicontrol(...
   'style'           , 'text', ...
   'horizontalalignment', 'left',...
   'position'        , [xb1 yb1-3*ybo xbw, ybh], ...
   'fontweight'      , 'bold', ...
   'string'          , 'Tolerance');
uicontrol(...
   'style'           , 'edit', ...
   'position'        , [xb1+xbw yb1 xbw, ybh], ...
   'backgroundcolor' , 'white', ...
   'string'          , num2str(param.seed), ...
   'callback'        , @changeParamCallback, ...
   'tag'             , 'seed');
uicontrol(...
   'style'           , 'edit', ...
   'position'        , [xb1+xbw yb1-ybo xbw, ybh], ...
   'backgroundcolor' , 'white', ...
   'string'          , num2str(param.towers), ...
   'callback'        , @changeParamCallback, ...
   'tag'             , 'towers');
uicontrol(...
   'style'           , 'text', ...
   'position'        , [xb1+xbw yb1-2*ybo xbw, ybh], ...
   'string'          , num2str(param.side), ...
   'tag'             , 'side');

uicontrol(...
   'style'           , 'text', ...
   'position'        , [xb1+xbw yb1-3*ybo xbw, ybh], ...
   'string'          , num2str(param.tol), ...
   'tag'             , 'tol');

% placement values
xp1=.75;  yp1=.45; yph=.07;
ypo=.1;

newbg=[.9 .9 .9];

uicontrol(...
   'style'           , 'pushbutton', ...
   'backgroundcolor', newbg,...
   'position'        , [xp1 yp1 .2, yph], ...
   'fontweight'      , 'bold', ...
   'callback'        , @runBtnCallback, ...
   'string'          , 'Run', ...
   'tag'             , 'run');

uicontrol(...
   'style'           , 'togglebutton', ...
'backgroundcolor', newbg,...   
'position'        , [xp1 yp1-ypo .2, yph], ...
   'fontweight'      , 'bold', ...
   'callback'        , @pauseBtnCallback, ...
   'string'          , 'Pause', ...
   'tag'             , 'pause', ...
   'enable'          , 'off');


htoggle = uibuttongroup('Position',[.72 .05 .27, .25], ...
   'backgroundcolor', newbg);

% placement values
tx1=.05; ty1=.01; tbx1=.50; tby=.33;
tx2=.57; ty2=.37; tbx2=.4;
         ty3=.66;
         
toggleobj(1) = uicontrol('Style','Radio','String','Serial:','units','normalized',...
    'pos',[tx1 ty3 tbx1 tby],'parent',htoggle,'backgroundcolor', newbg);
toggleobj(2) = uicontrol('Style','Radio','String','Parallel:','units','normalized',...
   'pos',[tx1 ty2 tbx1 tby],'parent',htoggle,'backgroundcolor', newbg);
uicontrol(...
    'Parent', htoggle, ...
    'Style', 'text', ...
     'backgroundcolor', newbg,...
    'Position', [tx1 ty1 tbx1 tby], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Speed Up: ');
hSerialTime = uicontrol(...
    'Parent', htoggle, ...
    'Style', 'text', ...
    'backgroundcolor', newbg,...
    'Position', [tx2 ty3-.06 tbx2 tby], ...
    'HorizontalAlignment', 'right', ...
    'String', '');
hParallelTime = uicontrol(...
    'Parent', htoggle, ...
    'Style', 'text', ...
     'backgroundcolor', newbg,...
    'Position', [tx2 ty2-.08 tbx2 tby], ...  
    'HorizontalAlignment', 'right', ...
    'String', '');
hSpeedUp = uicontrol(...
    'Parent', htoggle, ...
    'Style', 'text', ...
     'backgroundcolor', newbg,...
    'Position', [tx2 ty1 tbx2 tby], ...
    'HorizontalAlignment', 'right', ...
    'String', '');
set(htoggle,'SelectedObject',toggleobj(1));  % Default in Serial Mode
      
set(findobj(figH, 'Type', 'uicontrol'), 'FontUnits', 'Normalized');
set(toggleobj, 'FontUnits', 'Normalized');

handles = guihandles(figH);

stopOptim  = false;
pauseOptim = false;

% Initialize
[dimensions, lb, ub, x0] = ...
   helper.celltowersetup(param.towers, param.side, param.seed);

helper.plotFcn(x0, 0, '', dimensions);

%-------------------------------------------------
   function changeParamCallback(obj, edata)
      
      tmp = str2double(get(obj, 'string'));
      
      try
          switch get(obj, 'tag')
              case 'towers'
                  validateattributes(tmp, {'double'}, {'scalar', 'integer', '>=', minTowers, '<=', maxTowers}, '', '"Towers"');
                  param.side = ceil(sqrt(tmp)*2.35);    % dimension of piece of land (one side)
                  set(handles.side  , 'String', param.side);
                 %  param.tol=(1e-1)*round(((tmp/55).^2)); % dimension of piece of land (one side)
                 param.tol = 0.1;
                 set(handles.tol  , 'String', param.tol);
              case 'seed'
                  validateattributes(tmp, {'double'}, {'scalar', '>=', 0}, '', '"Seed"');
          end
      catch ME
         uiwait(errordlg(ME.message, 'modal'));
         tmp = param.(get(obj, 'tag'));
      end
      
      param.(get(obj, 'tag')) = tmp;
      set(obj, 'string', num2str(tmp));
      
      [dimensions, lb, ub, x0] = ...
         helper.celltowersetup(param.towers, param.side, param.seed);
      helper.plotFcn(x0, 0, '', dimensions);
      
      resetTimes;
      
   end

%-------------------------------------------------
   function runBtnCallback(obj, edata)
      
      if strcmp(get(obj, 'string'), 'Run')
         set(obj           , 'string', 'Stop');
         set(handles.pause , 'enable', 'on');
         set(handles.seed  , 'enable', 'off');
         set(handles.towers, 'enable', 'off');
         set(handles.side  , 'enable', 'off');
         set(handles.tol   , 'enable', 'off');
         %set(handles.time  , 'string', '');
         
         options = optimset;
         options = optimset(options, 'Display'    , 'none');
         options = optimset(options, 'TolFun'     , param.tol);
         options = optimset(options, 'OutputFcn'  , {@(x,it,f) helper.plotFcn(x,it,f,dimensions), @helper.myOutputFcn, @optimControlFcn});
         options = optimset(options, 'Algorithm'  , 'active-set');
         isParallel = strcmp(get(get(htoggle,'SelectedObject'),'String'),'Parallel:');
         
        if isParallel
             options = optimset(options, 'UseParallel', 'always');
             disp('Parallel Mode')
         else
             options = optimset(options, 'UseParallel', 'never');           
             disp('Serial Mode')
         end
 
         objfun = iMakeObjFun(dimensions.R);
         
         startTic = tic;
         [~, ~, ~, ~] = ...
            fmincon(objfun,...
            x0, [], [], [], [], lb, ub, [], options); 
         tm = toc(startTic);
       
          % Display execution time
            if isParallel
                parallelTime = tm;
                set(hParallelTime, 'String', sprintf('%0.1f sec', parallelTime));                    
            else
                serialTime = tm;
                set(hSerialTime, 'String', sprintf('%0.1f sec', serialTime));
            end
            
            % Compute speed up if both serial and parallel time exist
            if ~isnan(serialTime) && ~isnan(parallelTime)
                set(hSpeedUp, 'String', sprintf('%0.2fx', serialTime/parallelTime));
            end
         
         %helper.plotOptimSummary(output,dimensions);
         
         if ~ishandle(figH)
            return;
         end
         
         set(obj           , 'string', 'Run');
         set(handles.pause , 'enable', 'off', 'string', 'Pause', 'value', false);
         set(handles.seed  , 'enable', 'on');
         set(handles.towers, 'enable', 'on');
         set(handles.side  , 'enable', 'on');
         set(handles.tol   , 'enable', 'on');
         stopOptim  = false;
         pauseOptim = false;
         
      else
         
         set(obj           , 'string', 'Run');
         set(handles.pause , 'enable', 'off', 'string', 'Pause', 'value', false);
         set(handles.seed  , 'enable', 'on');
         set(handles.towers, 'enable', 'on');
         set(handles.side  , 'enable', 'on');
         set(handles.tol   , 'enable', 'on');
         stopOptim  = true;
         pauseOptim = false;
         
      end
      
   end
%-------------------------------------------------

%-------------------------------------------------
   function pauseBtnCallback(obj, edata)
      pauseOptim = ~pauseOptim;
      if pauseOptim
         set(obj, 'string', 'Resume');
      else
         set(obj, 'string', 'Pause');
      end
   end
%-------------------------------------------------

%-------------------------------------------------
   function stop = optimControlFcn(x,itervals,flag)
      % Control the flow of the optimization (pause, resume, stop)
      
      if ~ishandle(figH)
         stop = true;
         return;
      end
      
      switch flag
         case {'iter', ''}
            while pauseOptim && ishandle(figH)
               drawnow;
            end
      end
      
      stop = stopOptim;
      
   end
%-------------------------------------------------
%-------------------------------------------------

    function resetTimes()
        set(hSerialTime, 'String', '');
        set(hParallelTime, 'String', '');
        set(hSpeedUp, 'String', '');
        serialTime = nan;
        parallelTime = nan;
    end

end
function fun = iMakeObjFun(R)
fun = @(x) helper.objFcn(x, R);
end


%#ok<*INUSD>
%#ok<*INUSL>