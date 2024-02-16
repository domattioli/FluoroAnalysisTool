function [data, success] = getResultsPSHF(fhHandles, data, fieldNames)
%GETRESULTSPSHF Computes PSHF result.
%   [data, success] = GETRESULTSPSHF(fhHandles, data, fieldNames) displays
%   a log message of computed breadth ratio of the 1st and 3rd wire with
%   respect to the fracture line. GETRESULTSPSHF also returns the updated
%   fluoroProcess object data containing the current intersection points of
%   the fracture line and the wires.
%   
% See also BUILDINTERFACEDHS.
%==========================================================================

% Check existence of fracture, wire line object(s).
result = data.get('Result');
EF  = result.(fieldNames{contains(fieldNames, 'Fracture')});
AW  = result.(fieldNames{contains(fieldNames, 'Add')});
if or(isempty(EF), isempty(AW))
    success	= false;
    
else
    % Initialize result for relevant GUI button -- get intersection object.
    iFI = contains(fieldNames, 'Intersections');
    FI  = result.(fieldNames{iFI});
    
    % Remove previous intersection plots.
    data	= removeIntersections(data, fieldNames, iFI);
    
    % Get x-, y-coordinates of wire(s) with the fracture line.
    xyEF    = vertcat(EF.Plot.get('XData'), EF.Plot.get('YData'));
    
    % Find intersection points of wire(s) with the fracture line.
    hold on;
    xyInt = zeros(2,3);
    for idx = 1:length(AW.Plot)
        % Get each wire(s)'  x-, y-coordinates.
        xyAW	= AW.Plot(idx).getPosition'; % Conform to EF coordinates.
        
        % Compute intersection x-, y-coodinates.
        xyInt(:,idx)	= InterX(xyEF, xyAW);
        
        FI.Plot(idx)	= plot(xyInt(1,idx), xyInt(2,idx),...
             'tag', ['Int.', ' #', num2str(idx)],...
             'color', 'm', 'marker', 'x', 'markersize', 10, 'linewidth', 2);
    end
    
    % Compute result - distances between the wires along the fracture line.
    ratio = computePinSpreadRatio(xyEF', xyInt');
    printToLog(gcf, ['Computed Pin Spread Ratio: ~', num2str(ratio)], 'Note');
    
    % Output.
    data	= updateResults(data, fieldNames, iFI, FI);
    success = true;
end


