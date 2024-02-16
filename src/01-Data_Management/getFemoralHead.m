function [x, y] = getFemoralHead(femoralHead)
%GETFEMORALHEAD Retrieves x-, y-coordinates of femoral head ellipse.
%   [x, y] = GETFEMORALHEAD(femoralHead) returns the x- and y- coordinates
%   of the ellipse defined for the emoral head.
%       In:
%           femoralHead must be a struct with fields:
%               Plot: [1x1 Line]
%               MinInfo: [1x1 Struct]
%       Out:
%           x: Mx1 double
%           y: Mx1 double
%   
%   See also GETFEMORALNECK, GETWIRE.
%==========================================================================



if strcmpi(neckOrBisector, 'Both')
    x   = struct('Neck', femoralNeck.NeckPlot.get('XData')',...
        'Bisector', femoralNeck.BisectorPlot.get('XData')');
    y   = struct('Neck', femoralNeck.NeckPlot.get('YData')',...
        'Bisector', femoralNeck.BisectorPlot.get('YData')');
    
elseif strcmpi(neckOrBisector, 'Neck')
    x   = femoralNeck.NeckPlot.get('XData');
    y   = femoralNeck.NeckPlot.get('YData')';
    
elseif strcmpi(neckOrBisector, 'Bisector')
    x   = femoralNeck.BisectorPlot.get('XData');
    y   = femoralNeck.BisectorPlot.get('YData')';
    
else
    error('Invalid input.');
end
