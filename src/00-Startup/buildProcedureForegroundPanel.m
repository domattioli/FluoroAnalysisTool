function fh = buildProcedureForegroundPanel( fh )
%BUILDPROCEDUREFOREGROUNDPANEL Import procedure panel and its contents.
%   fh = BUILDPROCEDUREFOREGROUNDPANEL(fh) returns an updated figure handle
%   fh containing a panel for procedure buttons.
%   
%   See also MAIN>OPENINGFCN,
%   BUILDPROCEDUREFOREGROUNDPANEL>APLATERAL_CALLBACK,
%   BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Build GUI Parts.
procedureNames	= getProcedureNames();
procedureUICNames	= {'Procedure Foreground',...
    'Procedure Names',...
    'AP or Lateral',...
    'Initial View',...
    'AP',...
    'Lateral'};
procedureForegroundParent	= uipanel(...
    'Tag', procedureUICNames{ 1 }, 'Title', 'Procedure',...
    'Parent', fh,...
    'BackgroundColor', bgColor, 'ForegroundColor', 'k', 'ShadowColor', 'k',...
    'Position', [.70 .35 .285 .375],...
    'FontWeight', 'Bold', 'FontSize', 15 );
[~]	= uicontrol('Style', 'PopUpMenu',...
    'Tag', procedureUICNames{ 2 }, 'String', getProcedureNames(),...
    'Parent', procedureForegroundParent,...
    'Units', 'normalized',...
    'BackgroundColor', [1 1 1], 'ForegroundColor', [0 0 0],...
    'FontUnits', 'normalized', 'FontSize', 0.18,...
    'Position', [0.05 0.775 0.90 0.225],...
    'Enable', 'on', 'Visible', 'off',...
    'Value', length( procedureNames ), 'UserData', char(),...
    'Callback', { @ProcedureList_Callback, fh } );

% Build AP-Lateral Radio Buttons too.
APLateralRadios	= uibuttongroup(...
    'Tag', procedureUICNames{ 3 }, 'Title', [],...
    'Parent', procedureForegroundParent,...
    'BackgroundColor', [1 1 .8],...
    'Position', [.55 .575 .405 .165],...
    'Visible', 'off');
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', procedureUICNames{ 4 }, 'String', procedureUICNames{ 4 },...
    'Parent', APLateralRadios,...
    'Value', true,...
    'Visible', 'off',...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.25,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', [0 0 0],...
    'Position', [.00 .00 .00 .00],...
    'UserData', { @APLateral_Callback, fh} );
[~]	= uicontrol( 'Style', 'RadioButton',...
    'Tag', procedureUICNames{ 5 }, 'String', procedureUICNames{ 5 },...
    'Parent', APLateralRadios,...
    'Value', false,...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.25,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', [0 0 0],...
    'Position', [.15 .00 .35 1.00],...
    'Callback', { @APLateral_Callback, fh } );
[~]	= uicontrol('Style', 'RadioButton',...
    'Tag', procedureUICNames{ 6 }, 'String', procedureUICNames{ 6 },...
    'Parent', APLateralRadios,...
    'Value', false,...
    'FontUnits', 'normalized', 'Units', 'normalized',...
    'FontName', 'Default', 'FontSize', 0.25,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', [0 0 0],...
    'Position', [.55 .00 .35 1.00],...
    'Callback', {@APLateral_Callback, fh});

% Update fh UserData; Build panels for each installed procedure.
fh.set( 'UserData', fh.get( 'UserData' ).createNew( procedureForegroundParent ) );
fh	= assembleProcedurePanels( fh );
end


%% GUI Callbacks.
% Identify Camera View.
function APLateral_Callback( hObject, ~, fh )
%APLATERAL_CALLBACK Stores AP/Lateral designation to output data.
%   
%   See also BUILDPROCEDUREFOREGROUNDPANEL, BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Get figure handles and fluoro data.
[data, saveData]	= getFluoroData( fh );

% Grab currently-selected button designation, assign to data output.
switch hObject.get( 'String' )
    case { 'AP' }
        data.set( 'View', 'AP' );
    case {'Lateral'}
        data.set( 'View', 'L' );
    otherwise
        data.resetView();
        hObject.set( 'String', 'No' );
end
printToLog( fh, [hObject.get( 'String' ), ' view designated'], 'Success' );
saveData.set( 'UserData', data );
end


% Display buttons based on Procedure Selection.
function ProcedureList_Callback( hObject, ~, fh )
%PROCEDURELIST_CALLBACK Appends relavant buttons of procedure to GUI.
% 	Integrates different procedures into GUI.
%   
%   See also BUILDPROCEDUREFOREGROUNDPANEL, BUILDPROCEDUREFOREGROUNDPANEL>APLATERAL_CALLBACK.
%==========================================================================

% Get figure handles and fluoro data.
[data, saveData]	= getFluoroData( fh );
proceduresUI	= allchild( hObject.get( 'Parent' ) );
proceduresUIChildrenTags	= proceduresUI.get( 'Tag' );
nproceduresUIChildren	= length( proceduresUI );

% Clear graph of non-image plots.
mainAxisImage	= allchild( fh.get('CurrentAxes') );
delete( mainAxisImage( 1:end-1 ) );

% Check if no procedure selected.
iprocedure	= hObject.get( 'Value' );
if iprocedure == length( hObject.get( 'UserData' ) )	% 'None Selected'.
    % Make all children in panel (except listbox) invisible.
    iprocedureList	= find( contains( proceduresUIChildrenTags, 'Procedure List' ) );
    procedureList	= proceduresUI( iprocedureList ); 
    procedureList.set( 'Visible', 'on' );
    proceduresUI( setdiff( 1:nproceduresUIChildren, iprocedureList ) ).set( 'Visible', 'off' );
    printToLog( fh, 'No procedure selected', 'Success' );
    return
else
    % Assign currently-chosen procedure to data.
    chosenProcedureStr	= hObject.String{ iprocedure };
    chosenProcedureObj	= findobj( proceduresUI, 'Tag', chosenProcedureStr );
end

% Print to log depending on if procedure is being restarted.
procedure	= data.get( 'Procedure' );
if isempty( procedure )
    procedure   = Procedure( data );
end
if strcmp( procedure.get( 'Name' ), chosenProcedureStr )
    printToLog( fh, ['Restarting current ''', chosenProcedureStr, ''' procedure'], 'Progress' );
else
    printToLog( fh, ['Beginning ''', chosenProcedureStr, ''' procedure'], 'Success' );
end
printToLog( fh, 'To save data, find the ''Save Data'' icon in the toolbar', 'Progress' );

% Display buttons according to chosenProcedure.
switch chosenProcedureStr
    case 'DHS Tip-Apex Distance'
        [~]	= displayDHS( fh, chosenProcedureObj );
        data.set( 'Procedure', DHS( data ) );
        
    case 'Pediatric Supracondylar Humerus Fracture'
        [~]	= displayPSHF( fh, chosenProcedureObj );
        data.set( 'Procedure', PSHF( data ) );
        
    case 'Watch Surgery'
        [~]	= displayWatchSurgery( fh, chosenProcedureObj );
        data.set( 'Procedure', Procedure( data, 'Name', 'Watch Surgery', 'Tag', 'Watch Surgery' ) );
        
    case 'Mask Objects'
        fh = displayMaskObjects( fh, chosenProcedureObj );
        data.set( 'Procedure', Procedure( data, 'Name', 'Mask Objects', 'Tag', 'Mask Objects' ) );

    otherwise   % 'No Procedure Selected'
        % Just reset everything.
end
saveData.set( 'UserData', data );

% Ensure procedure buttons are at top of ui.
adjustProcedureVisibility( chosenProcedureObj, proceduresUI, hObject );
fh.set( 'CurrentObject', fh );
end

