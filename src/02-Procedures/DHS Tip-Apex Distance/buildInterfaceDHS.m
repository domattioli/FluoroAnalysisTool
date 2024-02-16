%% Build Display for Pediatric Elbow Procedure.
function fh	= buildInterfaceDHS(fh, hObject)
%BUILDINTERFACEDHS Builds display for 'DHS Wire Navigation' Procedure.
%   fh	= BUILDINTERFACEDHS(fh, hObject) returns updated fh w DHS buttons.
%
%   See also DISPLAYDHS, BUILDPROCEDUREFOREGROUNDPANEL,
%   BUILDINTERFACEDHS>LEFTRIGHT_CALLBACK,
%   BUILDINTERFACEDHS>WIREWIDTH_CALLBACK,
%   BUILDINTERFACEDHS>FEMORALHEAD_CALLBACK,
%   BUILDINTERFACEDHS>FEMORALHEAD_CALLBACK,
%   BUILDINTERFACEDHS>WIRESLOPE_CALLBACK.
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Build GUI Parts.
UICNames	= {'Left Or Right',...
    'Initial Condition',...
    'Left',...
    'Right',...
    'Femoral Head',...
    'Femoral Neck',...
    'Wire Slope',...
    'Wire Width'};

% Display initial condition decision panel.
if length(hObject) ~=1
    hObject(2:end)  = [];
end
fontSize    = .28;
leftRightButtons  = uibuttongroup('Title', [],...
    'Tag', UICNames{1},...
    'Parent', hObject,...
    'BackgroundColor', bgColor,...
    'Position', [.05 .775 .45 .225]);
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', UICNames{2}, 'String', UICNames{2},...
    'Parent', leftRightButtons,...
    'Value', true,...
    'Visible', 'off',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', bgColor, 'ForegroundColor', [0 0 0],...
    'Position', [.00 .00 .00 .00],...
    'Callback', {});
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', UICNames{3}, 'String', UICNames{3},...
    'Parent', leftRightButtons,...
    'Value', false,...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', bgColor, 'ForegroundColor', [0 0 0],...
    'Position', [.15 .00 .35 1.00],...
    'Callback', {@LeftRight_Callback, fh});
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', UICNames{4}, 'String', UICNames{4},...
    'Parent', leftRightButtons,...
    'Value', false,...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', bgColor, 'ForegroundColor', [0 0 0],...
    'Position', [.55 .00 .35 1.00],...
    'Callback', {@LeftRight_Callback, fh});

% Display Procedure buttons.
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{5}, 'String', UICNames{5},...
    'Parent', hObject,...
    'enable', 'inactive',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .525 .45 .225],...
    'Callback', {@FemoralHead_Callback, fh} );
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{6}, 'String', UICNames{6},...
    'Parent', hObject,...
    'enable', 'inactive',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .275 .45 .225],...
    'Callback', {@FemoralNeck_Callback, fh} );
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{7}, 'String', UICNames{7},...
    'Parent', hObject,...
    'enable', 'inactive',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .025 .45 .225],...
    'Callback', {@WireSlope_Callback, fh} );
[~]	= uicontrol('Style', 'listbox',...
    'Tag', UICNames{8}, 'String', {'Select a Wire Width [mm]', '1.5', '2.5', '3.2', 'Other'},...
    'Parent', hObject,...
    'Value', 3,...
    'enable', 'inactive',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', .15,...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0],...
    'Position', [.55 .40 .405 .345],...
    'Callback', {@WireWidth_Callback, fh} );
end


%% Helper.
function concludeCallback( fh, data, saveData, procedure, initialE )
%CONCLUDECALLBACK Ties up odds and ends for DHS callback function.
%
%   See also BUILDINTERFACEDHS.
%==========================================================================

% Reset axis limits, button enability.
data.resetAxisLimits();
data.set( 'Procedure', procedure );
% [~]	= toggleUIControls(fh, initialE);               % Unfreeze buttons

% Compute, display TAD, if possible; auto-save.
printDHS( fh, procedure );
saveData.set( 'UserData', data );
saveData.ClickedCallback{ 1 }( saveData, [], fh  );
if nargin == 5
%     [~]	= toggleUIControls(fh, initialE);           % Unfreeze buttons
end
fh.set( 'CurrentObject', fh );
end


function printDHS( fh, procedure )
%PRINTDHS Prints state of DHS to the Log.
%
%   See also BUILDINTERFACEDHS, CONCLUDECALLBACK.
%==========================================================================

[TAD, Theta]	= procedure.evaluate();
if isnan( TAD.px )
    return
end
if isstruct( TAD )
    data = round( vertcat( TAD.px, TAD.mm, TAD.in ), 1, 'decimals' );
    if all( ~isnan( data ) )
        printToLog( fh, ['Computed TAD: ~', sprintf( '%g', data( 2 ) ),...
            ' mm (~', sprintf( '%g', data( 1 ) ),' px, ~',...
            sprintf( '%g', data( 3 ) ), ' in.)'], 'Note' );
    end
end
if ~isnan( Theta )
    printToLog( fh, ['Computed Theta: ~', num2str( Theta ),' deg'], 'Note' );
end
end


%% Callback Functions.
function LeftRight_Callback( hObject, ~, fh )
%LEFTRIGHT_CALLBACK Stores L/R (of hip) designation to output data.
%
%   See also BUILDINTERFACEDHS, FEMORALNECK_CALLBACK, WIRESLOPE_CALLBACK.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, fhHandles]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
procedure   = data.get( 'Procedure' );
if success
    % Get fieldnames of results corresponding to chosen procedure.
    procedureStr	= procedure.get( 'Name' );
    procedureObj	= findobj( fhHandles.Procedure_Foreground, 'Tag', procedureStr );
    
    % If this is the first time calling this function (in procedure):
    sideStr	= hObject.get( 'String' );
    printToLog( fh, [sideStr, '-side chosen'], 'Success' );
    if isempty( data.get( 'Side' ) )
        % Enable other procedure buttons, end callback.
        set( findobj( procedureObj, 'Type', 'UIControl' ), 'Enable', 'On' );
        data.set( 'Side', sideStr );
        return
    end
    
    % Flip orientation of Femoral Neck perpendicular bisector, and Wire Slope.
    if ~strcmpi( sideStr, data.get( 'Side' ) )
        flipNote	= [];
        if ~isempty( procedure.get( 'Femur' ).get( 'Head' ).get( 'Boundary' ) )
            procedure.get( 'Femur' ).flipNeckPerpendicularBisector( sideStr );
            neckPlot    = procedure.get( 'Femur' ).plotNeck( sideStr );
            if ~isempty( neckPlot )
                flipNote    = strcat( flipNote, 'Bisector flipped' );
            end
        end
        if ~isempty( procedure.get( 'Wire' ).get( 'Boundary' ) )
            procedure.get( 'Wire' ).flipWire( sideStr );
            if ~isempty( flipNote )
                flipNote	= strcat( flipNote, ' & ' );
            end
            flipNote	= strtrim( strcat( flipNote, ' Wire (projection) flipped' ) );
        end
        if ~isempty( flipNote )
            printToLog( fh, flipNote, 'Note' );
        end
        data.set( 'Side', sideStr );
    end
end
concludeCallback( fh, data, saveData, procedure, initialE );
end


function FemoralHead_Callback( hObject, ~, fh )
%FEMORALHEAD_CALLBACK Predicts femoral head location, prompts user input,
%if necessary.
%
%   See also BUILDINTERFACEDHS, LEFTRIGHT_CALLBACK, FEMORALNECK_CALLBACK.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, ~]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    return
elseif strcmpi( data.defaultSide(), data.get( 'Side' ) )
    printToLog( fh, 'Cannot continue until a Side (Left/Right) is selected', 'Error' );
    return
end
printToLog( fh, ['Method: Define ''', hObject.get('String'), ''''], 'Progress' );
printToLog( fh, 'Circumscribe head with ellipse, double-click ellipse to complete', 'Note' );

% Try to predict the femoral head given the image, show it to the user.
procedure   = data.get( 'Procedure' );
femur    = procedure.get( 'Femur' );
headDisplay	= femur.get( 'Head' ).get( 'Display' );
if ~strcmpi( 'off', headDisplay )
    headDisplay.set( 'Visible', 'Off' );
end
if ~isempty( femur.get( 'Neck' ).get( 'Boundary' ) )
    femur.resetNeck();
end
femur.resetTipApex();
femur.defineHead( data, false );
femur.plotHead();
concludeCallback( fh, data, saveData, procedure, initialE );
printToLog( fh, ['''', hObject.get( 'String' ), ''' completed'], 'Success' );
end


function FemoralNeck_Callback( hObject, ~, fh )
%FEMORALNECK_CALLBACK Predicts femoral neck location, prompts user input,
%if necessary.
%
%   See also BUILDINTERFACEDHS, LEFTRIGHT_CALLBACK, WIRESLOPE_CALLBACK.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, ~]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    return
elseif strcmpi( data.defaultSide(), data.get( 'Side' ) )
    printToLog( fh, 'Cannot continue until a Side (Left/Right) is selected', 'Error' );
    return
else
    % Check whether Femoral Head is already defined.
    printToLog( fh, ['Method: Define ''', hObject.get('String'), ''''], 'Progress' );
    procedure   = data.get( 'Procedure' );
    femur   = procedure.get( 'Femur' );
    if strcmpi( 'off', femur.get( 'Head' ).get( 'Display' ) )
        printToLog( fh, 'Must first define ''Femoral Head''', 'Note' );
        femoralHeadObj  = findobj( hObject.Parent.Children, 'Tag', 'Femoral Head' );
        FemoralHead_Callback( femoralHeadObj, [], fh );
        [data, saveData]	= getFluoroData( fh );
    end
    printToLog( fh, ['Method: Define ''', hObject.get('String'), ''''], 'Progress' );
    printToLog( fh, ['At points along ellipse, place a line perpendicular',...
        ' to the neck''s edges, double-click line to complete'], 'Note' );
end

% Try to predict the femoral neck given the image, show it to the user.
neckDisplay	= femur.get( 'Neck' ).get( 'Display' );
if ~strcmpi( 'off', neckDisplay )
    neckDisplay( 1 ).set( 'Visible', 'Off' );
    neckDisplay( 2 ).set( 'Visible', 'Off' );
end
femur.defineNeck( data, false );
femur.plotNeck( data.get( 'Side' ) );
concludeCallback( fh, data, saveData, procedure, initialE );
printToLog( fh, ['''', hObject.get( 'String' ), ''' completed'], 'Success' );
end


function WireSlope_Callback( hObject, ~, fh )
%WIRESLOPE_CALLBACK Predicts wire location, prompts user input, if
%necessary.
%
%   See also BUILDINTERFACEDHS, LEFTRIGHT_CALLBACK, FEMORALNECK_CALLBACK.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, ~]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    return
elseif strcmpi( data.defaultSide(), data.get( 'Side' ) )
    printToLog( fh, 'Cannot continue until a Side (Left/Right) is selected', 'Error' );
    return
end
printToLog( fh, ['Method: Define ''', hObject.get('String'), ''''], 'Progress' );
printToLog( fh, ['Begin by clicking once at the tip of the wire, then',...
    ' along the median of the wire until you reach your desired end-point.'], 'Note' );
printToLog( fh, ['Click once more at the nearest edge of the wire. Right-click',...
    '  to set your points, and then double-left-click to complete'], 'Note' );

% Try to predict the wire given the image, show it to the user.
procedure   = data.get( 'Procedure' );
wire	= procedure.get( 'Wire' );
if ~strcmpi( 'off', wire.get( 'Display' ) )
    wire.get( 'Display' ).set( 'Visible', 'off' );
end
% [wire, fh]  = wire.defineWire( data, true ); % Comment out because neural net interfacing w python is a mess.
[wire, fh]  = wire.defineWire( data, false );
wire.alignWithDirection( data.get( 'Side' ) );
wire.plot( data.get( 'Side' ) );

% Allow for user to correct the prediction.
acceptPred  = questdlg( 'Is this prediction acceptable?', 'Judge Prediction', 'Yes', 'No', 'Cancel', 'Yes' );
wireDisplay = wire.get( 'Display' );
wireDisplay( 1 ).set( 'Visible', 'off' );
if strcmpi( 'Yes', acceptPred )
    printToLog( fh, 'Prediction accepted', 'Success' );
elseif strcmpi( 'No', acceptPred )
    % Define wire manually.
    wireDisplay( 2 ).set( 'Visible', 'off' );
    printToLog( fh, 'Prediction not accepted', 'Progress' );
    printToLog( fh, ['Method: (Manually) Define ''', hObject.get( 'Tag' ), ''''], 'Progress' );
    printToLog( fh, ['Beginning just shy of the tip, click along the wire''s centerline, ',...
        'add one last point perpendicular to the base at the wire boundary; ',...
        'Double-click to complete'], 'Note' );
    [wire, fh]  = wire.defineWire( data, false );
    if isempty( wire.get( 'Mask' ) )
        printToLog( fh, 'Must select at least 3 points', 'Error' );
        return
    end
    wire.alignWithDirection( data.get( 'Side' ) );
    wire.plotCenter( data.get( 'Side' ) );
else
    wire.resetBoundary();
    wire.resetMask();
    wire.resetDisplay();
    concludeCallback( fh, data, saveData, procedure, initialE );
    printToLog( fh, [ 'Canceling ''', hObject.get( 'Tag' ), ''''], 'Note' );
    return
end
procedure.set( 'Wire', wire );

% Compute, display TAD (if possible) by calling wire width (which has the same closing code.
printToLog( fh, ['''', hObject.get('String'), ''' completed'], 'Success' );
printToLog( fh, ['Estimated wire width: ', num2str( wire.get( 'Widthpx' ) ), ' px'], 'Note' );
WireWidth_Callback( findobj( 'Tag', 'Wire Width' ), [], fh );
end


function WireWidth_Callback( hObject, eventData, fh )
%WIREWIDTH_CALLBACK Stores wire-width designation to output data.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Handle selection.
dialogs     = {'Must select a millimeter width of the wire',...
    'Please enter a millimeter width of the wire.',...
    'Entered value must be numeric.'};
selection = appendToListBox( fh, hObject, dialogs );
if ~isempty( eventData )
    printToLog( fh, ['Selected width of wire is: ', selection, ' [mm]'], 'Note' );
end

% Get figure handles and wire.
[data, saveData, ~]	= getFluoroData( fh );
procedure   = data.get( 'Procedure' );
wire    = procedure.get( 'Wire' );
if isempty( wire )
    % Do nothing... for now.
    return
else
    wire( : ).set( 'WidthMM', str2double( selection ) );
    procedure.set( 'Wire', wire );
end
concludeCallback( fh, data, saveData, procedure );
end

