%% Build Display for Pediatric Elbow Procedure.
function fh = buildInterfacePSHF( fh, hObject )
%BUILDINTERFACEPSHF Builds displays for 'Pediatric Supracondylar Humerus Fracture' Procedure.
%   fh = BUILDINTERFACEPSHF(fh, hObject) returns updated fh w PSHF buttons.
%
%   See also DISPLAYPSHF, BUILDPROCEDUREFOREGROUNDPANEL,
%   BUILDINTERFACEPSHF>ELBOWFRACTURE_CALLBACK,
%   BUILDINTERFACEPSHF>ADDWIRE_CALLBACK,
%   BUILDINTERFACEPSHF>FINDINTERSECTIONS_CALLBACK,
%   BUILDINTERFACEPSHF>WIREWIDTHS_CALLBACK.
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Display procedure buttons.
UICNames	= { 'Fracture Plane', 'Wire 1', 'Wire 2', 'Wire 3', 'Wire Width' };
if length(hObject) ~= 1
    hObject(2:end)  = [];
end
fontSize    = .28;
listboxFontSizes	= 0.15;
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{ 1 }, 'String', UICNames{ 1 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .775 .45 .225],...
    'Callback', { @ElbowFracture_Callback, fh } );
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{ 2 }, 'String', UICNames{ 2 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .525 .45 .225],...
    'Callback', { @Wire_Callback, fh } );
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{ 3 }, 'String', UICNames{ 3 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .275 .45 .225],...
    'Callback', { @Wire_Callback, fh } );
[~]	= uicontrol('Style', 'pushbutton',...
    'Tag', UICNames{ 4 }, 'String', UICNames{ 4 },...
    'Parent', hObject,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', fontSize,...
    'BackgroundColor', fgUIowa, 'ForegroundColor', [0 0 0],...
    'Position', [.05 .025 .45 .225],...
    'Callback', { @Wire_Callback, fh } );
[~]	= uicontrol('Style', 'listbox',...
    'Tag', UICNames{ 5 },...
    'String', {'Select a Wire Width [mm]', '1.5', '2.5', '3.2', 'Other'},...
    'Parent', hObject,...
    'Value', 2,...
    'Enable', 'On',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', listboxFontSizes,...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0],...
    'Position', [.55 .40 .405 .345],...
    'Callback', { @WireWidth_Callback, fh } );
end


%% Helper.
function concludeCallback( fh, data, saveData, procedure, initialE )
%CONCLUDECALLBACK Ties up odds and ends for PSHF callback function.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Reset axis limits, include updated legend, reset button enability.
data.resetAxisLimits();
procedure.situateWires();
data.set( 'Procedure', procedure );
legendPSHF( fh, data );
% [~]	= toggleUIControls(fh, initialE);

% Compute, display breadth at fracture plane, if possible.
printPSHF( fh, procedure );
saveData.set( 'UserData', data );
saveData.ClickedCallback{ 1 }( saveData, [], fh  );
if nargin == 5
    %     [~]	= toggleUIControls(fh, initialE);
end
fh.set( 'CurrentObject', fh );
end


function legendPSHF( fh, data )
%LEGENDPSHF Displays legend for the fracture plane & varying number of wires.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Sort the axis children such that the humerus is first, followed by wires.
ax  = fh.get( 'CurrentAxes' );
fractureDisplay = data.get( 'Procedure' ).get( 'Humerus' ).get( 'Fracture' ).get( 'Display' );
if isa( fractureDisplay, 'char' )
    if contains( fractureDisplay, 'off' );	fractureDisplay	= [];	end
end
wireDisplays    = flipud( data.get( 'Procedure' ).get( 'Wire' ).get( 'Display' ) );
iempty  = ismember( cellfun( @class, wireDisplays, 'UniformOutput', false ), {'char' } );
wireDisplays( iempty )  = [];
plts    = gobjects( numel( ax.get( 'Children' ) ), 1 );
plts( 1:end ) = vertcat( wireDisplays{ : }, fractureDisplay, ax.Children( end ) );
ax.set( 'Children', plts );
labels	= plts.get( 'Tag' );
if isempty( plts )
    return
end
iIgnore = vertcat( contains( labels( 1:end-1 ), 'Center' ), true );
plts( iIgnore )	= [];
labels( iIgnore )	= [];
legend( plts, labels, 'Location', 'NorthEast', 'Visible', 'On' );
end


function printPSHF( fh, procedure )
%PRINTPSHF Prints state of PSHF to the Log.
%
%   See also BUILDINTERFACEPSHF, CONCLUDECALLBACK.
%==========================================================================

[Breadth, Width, Theta]	= procedure.evaluate();
wires = procedure.get( 'Wire' );
wires( cellfun( @isempty, wires.get( 'Boundary' ) ) )	= [];
convertionFactor    = wires.getRatio();
if ~isempty( wires )
    if length( wires ) > 1
        avgWidth	= nanmean( cell2mat( wires.get( 'WidthMM' ) ) );
    else
        avgWidth	= wires.get( 'WidthMM' );
    end
    printToLog( fh, ['Average estimated wire width: ', num2str( avgWidth ), ' [mm]'], 'Note' );
end
if ~isnan( Width ) % px width / (px per mm).
    fractureWidthMM	= num2str( Width / convertionFactor );
    printToLog( fh, ['Total width along fracture: ~ ', fractureWidthMM, ' [mm]' ], 'Note' );
end
if ~all( isnan( Breadth.MM ) )
    breadthWidthMM  = num2str( Breadth.MM( 3 ) / convertionFactor ); % Should be the max value
    printToLog( fh, ['Breadth of wires along fracture: ~ ', breadthWidthMM, ' [mm]' ], 'Note' );
end
if ~isnan( Breadth.Ratio )
    printToLog( fh, ['Breadth Ratio: ~', num2str( Breadth.Ratio )], 'Note' );
end
if ~isnan( Breadth.Spacing )
    br  = num2str( Breadth.Spacing );
    printToLog( fh, ['Middle Pin-Spread Ratio (w.r.t. outer pins): ~', br], 'Note' );
end
if ~all( isnan( Theta ) )
    str = 'Intersection angles at the fracture plane angles for wires ';
    iTheta	= find( ~isnan( Theta ) );
    for idx = 1:numel( iTheta )
        str = [ str, num2str( iTheta( idx ) ), ', ' ]; %#ok<AGROW>
    end
    if strcmpi( str( end-1:end ), ', ' )
        str( end-1 )	= [];
    end
    str = [ str, '[deg.]: ' ];
    t   = strtrim( cellstr( num2str( round( Theta( iTheta, 1 ) ) ) ) );
    for idx = 1:numel( iTheta ) 
        str     = [str, t{ idx }, ', ']; %#ok<AGROW>
    end
    if strcmpi( str( end-1:end ), ', ' )
        str( end-1:end )	= [];
    end
    printToLog( fh, str, 'Note' );
end
end


%% Callback Functions.
function ElbowFracture_Callback( hObject, ~, fh )
%ELBOWFRACTURE_CALLBACK Predicts fracture location, prompts user input, if
%necessary.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, saveData, fhHandles]	= getFluoroData( fh );
[success, initialE]	= data.checkPlot( fh );
if ~success
    printToLog( fh, ['Cannot define ''', hObject.get( 'String' ), ''' until DICOM is plotted'], 'Error' );
    return
end
printToLog( fh, ['Method: Define ''', hObject.get( 'String' ), ''''], 'Progress' );
printToLog( fh, ['Drag points of line to approximate the fracture by',...
    ' connecting its two endpoints; Double-click to complete'], 'Note' );

% Try to predict the fracture given the image, show it to the user.
procedure   = data.get( 'Procedure' );
humerus	= procedure.get( 'Humerus' );
fractureDisplay	= humerus.get( 'Fracture' ).get( 'Display' );
if ~strcmpi( 'off', fractureDisplay )
    fractureDisplay.set( 'Visible', 'Off' );
end
humerus.defineFracture( data, false );
humerus.plot();
concludeCallback( fh, data, saveData, procedure, initialE );
printToLog( fh, ['''', hObject.get( 'String' ), ''' completed'], 'Success' );
end


function Wire_Callback( hObject, eventData, fh )
%WIRE_CALLBACK Predicts wire location, prompts user input, if necessary.
%
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Get figure handles; ensure that latest selected DICOM is plotted; default axis limits.
[data, ~, ~]	= getFluoroData( fh );
[success, ~]	= data.checkPlot( fh );
str	=  hObject.get( 'String' );
if ~success
    printToLog( fh, ['Cannot define ''', str, ''' until DICOM is plotted'], 'Error' );
    return
end
printToLog( fh, ['Method: Define ''', str, ''''], 'Progress' );
iw  = str2double( str( end ) );
switch iw
    case 1
        iwColor	= 'm';
    case 2
        iwColor	= 'c';
    case 3
        iwColor	= 'b';
end

% Try to predict the wire given the image, show it to the user.
procedure   = data.get( 'Procedure' );
wire   = procedure.get( 'Wire' );
if ~strcmpi( 'off', wire( iw ).get( 'Display' ) )
    wire( iw ).get( 'Display' ).set( 'Visible', 'off' );
end
wire( iw ).defineWire( data, false );
if isempty( wire( iw ).get( 'Boundary' ) )
    procedure.resetWire( iw );
    printToLog( fh, ['''', hObject.get('String'), ''' exited'], 'Note' );
    WireWidth_Callback( findobj( 'Tag', 'Wire Width' ), [], fh );
    return;
end
wire( iw ).plot( 'None', 'Boundary', true, 'BoundaryColor', iwColor );
procedure.set( 'Wire', wire );

% Compute, display TAD (if possible) by calling wire width (which has the same closing code.
printToLog( fh, ['''', hObject.get('String'), ''' completed'], 'Success' );
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

