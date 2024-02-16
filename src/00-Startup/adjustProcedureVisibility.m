function adjustProcedureVisibility( chosenProcedure, siblings, parentPanel )
%ADJUSTPROCEDUREVISIBILITY Put chosen procedure at top of uistack.
%   ADJUSTPROCEDUREVISIBILITY(chosenProcedure, siblings, parentPanel) sets
%   the procedure and 'AP or Lateral' radio buttons (if necessary) to
%   visible and at the top of the ui stack, with it's siblings following,
%   followed finally by the parentPanel of procedure and it's siblings.
%   
%   See also PROCEDURELIST_CALLBACK, BUILDPROCEDUREFOREGROUNDPANEL.
%==========================================================================

% Create reordered uistack.
newStack    = vertcat( findobj( siblings, 'Tag', 'AP or Lateral' ), chosenProcedure );
siblingProcedures   = setdiff( siblings, vertcat( newStack, parentPanel ) );
newStack    = vertcat( newStack, parentPanel, siblingProcedures );

% Adjust visibility of other procedures' panels' children.
siblingProcedures.set( 'Visible', 'Off' );
newStack( [1:2, end] ).set( 'Visible', 'On' );
set( parentPanel.get( 'Parent' ), 'Children', newStack ); % 'AP or Lat' on top.

