function WS	= flipWire(WS, direction)
%FLIPWIRE Flip x- y- coordinate array of wire slope.
%	FN	= FLIPWIRE(WS, direction) returns the wireSlopeObject WS
%   containing the line object overlayed to the position of a UIControl
%   imline object for the wire slope.
%   
%   See also FLIPBISECTOR, DEFINEWIRESLOPE, ALIGNLINEWITHDIRECITON.
%==========================================================================

% Get Wire Slope [x,y] data.
x   = WS.Plot.get('XData');
y   = WS.Plot.get('YData');

% Given the specified direction, create a new set of points.
xNew    = NaN(1, 3);
yNew    = NaN(1, 3);
[xNew(1:2), yNew(1:2)]	= alignLineWithDirection(x(1:2), y(1:2), direction);

% Extend the new line from its current (2) real points.
WS.Plot.set('XData', xNew, 'YData', yNew);
WS.Plot	= extendLine(WS.Plot, direction);

