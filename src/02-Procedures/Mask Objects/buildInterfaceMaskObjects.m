%% Build Display for Pediatric Elbow Procedure.
function fh = buildInterfaceMaskObjects( fh, hObject )
%BUILDINTERFACEMASKOBJECTS Builds displays for masking and saving objects.
%   fh = BUILDINTERFACEPSHF(fh, hObject) returns updated fh w PSHF buttons.
%
%   See also 
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Display procedure buttons.
UICNames	= { 'Current Masks', 'Define', 'Edit', 'Delete', 'Commit', 'Object Types', 'Toggle Masks' };
if length( hObject ) ~= 1
    hObject( 2:end )  = [];
end
fontSize    = .28;
[~] = uicontrol( 'Style', 'listbox',...
    'Tag', UICNames{ 1 },...
    'String', { '' },...
    'Parent', hObject,...
    'Value', 1,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.07,...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0],...
    'Position', [0.05 0.025 0.275 0.975],...
    'Callback', { @CurrentMasks_Callback, fh } );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', UICNames{ 2 }, 'String', UICNames{ 2 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [0.35 0.775 0.175 0.225],...
    'Callback', { @Define_Callback, fh } );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', UICNames{ 3 }, 'String', UICNames{ 3 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [0.35 0.525 0.175 0.225],...
    'Callback', { @Edit_Callback, fh } );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', UICNames{ 4 }, 'String', UICNames{ 4 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [0.35 .275 .175 .225],...
    'Callback', { @Delete_Callback, fh } );
[~]	= uicontrol( 'Style', 'pushbutton',...
    'Tag', UICNames{ 5 }, 'String', UICNames{ 5 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', [0.75 0.75 0.75], 'ForegroundColor', [0 0 0],...
    'Position', [0.35 .025 .175 .225],...
    'Callback', { @Commit_Callback, fh } );
[~]	= uicontrol( 'Style', 'listbox',...
    'Tag', UICNames{ 6 },...
    'String', { 'Create new object type', 'Femur', 'Fracture', 'Humerus', 'Wire' },...
    'Parent', hObject,...
    'Value', 2,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', .14,...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0],...
    'Position', [0.55 0.275 0.405 0.475],...
    'Callback', { @ObjectTypes_Callback, fh } );
toggleMaskRadios	= uibuttongroup(... %----------Radio Buttons-----------
    'Tag', UICNames{ 7 }, 'Title', [],...
    'Parent', hObject,...
    'BackgroundColor', [1 1 .8],...
    'Position', [0.55 .025 .405 .225],...
    'Visible', 'On' );
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', horzcat( UICNames{ 7 }, ' On' ), 'String', 'Show Masks',...
    'Parent', toggleMaskRadios,...
    'Value', true,...
    'Visible', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.25,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', [0 0 0],...
    'Position', [0.05 .00 0.45 1.00],...
    'Callback', { @ToggleMasks_Callback, fh } );
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', horzcat( UICNames{ 7 }, ' Off' ), 'String', 'Hide Masks',...
    'Parent', toggleMaskRadios,...
    'Value', false,...
    'Visible', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.25,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', [0 0 0],...
    'Position', [0.50 0.00 .45 1.00],...
    'Callback', { @ToggleMasks_Callback, fh } );
end


%% Helper.
function concludeCallback( fh, data, saveData, procedure, initialE )
%CONCLUDECALLBACK Ties up odds and ends for PSHF callback function.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Reset axis limits, include updated legend, reset button enability.
data.resetAxisLimits();
% [~]	= toggleUIControls(fh, initialE);

% Create updated UI list of Current Objects.
existingMaskObjects	= procedure.get( 'Children' );
existingMaskObjects( ~isvalid( existingMaskObjects ) )	= [];
newVal  = size( existingMaskObjects.get( 'Tag' ), 1 );
currentMasksObj     = findobj( 'Tag', 'Current Masks' );
currentMasksObj.set( 'String', existingMaskObjects.get( 'Tag' ), 'Value', newVal );

% Plot objects if requested.
ToggleMasks_Callback( findobj( 'Tag', 'Toggle Masks On' ), [], fh );
if nargin == 5
    %     [~]	= toggleUIControls(fh, initialE);
end
data.set( 'Procedure', procedure );
saveData.set( 'UserData', data );
fh.set( 'CurrentObject', fh );
end


function legendMO( fh, data, visible )
%LEGENDMO Displays legend for the fracture plane & varying number of wires.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

maskObjects	= data.get( 'Procedure' ).get( 'Children' );
ivalid  = isvalid( maskObjects );
if isempty( maskObjects ) || strcmpi( 'Off', visible ) || all( ~ivalid )
    legend( 'Off' )
    return
end
maskObjects     = maskObjects( ivalid );
ax = gca;
axChildren = ax.get( 'Children' );
iaxChildren = ismember( axChildren.get( 'Tag' ), maskObjects.get( 'Tag' ) );
imaskObjects = ismember( maskObjects.get( 'Tag' ), axChildren.get( 'Tag' ) );
legend( axChildren( iaxChildren ), [maskObjects( imaskObjects ).get( 'Tag' )], 'Location', 'NorthEast', 'Visible', visible );
end



%% Callback Functions.
function ObjectTypes_Callback( hObject, eventData, fh )
%WIREWIDTH_CALLBACK Stores wire-width designation to output data.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

if hObject.get( 'Value' ) == 1
    % Rewrite list of options.
    continueLoop	= true;
    while continueLoop
        selection	= inputdlg( 'Please enter a title for a new object.', 'Manual Entry' );
        if isempty( selection )
            return
        else
            newVal  = numel( hObject.get( 'String' ) ) + 1;
            hObject.set( 'String', vertcat( hObject.get( 'String' ), selection ), 'Value', newVal );
            continueLoop	= false;
        end
    end
end
end


function Define_Callback( hObject, ~, fh )
%DRAW_CALLBACK 
%
%   See also BUILDINTERFACEMASKOBJECTS.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, fhHandles]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    printToLog( fh, ['Cannot perform ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end
procedure   = data.get( 'Procedure' );

% Prep new object.
siblingTags = hObject.Parent.Children.get( 'Tag' );
objectTypesObj	= hObject.Parent.Children( contains( siblingTags, 'Object Types' ) );
if objectTypesObj.get( 'Value' ) == 1
    printToLog( fh, 'You must select an object type', 'Note' );
    concludeCallback( fh, data, saveData, procedure );
    return
else
    objectTypesStr  = objectTypesObj.get( 'String' );
    selectedObjStr	= objectTypesStr{ objectTypesObj.get( 'Value' ) };
end
currentMasksObj	= hObject.Parent.Children( contains( siblingTags, 'Current Masks' ) );
currentMasksStr = currentMasksObj.get( 'String' );
iSelectedObjMasks	= contains( currentMasksStr, selectedObjStr );
if any( iSelectedObjMasks )
    selectedObjStr = horzcat( selectedObjStr, '_', num2str( sum( iSelectedObjMasks ) + 1 ) );
else
    selectedObjStr = horzcat( selectedObjStr, '_1' );
end

% Draw.
printToLog( fh, ['Drawing ''', selectedObjStr, ''''], 'Progress' );
printToLog( fh, ['Left-click along the outline of the object in the image;',...
    ' right-click to enclose; double-left-click to end'], 'Note' );
acceptPred	= 'No';
plotStyle   = '.-';
while strcmpi( 'No', acceptPred )
    switch objectTypesStr{ objectTypesObj.get( 'Value' ) }
        case 'Wire'
            wireObj	= Wire();
            wireObj.defineWire( data, false );
            wireObj.plot( 'Left', 'Boundary', true );
            delete( wireObj.Display( 2 ) ); % Necessary.
            [BW, p] = deal( wireObj.get( 'Mask' ), wireObj.Display( 1 ) );
        otherwise
            [BW, p] = maskObject( gca, 75, 'showPlot', true, 'style', plotStyle, 'Tag', selectedObjStr );
    end
    acceptPred  = questdlg( 'Is this mask outline acceptable?', 'Judge outline', 'Yes', 'No', 'Cancel', 'Yes' );
    if strcmpi( 'Cancel', acceptPred ) || isempty( acceptPred )
        printToLog( fh, ['Canceling drawing ''', selectedObjStr, ''''], 'Error' );
        return
    end
end
b = transpose( vertcat( p.get( 'XData' ), p.get( 'YData' ) ) );
procedure.addChild( FluoroObject( data, 'Tag', selectedObjStr, 'Boundary', b, 'Mask', BW, 'Display', p ) );
concludeCallback( fh, data, saveData, procedure, initialE );
printToLog( fh, ['Drawing ''', selectedObjStr, ''' complete'], 'Success' );
end


function Edit_Callback( hObject, ~, fh )

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, fhHandles]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    printToLog( fh, ['Cannot perform ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end

% Determine the number of draggable points to give the user.
currentMasks	= findobj( 'Tag', 'Current Masks' );
procedure   = data.get( 'Procedure' );
childs  = procedure.Children( isvalid( procedure.get( 'Children' ) ) );
focusObj	= findobj( childs, 'Tag', currentMasks.String{ currentMasks.Value } );
[~, R, ~]	= curvature( focusObj.Boundary ); % Need a function that admeshes this to have more points near curves.
N   = numel( R ) + ceil( sum( isoutlier( R ) | isnan( R) )  );

% Plot object in focus as an impoly for the user's adjustment.
bxy = focusObj.get( 'Boundary' );
H   = impoly( data.get( 'Parent' ), interparc( N, bxy( 1:end-1, 1 ), bxy( 1:end-1, 2 ) ) );
b	= H.wait();
b   = vertcat( b, b( 1, : ) );
BW  = H.createMask();
H.delete();
plt = line( b( : ,1 ), b( :, 2 ), 'Color', focusObj.Display.Color,...
    'LineStyle', focusObj.Display.LineStyle, 'LineWidth', focusObj.Display.LineWidth,...
    'Marker', focusObj.Display.Marker, 'MarkerSize', focusObj.Display.MarkerSize,...
    'MarkerFaceColor', focusObj.Display.MarkerFaceColor, 'Visible', 'Off',...
    'Tag', focusObj.Display.get( 'Tag' ) );
focusObj.delete();
procedure.replaceChild( procedure.Children == focusObj, FluoroObject( data, 'Tag', plt.get( 'Tag' ),...
    'Boundary', b, 'Mask', BW, 'Display', plt ) );
concludeCallback( fh, data, saveData, procedure, initialE );
end


function Delete_Callback( hObject, ~, fh )

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, fhHandles]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    printToLog( fh, ['Cannot perform ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end
childs  = data.get( 'Procedure' ).get( 'Children' );
ivalid	= isvalid( childs );
if isempty( childs ) || all( ~ivalid )
    return
end
data.Procedure.Children( hObject.get( 'Value' ) ).delete();
concludeCallback( fh, data, saveData, data.get( 'Procedure' ), initialE );
end


function Commit_Callback( hObject, ~, fh )

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, ~, ~]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh ); % initialE might cause problems.
if ~success
    printToLog( fh, ['Cannot perform ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end

% Save all valid masks individually.
printToLog( fh, 'Writing masks to:', 'Progress' );
printToLog( fh, data.get( 'Project' ), 'Note' );
childs  = data.get( 'Procedure' ).get( 'Children' );
saveChilds  = childs( isvalid( childs ) );
for idx = 1:length( saveChilds )
    imwrite( saveChilds( idx ).get( 'Mask' ), strcat( fullfile(...
        data.get( 'Project' ), saveChilds( idx ).get( 'Tag' ) ), '.tif' ) );
end
printToLog( fh, 'Successfully saved binary image data', 'Success' );
end


function CurrentMasks_Callback( hObject, ~, fh )
end


function ToggleMasks_Callback( hObject, ~, fh )

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, ~, ~]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh ); % initialE might cause problems.
if ~success
    printToLog( fh, ['Cannot perform ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end
procedure   = data.get( 'Procedure' );
childs	= procedure.get( 'Children' );
childs( ~isvalid( childs ) )	= [];
    
if contains( 'Show Masks', hObject.get( 'String' ) ) && hObject.get( 'Value' ) == true
    visible	= 'On';
else
    visible	= 'Off';
end
if numel( childs ) > 0 
    for idx = 1:numel( childs.get( 'Display' ) )
        childs( idx ).Display.set( 'Visible', visible );
    end
end
legendMO( fh, data, visible );
end





