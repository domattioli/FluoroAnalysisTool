function obj = matchGUIPosition( fh, obj )
%MATCHGUIPOSITION Place dialog/waitbar/etc at center of GUI.
%   obj = matchGUIPosition(fh, obj) returns object of dialog to with an
%   updated position that matches with respect to the center of the GUI's
%   figure handle, fh.
%   
%   See also
%==========================================================================

% Get both figure's and current object's current display positions.
set( 0, 'Units', 'Normalized' );
obj.set( 'Units', 'Normalized', 'Visible', 'Off' );
objPos  = obj.get( 'Position' );
monPos  = get( 0, 'MonitorPositions' );

% Aassume figure is in the last monitor --- this is hardcoded; should analze fh.
imonPos = size( monPos, 1 );

% Get center x, y coordinate of monitor of fh.
xy	= ( monPos( imonPos, 1:2 ) + monPos( imonPos, 3:4 )./2 )';

% Move the x coordinate of obj to half of it's width from the center of fh.
new_objPos  = objPos;
new_objPos( 1 )	= xy( 1 ) - ( objPos( 3 )/2 );
new_objPos( 2 )	= xy( 2 ) - ( objPos( 4 )/2 );
obj.set( 'Position', new_objPos, 'Visible', 'On' );

% Bring obj to front.
set( 0, 'Units', 'pixels' );

