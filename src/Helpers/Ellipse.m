function [A,B,C, F1, F2, e] = Ellipse(axis_h,markersFlag,ellipsePlotFlag)
%Ellipse - draw an ellipse and return ellipse parameters by using two
%vertices and another point on the ellipse. The points are selected by the
%user on the graph.
%
% Usage: [A,B,C, F1, F2, e] = Ellipse
% or [...] = Ellipse(axis_h)
% or [...] = Ellipse(axis_h, markersFlag)
% or [...] = Ellipse(axis_h, markersFlag, ellipsePlotFlag)
% 
% Inputs: 
%   axis_h - axis handle to plot
%   markersFlag - switch for drawing vertices and points of the ellipse
%   ellipsePlotFlag - switch for drawing the ellipse
%
% Outputs:
%   A - semi-major axis
%   B - semi-minor axis
%   C - center of the ellipse (x and y location)
%   F1, F2 - focus points (each one is a 2-element vector of x and y location)
%   e - eccentricity
%
% If the 3rd point is out of a possibe ellipse, the result will be a 
%
% Written by Noam Greenboim
% www.perigee.co.il
%


if nargin<3
    if nargin<2
        if nargin<1
            axis_h = gca;
        end
        markersFlag = 1;
    end
    ellipsePlotFlag = 1;
end

holdOrig = get(axis_h,'nextplot');
set(axis_h,'nextplot','add');

%% get points
G = ginput(1); % 1st point - 1st apsis
x1 = G(1,1);
y1 = G(1,2);
h1 = plot(x1,y1,'or');

G = ginput(1); % 2nd point - 2nd apsis
x2 = G(1,1);
y2 = G(1,2);
h2 = plot(x2,y2,'ok');

G = ginput(1);  % 3rd point - a point on the ellipse
x3 = G(1,1);
y3 = G(1,2);
h3 = plot(x3,y3,'ob');

%% calculations
a = 1/2*sqrt((x2-x1)^2+(y2-y1)^2);  % semi-major axis (probably)
Cx = (x1+x2)/2;     % center point
Cy = (y1+y2)/2;
h4 = plot(Cx,Cy,'*r');

 w = atan2(y2-y1,x2-x1);    % rotation of ellipse
xold = (x3-Cx)*cos(w)+(y3-Cy)*sin(w);  %3rd point, corrected to a non-rotated ellipse
yold = -(x3-Cx)*sin(w)+(y3-Cy)*cos(w);
b = yold/(sqrt(1-(xold/a)^2));  % semi-minor axis (probably)
 
%% canonical ellipse, without rotation and displacement
 t = linspace(0,2*pi,200);  
 X = a*cos(t);  
 Y = b*sin(t);

 %% ellipse after rotation and displacement 
 x = Cx + X*cos(w) - Y*sin(w);
 y = Cy + X*sin(w) + Y*cos(w);
 if ellipsePlotFlag
    plot(x,y,'r-');
 end
 h5 = line([x1 x2],[y1 y2]);

A = max(a,b);   % semi-major axis (definitely)
B = min(a,b);  % semi-minor axis (definitely)
e = sqrt(1-(B/A)^2);    % eccentricity

if e<0 || e>1 || ~isreal(e)
    [A,B,e] = deal(NaN);
    [F1, F2, C] = deal([NaN NaN]);
else
    f = sqrt(A^2-B^2);
    F1 = [Cx+f*cos(w) Cy+f*sin(w)];  % focus
    F2 = [Cx-f*cos(w) Cy-f*sin(w)];  % focus
    C = [Cx Cy];    % center of ellipse
end


%% remove marks
if ~markersFlag
    delete([h1 h2 h3 h4 h5])
end

set(axis_h,'nextplot',holdOrig);    % set the original state
