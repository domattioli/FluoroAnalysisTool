function guiOut	= main( varargin )
%MAIN Creates a GUI for processing routines of fluoro images.
%   
%   See also MAIN>OPENINGFCN, MAIN>OUTPUTFCN.
%==========================================================================
%{Version 1.0 of MAIN:
% - Builds figure window for GUI.
% - Tries to plot figure in the second display, if it exists.
% - Outputs a UserData structure containing the pathname, filename, 
% original image data, and the computed data ("Info").
% - Currently only accomodates DHS wire navigation, and a Pediatric Elbow
%   wire navigation.
% - Written by: Dominik Mattioli, 08/02/2018; Revised: Dec 2021.
%}

% Check if any figures are currently open and inform user that this code
% will close it.
openFigs = findobj('type','figure');
if ~isempty( openFigs )
    wdlg = warndlg( 'Warning: other opened figure detected; Please save and close your work. FluoroAnalysisTool requires the closing of all other MATLAB figures.',...
        'Open MATLAB Figures', 'Modal');
    return
end

% Build GUI.
global bgColor fgUIowa
bgColor	= [01.00 01.00 00.80];
fgUIowa = [1 205/255 0];
guiName	= 'Fluoroscopic DICOM Image Analysis';
fprintf( sprintf( [repmat( '-', 1, 95 ), '\nBeginning ', guiName, '.\n',...
    repmat( '-', 1, 95 ), repmat( '\n', 1, 5 )] ) );
guiTitle	= 'FluoroAnalysisTool';
gui_State	= struct( 'gui_Name', mfilename,...
    'gui_Callback', [],...
    'gui_LayoutFcn', [],...
    'gui_Singleton', 1 ); % Maybe use this and 'guidata' instead of figHandles function call.
[fh, success]	= OpeningFcn( guiTitle, guiName );

% Handle errors.
switch success
    case -1
        obj	= errordlg(sprintf(['Could not set correct environmental',...
            ' variables;\nEnsure all source code is located in the',...
            ' correct folders.']), 'Failure');
        obj     = matchGUIPosition(fh, obj);
        waitfor(obj);
        close all force
        
    case 0
        obj	= errordlg( sprintf( ['Could not build GUI;\nEnsure all source',...
            ' code is located in the correct folders.'] ), 'Failure' );
        obj     = matchGUIPosition( fh, obj );
        waitfor( obj );
        
        % Close all tcp connections.
        [tcp, tcpClosed] = destroySocketListener( fh.UserData.TCP );
        fh.UserData.set( 'TCP', tcp );
        close all force;
        
    otherwise % Successfully built GUI.
        % Assign GUI data.
        guidata( fh, gui_State );
%         setappdata(0, 'MainGui', gcf); % Unneccessary?
        guiOut	= OutputFcn( [], [], fh );
        % delete(fh);
% clear fh obj guiName guiTitle gui_State
end
end


function [fh, success]	= OpeningFcn( guiTitle, guiName )
%OPENINGFCN Build graphical user interface.
%   
%   See also MAIN, MAIN>OPENINGFCN, MAIN>DELETIONFCN, MAIN>CLOSEREQUESTFCN,
%   MAIN>KEYPRESSFCN, ADDSOURCECODETOPATH, BUILDMENU, BUILDTOOLBAR, 
%   BUILDAXISFOREGROUNDPANEL, BUILDLOADFOREGROUNDPANEL, 
%   BUILDLOGFOREGROUNDPANEL, BUILDPROCEDUREFOREGROUNDPANEL, INITIALIZEM2PY.
%==========================================================================

% Initialize figure.
fh	= figure( 'Name', guiName,...
    'Tag', guiTitle,...
    'Color', 'k',...
    'UserData', guiHandles(),...
    'CloseRequestFcn', @CloseRequestFcn,...
    'KeyPressFcn', @KeyPressFcn,...
    'visible', 'off' );
fh.addlistener( 'ObjectBeingDestroyed', @DeletionFcn );
fh	= setFigureDisplay( fh );

% Waitbar
startEnd	= [0 10];
wb  = waitbar( startEnd( 1 ), ['Booting ', guiTitle, '...'],...
    'Name', 'Startup', 'WindowStyle', 'Modal');
wb.set('CloseRequestFcn', @CloseRequestFcn, 'Units',...
    'Normalized', 'Visible', 'Off' );
wb	= matchGUIPosition( fh, wb );

% Set working path to include all source code of tool.
try
    [~]	= addSourceCodeToPath();
    startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
    wb  = advanceWaitBar( wb, startEnd, ['Booting ', guiTitle, '...'] );
catch
    success = -1;
    return
end

% Begin GUI building.
startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
wb  = advanceWaitBar( wb, startEnd, ['Booting ', guiTitle, '...'] );
set( 0, 'DefaultFigureWindowStyle', 'normal' );	% Do not try to dock GUI.

% GUI Parts that will have same error message if the code fails.
success  = false;
try
    % % Build Menu of GUI.
    % fh  = buildMenu(fh);
    
    % Build Toolbar of GUI.
    startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
    wb  = advanceWaitBar( wb, startEnd, ['Building GUI components of ', guiTitle, '...'] );
    fh  = buildToolbar( fh );
    
    % Create main axis in Axis Foreground Panel.
    startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
    wb  = advanceWaitBar( wb, startEnd, ['Building GUI components of ', guiTitle, '...'] );
    fh	= buildAxisForegroundPanel( fh );
    
    % Create buttons, list box for loading DICOM files in Load Foreground Panel.
    try
        startEnd	= [startEnd( 2 ) startEnd( 2 ) + 10];
        wb  = advanceWaitBar( wb, startEnd, ['Building GUI components of ', guiTitle, '...'] );
        fh	= buildLoadForegroundPanel( fh );
    catch
        errordlg( sprintf( ['Could not build GUI;\nEnsure all source code is',...
            'located in the correct folders.'] ), 'Failure' );
        return
    end
    
    % Create buttons Procedure Foreground Panel (includes 'AP or Lateral' Buttons).
    startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
    wb  = advanceWaitBar( wb, startEnd, ['Building GUI components of ', guiTitle, '...'] );
    fh	= buildProcedureForegroundPanel( fh );
    
    % Create text boxes for displaying information to user in a Log Panel.
    try
        startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
        wb  = advanceWaitBar( wb, startEnd, ['Building GUI components of ', guiTitle, '...'] );
        fh  = buildLogForegroundPanel( fh );
    catch
        errordlg( sprintf( ['Could not build GUI;\nEnsure all source code is',...
            'located in the correct folders.'] ), 'Failure' );
        return
    end
    
    % Force user to login. Note that this callback cannot be run until LogForeground is created.
    startEnd    = [startEnd( 2 ) startEnd( 2 ) + 0.5];
    wb  = advanceWaitBar( wb, startEnd, ['Waiting for user to login to ', guiTitle, '...'] );
    loginHandle = findobj( fh.UserData.Current.FigureToolBar.Children, 'Tag', 'User Login' );
    loginHandle.ClickedCallback{ 1 }( loginHandle, [], fh );

    % Find Python path, start up socket script.
    try
        startEnd    = [startEnd( 2 ) startEnd( 2 ) + 10];
        wb  = advanceWaitBar( wb, startEnd, 'Finding Python Path...' );
        wbPos   = wb.get( 'Position' );
        questUsePython	= mvdlg( 'Will you be using AI models?', 'Python AI Models', horzcat( wbPos( 1:2 ), 0.15, 0.15 ), 'Yes', 'No' );
        switch questUsePython
            case 'Yes'
                % Initialize socket-listener connection.
                [~]	= initializeM2Py( getuserdir );
                [~]	= addNNCodeToPyPath();
                try
                    startEnd    = [startEnd( 2 ) 95];
                    wb  = advanceWaitBar( wb, startEnd, 'Establishing Python Connection...' );
                    [tcp, success]	= initializeSocketListener();  %% NEED CODE TO PREVENT THIS FROM BEING CLOSED BY USER.
                catch
                    errordlg( sprintf( ['Could not initialist MATLAB-python socket;',...
                        '\nEnsure apropriate .h5 model(s) are installed properly'...
                        '\nor try to run this program without using the NN models'] ), 'Failure' );
                    return
                end
        
            otherwise
                tcp	= [];
        end
        fh.UserData.set( 'TCP', tcp );
    catch
        % Couldnt find python.
        errordlg( sprintf( ['Could not find python executable;\nEnsure Python',...
            ' and the relevant libraries are installed straight to the',...
            ' computer.'] ), 'Failure' );
        return
    end
catch
    return
end

% Finally, enable visibility of the GUI.
startEnd    = [startEnd( 2 ) 100];
wb  = advanceWaitBar( wb, startEnd, ['Launching ', guiTitle, '...'] );
pause(.35);
delete( wb );
printToLog(fh, 'Welcome! Please load a directory', 'Progress' );
fh.set( 'Visible', 'on' );                    	% Been invisible until now.
success	= true;
end


function varargout	= OutputFcn(~, ~, fh, varargin)
%OPENINGFCN Outputs GUI results.
%   
%   See also MAIN, MAIN>OPENINGFCN, MAIN>DELETIONFCN.
%==========================================================================

% Get default command line output from handles structure
try
%     varargout{1}	= getappdata(fh);
    % Get figure handles and fluoro data.
    [varargout{1}, ~, ~]	= getFluoroData(fh);
    
catch
    varargout{1}    = NaN;
end
end


function DeletionFcn( ~, ~ )
%DELETIONFCN Execute upon deletion of GUI.
%   Deletes any temporary data created by tool.
%   
%   See also MAIN, MAIN>OPENINGFCN, MAIN>CLOSEREQUESTFCN.
%==========================================================================

% Delete all images in .../data/temp.
execPath    = mfilename( 'fullpath' );
iexecPath   = strfind( execPath, strcat( filesep, 'src') );
tempDataPath	= fullfile( execPath( 1:iexecPath-1 ), 'data', 'temp', 'masks' );
rmdir( tempDataPath, 's' );
mkdir( tempDataPath );
end


function CloseRequestFcn( obj, ~ )
%CLOSEREQUESTFCN Prevents mistaken closure of GUI.
%   
%   See also MAIN, MAIN>OPENINGFCN, MAIN>DELETIONFCN.
%==========================================================================

% Get GUI name if obj does not already handle to it.
guiName     = 'Fluoroscopic DICOM Image Analysis';
if strcmp( obj.get( 'Name' ), guiName )
    % Get waitbar.
    fh  = obj;
    wb  = findobj( 'Tag', 'TMWWaitbar' );
else
    fh	= findobj( 'Name', guiName );
    wb  = obj;
end

% Close request function to display a question dialog box
selection	= questdlg( ['Exit ', fh.get('Tag'), '?'],...
    'Confirmation', 'Yes', 'No', 'No' );
if strcmpi( 'Yes', selection )
    % Close all tcp connections.
    [tcp, tcpClosed] = destroySocketListener( fh.UserData.get( 'TCP' ) );
    if ~tcpClosed
        tcp	= instrfindall( 'Status', 'open' ); 
        for idx = 1:length( tcp )
            [tcp( idx ), ~]     = destroySocketListener( tcp( idx ) );
        end
    end
    try
        fh.UserData.set( 'TCP', tcp( end ) );
    catch
        fh.UserData.set( 'TCP', [] );
    end
    delete( fh );
    delete( wb );
    clear fh wb
else
    return
end
end


function KeyPressFcn(fh, keyData)
%KEYPRESSFCN Keyboard shortcut (quick-keys) for GUI.
%   
%   See also MAIN, MAIN>OPENINGFCN.
%==========================================================================

% Get figure handles and fluoro data.
[~, saveData, fhHandles]	= getFluoroData(fh);

switch keyData.Key
    case 'escape'
        close(fh);
        return
        
    case 'uparrow'
        % Decrement(-1) in file list value.
        obj	= findobj(fhHandles.Load_Foreground, 'Tag', 'File List');
        if obj.get('Value') ~= 1
            obj.set('Value', obj.get('Value') - 1);
            callBack  = obj.get('Callback');
        else
            return
        end
        
    case 'leftarrow'
        % Decrement(-1) in file list value, then plot the file.
        obj	= findobj(fhHandles.Load_Foreground, 'Tag', 'File List');
        if obj.get('Value') ~= 1
            obj.set('Value', obj.get('Value') - 1);
            callBack  = obj.get('Callback');
            callBack{1}(obj, keyData, fh);
            kData   = struct('Character', 'space', 'Key', 'space');
            KeyPressFcn(fh, kData);
            [data, saveData, ~]	= getFluoroData(fh);
            saveData.set('UserData', data);
        end
        return
        
    case 'downarrow'
        % Decrement(-1) in file list value.
        obj	= findobj(fhHandles.Load_Foreground, 'Tag', 'File List');
        if obj.get('Value') ~= size(obj.get('String'), 1)
            obj.set('Value', obj.get('Value') + 1);
            callBack  = obj.get('Callback');
        else
            return
        end
        
    case 'rightarrow'
        % Decrement(-1) in file list value, then plot the file.
        obj	= findobj(fhHandles.Load_Foreground, 'Tag', 'File List');
        if obj.get('Value') ~= size(obj.get('String'), 1)
            obj.set('Value', obj.get('Value') + 1);
            callBack  = obj.get('Callback');
            callBack{1}(obj, keyData, fh);
            kData   = struct('Character', 'space', 'Key', 'space');
            KeyPressFcn(fh, kData);
            [data, saveData, ~]	= getFluoroData(fh);
            saveData.set('UserData', data);
        end
        return
                
    case {'z', 'x', 'p', 'd', 'b'} % MATLAB-custon-toolbar pushtool buttons.
        % Get previous uimode, if any.
        hManager    = uigetmodemanager(fh);
        prevuimode  = hManager.CurrentMode;
        
        % Set new uimode.
        switch keyData.Key
            case 'z' % "Zoom in".
                newuimode	= zoom(fh);
                if strcmp(newuimode.get('Direction'), 'out')
                    newuimode.set('Enable', 'off')
                end
                zoom('direction', 'in');
                newName	= 'Zoom In';
                
            case 'x' % "Zoom out".
                newuimode	= zoom(fh);
                if strcmp(newuimode.get('Direction'), 'in')
                    newuimode.set('Enable', 'off')
                end
                zoom('direction', 'out');
                newName	= 'Zoom Out';
                
            case 'p' % "Pan".
                newuimode	= pan(fh);
                newName	= 'Pan';
                
            case 'd' % "Data Cursor".
                newuimode	= datacursormode(fh);
                newName	= 'Data Cursor';
                
            case 'b' % "Brush/Select Data".
                newuimode	= brush(fh);
                newName	= 'Brush Data';
        end
        
        if ~isempty(prevuimode)
            prevName    = prevuimode.Name;
            if ~contains(prevName, newName) && strcmp(newuimode.get('Enable'), 'off')
                newuimode.set('Enable', 'off');
                printToLog(fh, [prevName(find(prevName == '.', 1, 'last')+1:end), ': Off'], 'Note');
            end
        end
        
        % Turn object on/off, notify user.;
        if strcmp(newuimode.get('Enable'), 'off')
            newuimode.set('Enable', 'on');
            printToLog(fh, [newName, ': On'], 'Note');
            
            % Prevent MATLAB from disabling listeners during uimodes like "zoom in".
            [hManager.WindowListenerHandles.Enabled]	= deal(false);
            fh.set('WindowKeyPressFcn', [], 'KeyPressFcn', @KeyPressFcn);
            
        else
            newuimode.set('Enable', 'Off');
            printToLog(fh, [newName, ': Off'], 'Note');
        end
        return
        
    case 'l'
        % Execute load directory callback.
        obj   = findobj( fhHandles.Load_Foreground, 'Tag', 'Load Directory' );
        callBack  = obj.get( 'Callback' );
        
    case {'space', 'return'} 
        % Execute plot file callback.
        obj   = findobj( fhHandles.Load_Foreground, 'Tag', 'Plot File' );
        callBack  = obj.get( 'Callback' );
        
    case 's'
        % Execute save data callback for toolbar key.
        obj	= saveData;
        callBack	= saveData.get( 'ClickedCallback' );
        
    case 'u'
        % Execute login user callback for toolbar key.
        obj   = findobj( fhHandles.FigureToolBar, 'Tag', 'User Login' );
        callBack = obj.get( 'ClickedCallback') ;
        
    case 'c' % as in "capture".
        % Execute save image callback for toolbar key.
        obj   = findobj( fhHandles.FigureToolBar, 'Tag', 'Save Image' );
        callBack = obj.get( 'ClickedCallback' );
        
    case 'f' % as in (project) "file".
        % Execute save image callback for toolbar key.
        obj   = findobj( fhHandles.FigureToolBar, 'Tag', 'Project' );
        callBack = obj.get( 'ClickedCallback' );
        
    otherwise
        % Do nothing.
        return
end

% Perform appropriate callback.
callBack{ 1 }( obj, keyData, fh );
end

