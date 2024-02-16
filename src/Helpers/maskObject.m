function [BW, plt] = maskObject( varargin )
%MASKOBJECT Prompt user to mask a region of interest in the current axis.
%   BW = MASKOBJECT( currentAxis, N ) returns the binary mask BW resulting
%   from the impoly drawn by the user in the current axis. BW is
%   interpolated as a spline.
%   
%   [BW, plt] = MASKOBJECT( currentAxis, N, plotResult ) will overlay the
%   result in the current axis and return the plot object handle.
%   
%   See also 
%==========================================================================

p = inputParser;
p.addRequired( 'currentAxis', @(x) isa( x, 'matlab.graphics.axis.Axes' ) );
p.addRequired( 'numPoints', @(x) isnumeric( x ) );
p.addParameter( 'showPlot', true, @(x) islogical( x ) );
p.addParameter( 'style', '.-', @(x) ischar( x ) );
p.addParameter( 'tag', 'Mask', @(x) ischar( x ) );
p.parse( varargin{:} );
narginchk( 2 , numel( p.Parameters )*2 - 2 );

% Draw roi.
initialState    = p.Results.currentAxis.get( 'NextPlot' );
p.Results.currentAxis.set( 'NextPlot', 'Add' );
h	= impoly( p.Results.currentAxis );
pos	= wait( h );
delete( h );
if isempty( pos )
    BW	= [];
    plt	= [];
    return
end

% Create outputting mask.
pt	= interparc( ceil( p.Results.numPoints * 1.10 ), pos( :, 1 ), pos( :, 2 ), 'pchip' );
pt  = vertcat( pt, pt( 1, : ) );
imgObj	= findobj( p.Results.currentAxis.get( 'Children' ), 'Type', 'Image' );
BW  = poly2mask( pt( :, 1 ), pt( :, 2 ), size( imgObj.CData, 1 ), size( imgObj.CData, 2 ) );

% Plot result.
plt	= plot( NaN, NaN, p.Results.style, 'Tag', p.Results.tag, 'DisplayName', p.Results.tag );
if p.Results.showPlot
    plt.set( 'Visible', 'On' );
else
    plt.set( 'Visible', 'Off' );
end
plt.set( 'XData', pt( :, 1 ), 'YData', pt( :, 2 ) );
p.Results.currentAxis.set( 'NextPlot', initialState );

