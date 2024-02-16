function [x, y] = getFemoralNeck(femoralNeck, neckOrBisector)
%GETFEMORALNECK Retrieves x-, y-coordinates of femoral neck geometry.
%   [x, y] = GETFEMORALNECK(femoralNeck) returns the x- and y- coordinates
%   of both geometric entities of the femoral neck - the neck itself and
%   its bisector.
%       In:
%           femoralNeck must be a struct with fields:
%               NeckPlot: [1x1 Line]
%               BisectorPlot: [1x1 Line]
%       Out:
%           x and y are both structs with fields:
%               Neck: 2x1 double (dimensions for both x and y)
%               Bisector: 2x1 double (dimensions for both x and y)
%   
%   [x, y] = GETFEMORALNECK(femoralNeck, 'entity') returns the coordinates
%   of the geometric entity specified by the string 'entity', where
%   'entity' may be 'Neck', 'Bisector', or 'Both'. Inputting 'both' is the
%   same as only one input argument.
%       Out:
%           Unless 'entity' is 'both', both x and y return as 2x1 doubles.
%   
%   
%   See also GETFEMORALHEAD, GETWIRE.
%==========================================================================

if nargin == 1
    neckOrBisector	= 'Both';
end

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
