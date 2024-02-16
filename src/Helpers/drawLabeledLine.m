function lineObject = drawLabeledLine(figHandle, varargin)
%DRAWLABELEDLINE Active UIControl line object on Fluoro.
%   lineObject = DRAWLABELEDLINE(figHandle, varargin) returns the line
%   object for a line drawn on the main axis of the FluoroAnalysisTool.
%   Inherently, DRAWLINE plots the lineObj on the main axis. Additional
%   arguments pertain to the plotting elements of the line object. hObject
%   should be the invoking UIControl button's handle.
%
%   See also DRAWLINE.
%==========================================================================

% Parse input.
validateColor	= @(x) isa(x, 'char') || and(isnumeric(x), length(x) == 3);
p   = inputParser;
p.CaseSensitive	= false;
p.addParameter('label', @(x) isa(x, 'char')) % Might need to refine.
p.addParameter('color', 'r', validateColor) % Might need to refine.
p.addParameter('tag', 'Wire', @(x) isa(x, 'char')) % Might need to refine.
p.parse(varargin{:});

% Draw line.
lineObject	= imdistline(figHandle.CurrentAxes);
lineObject.setLabelTextFormatter(p.Results.label);
lineObject.setColor(p.Results.color./255);