function wireObject  = defineAddWire(fh, hObject, nWires)
%DEFINEADDWIRE Creates imline for approximating the wire slope.
%	wireSlopeObject = DEFINEWIRESLOPE(fh, hObject, data) returns the plot
%   object overlaying the position of a UIControl imline object for the
%   wire.
%	
%   Note: DEFINEFEMORALHEAD waits until the user has double-clicked the
%	object before returning an output.
%   
%   See also DEFINEFEMORALHEAD, DEFINEFEMORALNECK, REMOVEWIRESLOPE,
%   PREDICTWIRESLOPE, BUILDINTERFACEDHS.
%==========================================================================

newLabel	= num2str(nWires);
printToLog(fh, ['Method: ', hObject.get('Tag'), ' #', newLabel], 'Progress');
if nWires == 1
    printToLog(fh, ['Drag points of line (from entry-point to end) to',...
        ' define the wire''s slope; Double click to confirm.'], 'Note');
end

% Possible wire colors: 'coral', 'orange', 'orange-red' (https://www.rapidtables.com/web/color/orange-color.html).
colors  = [255 127 80; 255 165 0; 255 69 0];

% Define new wire with a labeled line object.
wireObject	= drawLabeledLine(fh, 'label', newLabel,...
    'color', colors(nWires, :), 'Tag', ['Wire', ' #', newLabel]);
wait(wireObject);

