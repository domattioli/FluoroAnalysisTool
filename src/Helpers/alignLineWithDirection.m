function [xNew, yNew] = alignLineWithDirection(xIn, yIn, direction)
%ALIGNLINEWITHDIRECITON switches x- and y- coordinates wrt direction.
%   [xNew, yNew] = alignLineWithDirection(xin, yin, direction) returns new
%   x- and y-coordinates that respect the 'Left'/'Right' input direction.
%   
%   See also EXTENDLINE, FLIPWIRE.
%==========================================================================

if ( direction(1) == 'L' && ( xIn(2) > xIn(1) ) ) || ...
        ( direction(1) == 'R' && ( xIn(1) > xIn(2) ) )
    % First 2 points must be switched.
    xNew	= fliplr(xIn);
    yNew	= fliplr(yIn);
    
else
    % First 2 points are as inputted.
    xNew	= xIn;
    yNew	= yIn;
end

