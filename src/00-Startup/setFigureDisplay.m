function fh = setFigureDisplay(fh)
%SETFIGUREDISPLAY Sets GUI extent, location to the second monitor.
%   
%   See also FLUORODICOM_GUI.
%==========================================================================

% Get pixel position of monitors.
set(0, 'Units', 'Pixels');
MP	= get(0, 'MonitorPositions');

% Set position of fh to the secondary monitor, if possible.
distance  = 0.125;
newPosition	= [MP(1,3)*distance, MP(1,4)*distance,...
    MP(1,3)*(1-distance*2), MP(1,4)*(1-distance*2)];
if size(MP, 1) == 1
    % Single monitor -- do nothing.
    
else
    % Multiple monitors - shift to second.
    newPosition(1)	= newPosition(1) + MP(2,1);
end
fh.set('Position', newPosition, 'units', 'normalized');
fh.WindowState	= 'maximized';                      % Wrt current window.
