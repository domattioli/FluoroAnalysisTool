function wireSlopeObject  = defineWireSlope(fh, hObject, data)
%DEFINEWIRESLOPE Creates imline for approximating the wire slope.
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

% If a prediction is available, plot it as an imroi.
mainAxis	= fh.get('CurrentAxes' );
wireObj	= predictWireSlope( fh, data );

% Prompt user to accept prediction or not.
if ~all( isnan( mask(:) ) )
    acceptPred  = questdlg( 'Is this prediction acceptable?',...
        'Judge Prediction', 'Yes', 'No', 'Cancel', 'Yes' );
end

% Compute avg wire width and approximate with a line if user accepts,
% otherwise, have user draw it.

wireSlopeObject = struct( 'Plot', [], 'Width', [] );
if strcmp( acceptPred, 'Yes' )
    printToLog( fh, 'Prediction accepted', 'Success' );
    
    % Build output from prediction.
    wirePlot.set( 'Tag', hObject.get( 'Tag' ),...
        'XData', horzcat( wirePlot.get( 'XData' ), NaN ),...
        'YData', horzcat( wirePlot.get( 'YData' ), NaN ),...
        'LineStyle', '--', 'LineWidth', 1, 'Marker', 'o', 'MarkerSize', 5 );
    wireSlopeObject.Plot	= wirePlot;
    delete( maskPlot );
    
    % Compute width of wire.
    wireSlopeObject.Width   = computeAverageWireWidth( mask ); 
    
else
    printToLog( fh, 'Prediction not accepted', 'Success' );
    a = gca;
    delete( a.Children( 1:2 ) );
    
    % Draw line manually.
    printToLog( fh, ['Method: (Manually) Define ''', hObject.get( 'Tag' ), ''''], 'Progress' );
    printToLog( fh, ['Drag points of line (from entry-point to end) to',...
        'define the wire''s slope; Double-click to complete'], 'Note' );
    wireSlopeObject.Plot	= drawLine( mainAxis, 'tagname',...
        hObject.get( 'Tag' ), 'color', 'r', 'lineStyle', '--',...
        'linewidth', 1, 'marker', 'o', 'markersize', 5 );
    
    % Draw width of wire.
    printToLog( fh, ['Drag points of line to define the wire width;',...
        ' Double-click to complete'], 'Note' );
    wireWidth   = drawLine( mainAxis, 'color', 'r', 'lineStyle', '-',...
        'linewidth', 1, 'marker', '.', 'markersize', 5 );
    wireSlopeObject.Width   = sqrt( diff( wireWidth.XData( 1 : 2 ) )^2 +...
        diff( wireWidth.YData( 1 : 2 ) )^2 );
    delete( wireWidth );
end
printToLog( fh, ['Estimated wire width: ',...
    num2str( wireSlopeObject.Width ), ' px'], 'Note' );

