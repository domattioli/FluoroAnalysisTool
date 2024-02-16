function fh = buildToolbar( fh )
%BUILDTOOLBAR Import GUI toolbar and its contents.
%	fh = BUILDTOOLBAR( fh ) returns an updated figure handle fh containing
%   a toolbar for misc. quick actions.
%
%  See also MAIN>OPENINGFCN, BUILDTOOLBAR>PROJECT_CALLBACK,
%  BUILDTOOLBAR>SAVEIMAGE_CALLBACK, BUILDTOOLBAR>SAVEDATA_CALLBACK,
%  BUILDTOOLBAR>LOGINUSER_CALLBACK, BUILDTOOLBAR>NNMODELS_CALLBACK.
%==========================================================================

% Modify MATLAB's Standard Toolbar - hide unnecessary buttons.
removeToolButtons	= vertcat( findall( fh, 'ToolTipString', 'New Figure' ),...
    findall( fh, 'TooltipString', 'Open File' ),...
    findall( fh, 'TooltipString', 'Save Figure' ),...
    findall( fh, 'TooltipString', 'Print Figure' ),...
    findall( fh, 'TooltipString', 'Edit Plot' ),...
    findall( fh, 'TooltipString', 'Rotate 3D' ),...
    findall( fh, 'TooltipString', 'Link Plot' ),...
    findall( fh, 'TooltipString', 'Insert Colorbar' ),...
    findall( fh, 'TooltipString', 'Insert Legend' ),...
    findall( fh, 'TooltipString', 'Hide Plot Tools' ),...
    findall( fh, 'TooltipString', 'Show Plot Tools' ),...
    findall( fh, 'TooltipString', 'Show Plot Tools and Dock Figure' ) );
removeToolButtons.set( 'Visible', 'Off' );
tb  = findall( fh, 'Type', 'uitoolbar' );

% Build GUI Parts.
tbUICNames	= { 'Project', 'Save Image', 'Save Data', 'User Login', 'NN Models' };
[img, map]	= imread( 'project_logo.png' );  	% Project button.
img	= imresize( img, [16 16] );
[~]	= uipushtool( 'Tag', tbUICNames{ 1 },...
    'TooltipString', tbUICNames{ 1 },...
    'Parent', tb,...
    'Separator', 'on',...
    'CData', ind2rgb( img, map ),...
    'ClickedCallback', { @Project_Callback, fh} );
[img, map]	= imread( 'camera_logo.png' );     	% Use save image button.
img	= imresize( img, [16 16] );
[~]	= uipushtool( 'Tag', tbUICNames{ 2 },...
    'TooltipString', tbUICNames{ 2 },...
    'Parent', tb,...
    'Separator', 'off',...
    'CData', ind2rgb( img, map ),...
    'ClickedCallback', { @SaveImage_Callback, fh } );
saveFigure = findall( fh, 'ToolTipString', 'Save Figure' );
img	= saveFigure.get( 'CData' );                 % Save Data button.
[~]	= uipushtool( 'Tag', tbUICNames{ 3 },...
    'TooltipString', tbUICNames{ 3 },...
    'Parent', tb,...
    'Separator', 'off',...
    'CData', img,...
    'UserData', Fluoro(),...              % Initialize output.
    'ClickedCallback', { @SaveData_Callback, fh} );
[img, map]	= imread( 'login_logo.png' );       % Login button.
img	= imresize( img, [16 16] );
[~]	= uipushtool('Tag', tbUICNames{ 4 },...
    'TooltipString', tbUICNames{ 4 },...
    'Parent', tb,...
    'Separator', 'on',...
    'CData', ind2rgb(img, map),...
    'ClickedCallback', { @LoginUser_Callback, fh} );
[img, ~]	= imread( 'models_logo.png' );     	% Use NN models toggle.
img	= imresize(img, [16 16] );
[~]	= uitoggletool('Tag', tbUICNames{ 5 },...
    'TooltipString', tbUICNames{ 5 },...
    'Parent', tb,...
    'Separator', 'off',...
    'CData', img,...
    'State', 'off',...
    'ClickedCallback', { @nnModels_Callback, fh} );

% Update fh UserData.
fh.set( 'UserData', fh.get('UserData' ).createNew(tb) );
end


function Project_Callback( hObject, ~, fh  )
%PROJECT_CALLBACK Handle project information.
%
%  See also BUILDTOOLBAR.
%==========================================================================

% Get figure handles, save result in data.
[data, ~, ~]	= getFluoroData( fh  );

% Prompt user:
projectBaseDir  = fullfile( sourceCodeDirectory( ), 'Projects' );
answer  = questdlg( 'What would you like to do?', 'Project',...
    'New Project', 'Open Project', 'Cancel', 'New Project' );

% Check if a directory has already been selected.;
chosenDir	= data.get( 'CaseID' );
if isempty( chosenDir  )
    chosenDirFolderName	= [];
else
    [~, chosenDirFolderName]	= fileparts( chosenDir  );
end

% Parse answer for user's decision on selecting a project.
if strcmp( answer, 'Cancel' ) || isempty( answer  )
    projectDir  = hObject.get( 'UserData' );
else
    if strcmp( answer, 'New Project' )
        if isempty( chosenDir  )
            newDirName = 'No';
        else  % Directory has been selected. Copy it's name?
            newDirName = questdlg(...
                'Create a project named after the selected directory?',...
                'Project Name', 'Yes', 'No', 'Yes' );
        end
    else % Open Project
        newDirName	= 'No';
    end
    
    % Make a new folder name automatically, if desired.
    if strcmp( newDirName, 'Yes' )
        mkdir( projectBaseDir, chosenDirFolderName  )
        projectDir	= fullfile( projectBaseDir, chosenDirFolderName  );
    else
        projectDir  = uigetdir( projectBaseDir, 'Select a Project Folder' );
    end
end

% Save to userdata.
if ~isempty( projectDir  )
    fh.get( 'UserData' ).set( 'Project', projectDir  );
    data.set( 'Project', projectDir );
    printToLog( fh, ['Now working in project folder: ', projectDir], 'Success' )
end
end


function SaveImage_Callback( hObject, ~, fh  )
%SAVEIMAGE_CALLBACK Screenshot image in main axis.
%
%  See also BUILDTOOLBAR.
%==========================================================================

% Get figure handles, save result in data; Identify path for saved file.
[data, ~, ~]	= getFluoroData( fh  );
projectFolderName  = data.get( 'Project' );
if isempty( projectFolderName  )
    projectFolderName   = fullfile( sourceCodeDirectory(), 'Projects', 'New_Project' );
end
fileName   = data.get( 'FileName' );
if isempty( fileName  )
    printToLog( fh, 'No image data to capture; please load a directory and choose a file', 'Error' );
    return
else
    % Assume dicom already has a screen-capture of the same name.
    N = 0;
    fileName	= fullfile( projectFolderName, strcat( fileName, '_capture(', num2str( N ), ').tif' ) );
    while exist( fileName, 'file' ) == 2
        N  = N + 1;
        fileName( end-5  )	= num2str( N  );
    end
end

% If path doesn't exist, adjust and recursively call self.
if ~exist( projectFolderName, 'dir' )
    siblings   = hObject.get( 'Parent' ).get( 'Children' );
    project	= findobj( siblings, 'Tag', 'Project' );
    printToLog( fh, 'Project folder no longer exists', 'Note', '!' );
    Project_Callback( project, [], fh  );   % Select different project folder.
    SaveImage_Callback( hObject, [], fh  );  % Try again.
    return
end

% Write image to project folder (or current folder).
[img, map]	= frame2im( getframe( fh.get( 'CurrentAxes' ) ) );
if isempty( map  )
    imwrite( img, fileName, 'tif', 'compression', 'none' );
else
    imwrite( img, map, fileName, 'tif', 'compression', 'none' );
end
printToLog( fh, 'Image saved', 'Success', '!' )
end


function SaveData_Callback( hObject, ~, fh  )
%SAVEDATA_CALLBACK Placeholder callback function for saving data.
%  As procedures are selected, the callback to the 'Save Data' button will
%  change appropriately.
%
%  See also BUILDTOOLBAR.
%==========================================================================

% Save only if data is available.
data   = hObject.get( 'UserData' );
data.set( 'Project', fh.get( 'UserData' ).get( 'Project' ) );
if isempty( data.get( 'FileName' ) )
    printToLog( fh, 'No data to save', 'Progress' );
    printToLog( fh, 'Try selecting and performing a procedure', 'Note' );
else
    [~, success]	= data.save();
    if success
        printToLog( fh, ['Fluoro data successfully saved to ''',...
            data.get( 'Project' ), ''''], 'Success' );
    else
        printToLog( fh, 'Save failed', 'Error' );
        warndlg( {'Save failed; potential causes:',...
            '1. Neither a Project nor Load Directory specified',...
            '2. TBD...'}, 'Save Failure', 'modal' )
    end
end
end


function LoginUser_Callback( hObject, ~, fh  )
%LOGINUSER_CALLBACK Prompt, assign user login information.
%
%  See also BUILDTOOLBAR.
%==========================================================================

% Prompt user.
% options.Resize = 'on';
% options.WindowStyle	= 'modal';
% answer	= inputdlg( {'Last Name', 'First Initial'},...
%     'Login', [1 32; 1 15], {'Last Name', 'F'}, options  );
dlgPos = [fh.Position( 1 ) + fh.Position( 3 ) * 0.4,...
    fh.Position( 2 ) + fh.Position( 4 ) * 0.21,...
    0.15, 0.15 ]; % Hardcoded to place roughly at center of figure location.
userLoginAnswer	= loginDlg( 'Personal Login Info:', 'User Login', dlgPos );

% Prompt user until correct input given.
if isempty( userLoginAnswer )
    printToLog(fh, 'No unique user login given', 'Note' );
    
else
    % Process input first initial - make sure it's only one, capital letter.
    userLoginAnswer{2}	= upper( userLoginAnswer{2}(  1  ) );
    userName   = [userLoginAnswer{1}, ', ', userLoginAnswer{end}];
    hObject.set( 'TooltipString', [hObject.get('Tag' ), ': ', userName] );
    printToLog( fh, ['Login registered! Username: ' userName], 'Success' );
end

% Get figure handles and fluoro data.
[data, saveData, ~]	= getFluoroData( fh  );

% Assign to data.
data.set( 'User', userLoginAnswer  );
saveData.set( 'UserData', data  );
end


function nnModels_Callback(hObject, ~, fh)
%NNMODELS_CALLBACK Determine if models are used.
%
%  See also BUILDTOOLBAR.
%==========================================================================

% Get figure handles and fluoro data.
[data, saveData, ~]	= getFluoroData(fh);

% Initialize output, in case of questdlg being canceled by user.
tcp	= [];

% Prompt user:
printStr   = {'Model predictions will', 'be provided'};
switch hObject.get('State' )
    case 'off'
        % Inform user that if they continue then there will not be
        % NN-offered predictions.
        answer	= questdlg('Disable NN Model Predictions?',...
            'Use Models', 'Yes', 'No', 'Yes' );
        
        % Disable socket listener.
        switch answer
            case 'Yes'
                tcp = data.get('Models' );
                [tcp, success]	= destroySocketListener(tcp);
                hObject.set('TooltipString', [hObject.get('Tag' ), ': Off'] );
                if success
                    printToLog(fh, [printStr{1},' not ', printStr{2}], 'Progress' );
                    
                else
                    printToLog(fh, ['Could not turn off neural network;',...
                        ' Ensure models are not corrupted and packages are',...
                        ' installed properly.'], 'Error' )
                end
                
            case 'No'
                % Do nothing.
                
            otherwise % Canceled - revert to previous state.
                hObject.set('State', 'on' );
        end
        
    case 'on'
        % Ask if they want to turn it on (use NN models).
        answer	= questdlg('Enable NN Model Predictions?', ...
            'Prediction Tool', 'Yes', 'No', 'Yes' );
        
        % Enable socket listener.
        switch answer
            case 'Yes'
                [tcp, success]	= initializeSocketListener( );
                hObject.set('TooltipString', [hObject.get('Tag' ), ': On'] );
                if success
                    printToLog(fh, [printStr{1}, ' ', printStr{2}, ', if possible'], 'Progress' );
                    
                else
                    printToLog(fh, ['Could not turn on neural network;',...
                        ' Ensure models are not corrupted and packages are',...
                        ' installed properly.'], 'Error' )
                end
                
            case 'No'
                % Do nothing.
                
            otherwise % Canceled - revert to previous state.
                hObject.set('State', 'off' );
        end
end

% Assign to data.
data.set('User', answer, 'Models', tcp);
saveData.set('UserData', data);
end

