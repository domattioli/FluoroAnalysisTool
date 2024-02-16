function [x,y] = generateEllipsePoints( centerXY, topXY, leftXY )
%GENERATEELLIPSEPOINTS Generate points of ellipse from min. information.
%   [x,y] = ellipsePoints(centerXY,topXY,leftXY) returns the x and y
%   coordinates estimating the geometry of an ellipse defined by its
%   minimum information coordinates centerXY (centroid), topXY (vertical
%   axis), and leftXY (horizontal axis).
%
%   See also
%==========================================================================

% Given ((x-h)^2)/(a^2) + ((y-k)^2)/(b^2) = 1, find 'a' and 'b'.
if nargin == 1 && isstruct( centerXY )
    temp = centerXY;
    centerXY= temp.Center_XY;
    leftXY	= temp.Left_XY;
    topXY	= temp.Top_XY;
end
h	= centerXY( 1 );
k   = centerXY( 2 );
a	= h - leftXY( 1 );                              % Horizontal radius.
b	= topXY( 2 ) - k;                               % Vertical radius.

% Compute x, y coordinates of ellipse using paramentric equations.
x	= a.*cos( linspace( -pi,pi, 100 ) ) + h;
y	= b.*sin( linspace( -pi,pi, 100 ) ) + k;

