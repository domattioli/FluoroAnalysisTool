function fh = displayDHS( fh, chosenProcedureObj )
%DISPLAYDHS Displays DHS Procedure buttons.
%   fh = DISPLAYDHS(fh) returns the updated gui with visible DHS procedure.
%
%   See also BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Create DHS panel if it has not already been done during life of GUI.
if isempty( allchild( chosenProcedureObj ) )
    gui_State  = guidata( fh );
    gui_State.gui_LayoutFcn    = @buildInterfaceDHS;
    guidata( fh, gui_State );
    fh	= buildInterfaceDHS( fh, chosenProcedureObj );
end
set( findobj( 'Tag', 'Initial Condition' ), 'Value', true );

printToLog( fh, 'Must select "Left" or "Right" side (of pelvis) before continuing', 'Note' );

