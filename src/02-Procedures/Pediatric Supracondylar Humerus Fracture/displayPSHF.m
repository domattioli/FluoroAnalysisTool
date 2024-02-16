function fh = displayPSHF( fh, chosenProcedure )
%DISPLAYPSHF Displays PSHF Procedure buttons.
%   fh = DISPLAYPSHF(fh) returns the updated gui with visible PSHF
%   procedure.
%
%   See also BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Create PSHF panel if it has not already been done during life of GUI.
if isempty( allchild( chosenProcedure ) )
    gui_State  = guidata( fh );
    gui_State.gui_LayoutFcn    = @buildInterfacePSHF;
    guidata( fh, gui_State );
    fh	= buildInterfacePSHF( fh, chosenProcedure );
end

% [~]    = toggleUIControls( fh, initialE );

