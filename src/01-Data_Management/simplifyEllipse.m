function minInfo = simplifyEllipse( pos )
%SIMPLIFYELLIPSE Simplifies (x,y) ellipse into minimum info.
%   minInfo = SIMPLIFYELLIPSE( pos ) returns the minimum
%   information necessary to define an ellipse: the top point
%   (x,y), the left point (x,y), and the center point (x,y),
%   given the x- and y- coordinates defining the entire
%   ellipse boundary.
%
%   SIMPLIFYELLIPSE uses this link as motivation for defining
%   the foci and axes of an ellipse:
%   https://courses.lumenlearning.com/waymakercollegealgebra/chapter/equations-of-ellipses/
%
%   ( ( x-h )^2 )/( a^2 ) + ( ( y-h )^2 )/( b^2 ) = 1
%
%   See also GENERATEELLIPSEPOINTS, EQUATIONOFELLIPSE.
%==========================================================================

% Initialize minimum information
posRounded  = round( pos, 2 );
[~,ileftPt]	= min( posRounded( :, 1 ) );
[~,itopPt]	= max( posRounded( :, 2 ) );
minInfo     = struct( 'Left_XY', posRounded( ileftPt, : ),...
    'Top_XY', posRounded( itopPt, : ),...
    'Center_XY', horzcat( posRounded( itopPt, 1 ), posRounded( ileftPt, 2 ) ) );

