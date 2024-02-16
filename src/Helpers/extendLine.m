function lineObject = extendLine( lineObject, direction, eq )
%EXTENDLINE Extend to ( x ) axis limit.
%   lineObject = EXTENDLINE( lineObject, direction ) returns the updated
%   line object of the extended line defined by lineObject in the specified
%   direction. EXTENDLINE will add one point at the extent of the current
%   axis that lineObject is plotted on.
%   
%   lineObject = EXTENDLINE( lineObject, direction, eq ) uses the input
%   function handle eq to compute the new y, given the x-extent of the
%   axis. If no valid equation is given, a slope and y-intercept are
%   computed and used as the linear equation.
%   
%   Note: 'direction' will take precedence over the inputted line, i.e.,
%   if direction is 'left' but the second x coordinate is larger than the
%   first, the points will be switched to comply with 'direction'.
%   
%   See also DRAWLINE, ALIGNLINEWITHDIRECITON.
%==========================================================================

% Given the specified direction, create a new set of points.
narginchk( 2, 3 );
x   = lineObject.get( 'XData' );
y   = lineObject.get( 'YData' );
xNew    = NaN( 1, 3 );
yNew    = NaN( 1, 3 );
[xNew( 1:2 ), yNew( 1:2 )]	= alignLineWithDirection( x( 1:2 ), y( 1:2 ), direction );

% Create 3rd point at the extent of the x axis in the specified direction.
xLim	= lineObject.get( 'Parent' ).get( 'xlim' );
if strcmpi( direction( 1 ), 'L' )
    xNew( end )   = xLim( 1 );
else
    xNew( end )   = xLim( end );
end

% Use equation of line to compute final y-coordinate if it exists.
if nargin < 3
    m   = diff( yNew( 1:2 ) ) / diff( xNew( 1:2 ) );
else % Project a y using the moving-average slope of the previous points.
%     interpXY    = interparc( 10, x, y );
    interpXY    = eq( 0:0.1:1 );
    if xNew( 1 ) - interpXY( 1 , 1 ) > 1        % Temporary.
        interpXY    = flipud( interpXY );
    end
    slopes  = diff( interpXY( :, 2 ) ) ./ diff( interpXY( :, 1 ) );
    movingAvgSlopes	= movmean( slopes, size( interpXY, 1 ) / 3 );
    m   = movingAvgSlopes( end );
end
b	= yNew( 2 ) - ( m * xNew( 2 ) );
yNew( 3 )	= ( m * xNew( 3 ) ) + b;

% Create and return new plot.
lineObject.set( 'XData', xNew, 'YData', yNew );

