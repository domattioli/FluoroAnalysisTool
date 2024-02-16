function lineObject = drawLine( axisHandle, varargin )
%DRAWLINE Active UIControl line object on Fluoro.
%   lineObject = DRAWLINE( axisHandle, varargin ) returns the lineObject for
%   a line drawn to axisHandle. DRAWLINE plots the lineObj on the main
%   axis. Additional arguments pertain to the plotting elements of the plot
%   object, and the lineObject's tag.
%
%   See also DRAWLABELEDLINE, EXTENDLINE.
%==========================================================================

% Parse input.
validateColor	= @( x ) isa( x, 'char' ) || and( isnumeric( x ), length( x ) == 3 );
nLinesInAxis    = length( findobj( axisHandle.Children, 'Type', 'Line' ) );
p   = inputParser;
p.CaseSensitive	= false;
p.addParameter( 'color', 'r', validateColor ) % Might need to refine.
p.addParameter( 'marker', 's', @( x ) isa( x, 'char' ) ) % Might need to refine.
p.addParameter( 'linestyle', '--', @( x ) isa( x, 'char' ) ) % Might need to refine.
p.addParameter( 'markersize', 7, @( x ) isnumeric( x ) && x > 0 )
p.addParameter( 'linewidth', 3.5, @( x ) isnumeric( x ) && x > 0 )
p.addParameter( 'tagname', ['Line', num2str( nLinesInAxis )], @( x ) ischar( x ) )
narginchk( 1, 1+( length( p.Parameters )*2 ) );
p.parse( varargin{:} );

% Initialize plotted line object.hold on;
lineObject	= line( NaN( 2,1 ), NaN( 2,1 ),...
    'Tag', p.Results.tagname,...
    'Parent', axisHandle,...
    'color', p.Results.color, 'linewidth', p.Results.linewidth,...
    'linestyle', p.Results.linestyle, 'marker', p.Results.marker,...
    'markerfacecolor', p.Results.color, 'markersize', p.Results.markersize );

% Draw line.
l	= imline( axisHandle );
pos = round( wait( l ), 0 );
while ~isvalid( l )
    l	= imline( axisHandle );
    pos = round( wait( l ),0 );
end
wx  = [pos( :,1 ); NaN];
wy  = [pos( :,2 ); NaN];
delete( l );

% Compute equation of line given [x1,y2] and [x2,y2].
m   = diff( wy( 1:2 ) )/diff( wx( 1:2 ) );
b	= wy( 1 ) - m*wx( 1 );
lineObject.set( 'UserData', struct( 'Slope', m, 'yIntercept', b ) );
lineObject.set( 'XData', wx );
lineObject.set( 'YData', wy );
drawnow;

