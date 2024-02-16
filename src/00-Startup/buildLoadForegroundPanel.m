function fh = buildLoadForegroundPanel( fh )
%BUILDLOADFOREGROUNDPANEL Import procedure panel and its contents.
%   fh = BUILDLOADFOREGROUNDPANEL( fh ) returns an updated figure handle
%   fh containing a panel for load buttons.
%   
%   See also MAIN>OPENINGFCN, BUILDLOADFOREGROUNDPANEL>FILELIST_CALLBACK,
%   BUILDLOADFOREGROUNDPANEL>LOADDIRECTORY_CALLBACK,
%   BUILDLOADFOREGROUNDPANEL>PLOTFILE_CALLBACK,
%   BUILDLOADFOREGROUNDPANEL>SELECTEDDIRECTORY_CALLBACK.
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Build GUI Parts.
loadUICNames	= {'Load Foreground',...
    'Load Directory',...
    'Selected Directory',...
    'Plot File',...
    'File List'};
loadForegroundParent	= uipanel( ...
    'Tag', loadUICNames{1}, 'Title', 'Load DICOM',...
    'Parent', fh,...
    'BackgroundColor', bgColor, 'ForegroundColor', 'k', 'ShadowColor', [0 0 0],...
    'Position', [.70 .75 .285 .225],...
    'FontWeight', 'Bold', 'FontSize', 15 );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', loadUICNames{2}, 'String', loadUICNames{2},...
    'Parent', loadForegroundParent,...
    'Units', 'normalized',...
    'BackgroundColor', fgUIowa, 'ForegroundColor', 'k',...
    'FontUnits', 'normalized', 'FontSize', 0.35,...
    'Position', [.05 .7 .45 .225],...
    'Callback', {@LoadDirectory_Callback, fh} );
[~]	= uicontrol( 'Style', 'edit',...
    'Tag', loadUICNames{3}, 'String', loadUICNames{3},...
    'Parent', loadForegroundParent,...
    'max', 0,...
    'Units', 'normalized',...
    'BackgroundColor', [.8275 .8275 .8275], 'ForegroundColor', 'k',...
    'FontUnits', 'normalized', 'FontSize', 0.35,...
    'Position', [.05 .4 .45 .225],...
    'HorizontalAlignment', 'Center',...
    'Enable', 'on',...
    'Callback', {@SelectedDirectory_Callback, fh} );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', loadUICNames{4}, 'String', loadUICNames{4},...
    'Parent', loadForegroundParent,...
    'Units', 'normalized',...
    'BackgroundColor', fgUIowa, 'ForegroundColor', 'k',...
    'FontUnits', 'normalized', 'FontSize', 0.35,...
    'Position', [.05 .1 .45 .225],...
    'Enable', 'on',...
    'UserData', 1,...% Corresponds to 'No File Selected' in fileList.
    'Callback', {@PlotFile_Callback, fh} );
[~]	= uicontrol( 'Style', 'listbox',...
    'Tag', loadUICNames{5}, 'String', loadUICNames{5},...
    'Parent', loadForegroundParent,...
    'Units', 'normalized',...
    'BackgroundColor', 'w', 'ForegroundColor', 'k',...
    'FontUnits', 'normalized', 'FontSize', 0.09,...
    'Position', [.55 .1 .4 .825],...
    'Enable', 'on',...
    'Callback', {@FileList_Callback, fh} );

% Update fh UserData.
fh.set(  'UserData', fh.get(  'UserData' ).createNew(  loadForegroundParent ) );
end


%% GUI Callbacks.
% Display all files in selectedDirectory.
function FileList_Callback( hObject, eventData, fh )
%FILELIST_CALLBACK Callback function for File List hit.
%   FILELIST_CALLBACK( hObject, ~, fh ) instantiates a fluoroProcess object
%   given the selected DICOM file.
%   
%   See also BUILDLOADFOREGROUNDPANEL.
%==========================================================================

% Load file selected in FileList; check if mistake occurred.
iFileName	= hObject.get( 'Value' );
if iFileName == 1
    printToLog( fh, 'No file selected', 'Error' );
    return
end

% Get figure handles and fluoro data, parse file location.
[data, ~, ~]	= getFluoroData( fh );
filesInFolder	= hObject.get( 'String' );
fileName    = filesInFolder{ iFileName, : };
printToLog( fh, ['File selected: ', fileName, '; try plotting the DICOM'], 'Success' );

% Instantiate Fluoro object for analysis.
try                                                 % End-folder selected.
    oldUser = data.get( 'User' );
    oldView	= char( data.get( 'View' ) );
    data	= Fluoro( fileName, 'CaseID', data.get( 'CaseID' ), 'User',...
        oldUser, 'Procedure', data.get( 'Procedure' ), 'View', oldView );
    hObject.set( 'UserData', data );
catch
    printToLog( fh, 'Must select a folder containing .dcm files', 'Error' );
end
fh.set( 'CurrentObject', fh );
end


% Load DICOM Callbacks.
function LoadDirectory_Callback( hObject, eventData, fh )
%LOADDIRECTORY_CALLBACK Callback function for Load Directory hit.
%   LOADDIRECTORY_CALLBACK( hObject, ~, fh ) prompts the user to load a dir.
%   
%   See also BUILDLOADFOREGROUNDPANEL.
%==========================================================================

% Get figure handles and fluoro data.
[data, saveData, fhHandles]	= getFluoroData( fh );
loadForegroundChildren  = fhHandles.Load_Foreground.get( 'Children' );
selectedDirectory   = findobj( loadForegroundChildren, 'Tag', 'Selected Directory' );
hLegend = findobj( gcf, 'Type', 'Legend' );
if ~isempty( hLegend )
    hLegend.set( 'Visible', 'Off' );
end

% Set procedure list as invisible.
procedureForegroundChildren	= fhHandles.Procedure_Foreground.get( 'Children' );
procedureForegroundChildren.set( 'Visible', 'Off' );

% Select directory so multiple files may be acted upon.
if nargin == 3
    % Identify parent folder in which directory is located.
    printToLog( fh, 'Loading directory', 'Progress' );
    if isempty( fh.get( 'CurrentAxes' ).get( 'Children' ) )
        % Havent plotted yet -- 1st time running program **** Should change this someday to a "project" folder or something.
        if isempty( data.get( 'CaseID' ) )
            parentDir = 'D:';
        else
            parentDir   = data.get( 'CaseID' );
        end
    else
        % Nth time; jump back 1 folder.
        parentDir   = fullfile( data.get( 'CaseID' ), '..' );
        cla( fh.get( 'CurrentAxes' ) ); % Replace this with 'display'?
    end
    
    % Load directory.
    uigetdir_prompt     = 'Select a directory of DICOM files.';
    try
        directoryName	= uigetdir( parentDir, uigetdir_prompt );
    catch
        directoryName	= uigetdir( 'C:', uigetdir_prompt );
    end
    
    if length( directoryName ) == 1 && directoryName == 0
        printToLog( fh, 'Directory not chosen; Must select a folder with files', 'Error' );
        return
    end
end

% Update view of selected directory, file list box, project directory.
saveData.set( 'UserData', Fluoro( '', 'CaseID', directoryName ) );
SelectedDirectory_Callback( selectedDirectory, eventData, fh );
procedureChildrenObj	= fhHandles.Procedure_Foreground.get( 'Children' );
procedureListObj	= findobj( procedureChildrenObj, 'Tag', 'Procedure Names' );
procedureListObj.set( 'Value', length( procedureListObj.get( 'String' ) ) );
fh.set( 'CurrentObject', fh );
end


% Plot DICOM in Main Axis.
function PlotFile_Callback( hObject, eventData, fh )
%PLOTFILE_CALLBACK Callback function for Plot File hit.
%   PLOTFILE_CALLBACK( hObject, ~, fh ) has no callback purpose.
%   
%   SELECTEDDIRECTORY_CALLBACK( hObject, ~, fh, loadDirectory ) displays the
%   selected directory to the user.
%   
%   See also BUILDLOADFOREGROUNDPANEL.
%==========================================================================

% Get figure handles and fluoro data; Check if file selected.
[~, saveData, fhHandles]	= getFluoroData( fh );
fileList = findobj( hObject.get( 'Parent' ).get( 'Children' ), 'Tag', 'File List' );
data = fileList.get( 'UserData' );
saveData.set( 'UserData', data );
if isempty( data.get( 'FileName' ) )
    printToLog( fh, 'No file selected; cannot plot', 'Error' );
    return
end
[~, ~, d3] = size( data.Image );
if d3 >= 3
    printToLog( fh, ['Your DICOM image data is ', num2str( d3 ),...
        '-dimensional; this tool does not  support image data that is not two-dimensional.'], 'Note' );
    return
end
data.plot();
printToLog( fh, ['''', data.get( 'FileName' ), ''' plotted'], 'Success' );

% Initialize/reset procedure-relevant data.;
procedureChildrenObj	= fhHandles.Procedure_Foreground.get( 'Children' );
procedureListObj	= findobj( procedureChildrenObj, 'Tag', 'Procedure Names' );
procedureListObj.set( 'Visible', 'on' );
ichosenProcedure	= procedureListObj.get( 'Value' );
chosenProcedureStr	= procedureListObj.String{ ichosenProcedure };
if ismember( ichosenProcedure, 1:length( procedureListObj.get( 'String' ) ) - 1 )
    % Reset Procedure Interactive Parameters and UserData, AP/Lat button status.
    oldProcedureStr = data.get( 'Procedure' ).get( 'Name' );
    data.get( 'Procedure' ).resetProcedure();
    data.resetSide();
    APLatButtonGroupObj	= findobj( procedureChildrenObj, 'Tag', 'AP or Lateral' );
    APorLatButtons	= APLatButtonGroupObj.get( 'Children' );
    iAPorLat	= cell2mat( APorLatButtons.get( 'Value' ) ) == true;
    
    % If it's a new procedure, reset view, otherwise leave it alone.
    if ~strcmp( chosenProcedureStr, oldProcedureStr )
        % Procedure changed - reset view, return.
        data.resetView();
        printToLog( fh, ['Beginning a ''', chosenProcedureStr, ''' analysis'], 'Progress' );
        saveData.set( 'UserData', data );
        return
    else
        % Set View if it has already been designated by user.
        printToLog( fh, ['Beginning a new ''', chosenProcedureStr, ''' analysis'], 'Progress' );
        if find( iAPorLat ) < 3
            funcWrap	= APorLatButtons( 1 ).get(  'Callback' );
            funcWrap{ 1 }( APorLatButtons( iAPorLat ), [], fh );
        end
        saveData.set( 'UserData', data );
    end
else    
    return	% 1st time running program - No procedure selected, yet.
end

% Callback Procedure instantiation.
procedureListObj.Callback{ 1 }( procedureListObj, [], fh );
end


% Display selectedDirectory.
function SelectedDirectory_Callback( hObject, eventData, fh )
%SELECTEDDIRECTORY_CALLBACK Callback function for Selected Directory hit.
%   SELECTEDDIRECTORY_CALLBACK( hObject, ~, fh ) displays the
%   selected directory to the user.
%   
%   See also BUILDLOADFOREGROUNDPANEL.
%==========================================================================

% Get figure handles and fluoro data.
if nargin < 3 % Why is this happening when I manually enter a dir?
    [fh, eventData]	= deal( eventData, hObject );
    hObject	= eventData.Source;
end
[data, saveData, fhHandles]	= getFluoroData( fh );
loadForegroundChildren  = fhHandles.Load_Foreground.get( 'Children' );
loadDirectory   = findobj( loadForegroundChildren, 'Tag', 'Load Directory' );

if eventData.Source == hObject
    % User entered a custom directory into edit field. Validate it.
    directoryName	= hObject.get( 'String' );
    if exist( directoryName, 'dir' ) == 7
        % Directory exists -- set it as loadDirectory's userData.
        loadDirectory.set( 'UserData', directoryName );
    else
        % Go to previously-selected directory instead.
        directoryName   = loadDirectory.get( 'UserData' );
        printToLog( fh, ['Manually-entered directory ''', directoryName, ''' does not exist'], 'Error' );
    end
else
    % Not activated by button click.
    directoryName   = data.get( 'CaseID' );
    if ~ischar( directoryName )
        return
    end
    
end
data    = Fluoro( '', 'CaseID', directoryName );

% Get list of files in chosen directory, convert to dicoms and change
% chosen directory, if necesssary.
fileList    = findobj( loadForegroundChildren, 'Tag', 'File List' );
[listOfFileNames, success]	= buildFileList( fh, directoryName );
try
    [new_directoryName, ~, ~]	= fileparts( listOfFileNames{ 1 } );
catch
    printToLog( fh, 'Make sure that the folder you selected contains DICOM files, not just subfolders', 'Error' );
    return
end
if ~isempty( new_directoryName )
    % Must change the original directory to new one w dicoms by recursion.
    hObject.set( 'String', new_directoryName );
    eventData	= struct( 'Source', hObject, 'EventName', 'Action' );
    SelectedDirectory_Callback( hObject, eventData, fh );
    return
end

% Populate file list.
fileList.set( 'String', listOfFileNames, 'value', 1 );
if success
    printToLog( fh, 'Directory successfully loaded', 'Success' );
    printToLog( fh, 'Select a file to plot', 'Note' );
    
else
    % Depopulate file list.
    printToLog( fh, ['Selected directory is either empty or does not have',...
        ' DICOM files; Select a different folder to analyze and ensure',...
        ' that all file extensions are ''.dcm'''], 'Error' );
end

% Truncate, display selected directory in edit box.
selectedDir	= truncateForTextBox( hObject, directoryName );
hObject.set( 'String', selectedDir, 'HorizontalAlignment', 'center' );

% Reinstate Window Key Press Function.
fh.set( 'CurrentObject', fh );
saveData.set( 'UserData', data );
end

