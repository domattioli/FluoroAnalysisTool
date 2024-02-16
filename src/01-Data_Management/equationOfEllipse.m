function eq = equationOfEllipse( pos )
%EQUATIONOFELLIPSE Creates equation of a line
%   EQ = EQUATIONOFELLIPSE( pos ) returns an equation defining the ellipse.
%
%   SIMPLIFYELLIPSE uses this link as motivation for defining
%   the foci and axes of an ellipse:
%   https://courses.lumenlearning.com/waymakercollegealgebra/chapter/equations-of-ellipses/
%
%   ( ( x-h )^2 )/( a^2 ) + ( ( y-h )^2 )/( b^2 ) = 1
%
%   See also SIMPLIFYELLIPSE.
%==========================================================================

% Depending on the major axis, define the ellipse equation.
minInfo     = simplifyEllipse( pos );
horizontalD	= abs( minInfo.Left_XY( 1 ) - minInfo.Center_XY( 1 ) );
verticalD	= abs( minInfo.Top_XY( 2 ) - minInfo.Center_XY( 2 ) );
if ( horizontalD >= verticalD )
    eq.X  = strrep( '@(t) a.*cos( t ) + h', 'a', num2str( horizontalD ) );
    eq.Y  = strrep( '@(t) b.*sin( t ) + k', 'b', num2str( verticalD ) );
    %                 eq  = 'sqrt( b.^2 * ( 1 - ( ( x - h ).^2/ ( a.^2 ) ) ) ) + k';
    
else
    eq.X  = strrep( '@(t) b.*cos( t ) + h', 'a', num2str( verticalD ) );
    eq.Y  = strrep( '@(t) b.*sin( t ) + k', 'b', num2str( horizontalD ) );
end
eq.X  = str2func( strrep( minInfo.Equation.X, 'h', num2str( minInfo.Center_XY( 1 ) ) ) );
eq.Y  = str2func( strrep( minInfo.Equation.Y, 'k', num2str( minInfo.Center_XY( 2 ) ) ) );

