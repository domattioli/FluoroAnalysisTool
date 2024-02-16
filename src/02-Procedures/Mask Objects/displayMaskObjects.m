function fh = displayMaskObjects( fh, chosenProcedureObj )
%DISPLAYMASKOBJECTS Displays Mask Objects Procedure buttons.
%   fh = DISPLAYMASKOBJECTS( fh ) returns the updated gui with buttons for
%   masking objects.
%
%   See also BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Create DHS panel if it has not already been done during life of GUI.
if isempty( allchild( chosenProcedureObj ) )
    gui_State  = guidata( fh );
    gui_State.gui_LayoutFcn    = @buildInterfaceMaskObjects;
    guidata( fh, gui_State );
    fh	= buildInterfaceMaskObjects( fh, chosenProcedureObj );
end
set( findobj( 'Tag', 'Initial Condition' ), 'Value', true );

[data, ~, fhHandles]	= getFluoroData( fh );
iter = 1;
while isempty( data.get( 'Project' ) )
    if iter == 1
        printToLog( fh, 'You must specify a destination folder for saving your masks', 'Note' );
    end
    projectButton	= fhHandles.FigureToolBar.Children(end);
    projectButton.ClickedCallback{ 1 }( projectButton, [], fh  );
end

% Reset the 'Current Masks' list.
currentMasks	= findobj( 'Tag', 'Current Masks' );
currentMasks.set( 'String', '', 'Value', 1 );

printToLog( fh, 'You must select "AP" or "Lateral" view before continuing', 'Note' );

