function legendObject   = buildLegend(figureHandle, hObject, varargin)
%BUILDLEGEND Creates, updates DICOM legend.
%   legendObject = BUILDLEGEND(figureHandle) returns the legend object for
%   the CurrentAxes of the figureHandle. If a legend does not exist on the
%   first call of BUILDLEGEND, one is instantiated and placed outside of
%   the axis in the top right corner.
%   
%   legendObject   = BUILDLEGEND(figureHandle, hObject) the plot object
%   hObject and it's associated Tag are added to the legendObject. When
%   another plot object with the same tag already exists as a part of
%   legendObject, a number is appended to the string, i.e. line1, line2,
%   ..., lineN.
%   
%   See also
%==========================================================================

% Parse input.
p   = inputParser;
p.CaseSensitive	= false;
p.addRequired('figHandle', @(x) isa(x, 'matlab.ui.Figure'))
p.addOptional('hObject', NaN, @(x) isa(x, 'matlab.ui.control.UIControl'))
p.parse(varargin{:});

% Grab legend.
legendObject     = findobj(fh.CurrentAxes, 'Type', 'Legend');
if isempty(legendObject)
    legendObject = legend('location','NorthEastOutside');
end

