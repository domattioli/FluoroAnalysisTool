function femoralNeckObject  = defineFemoralNeck(fh, hObject, femoralHead, chosenSide)
%DEFINEFEMORALNECK Creates imline for the femoral neck.
%	femoralNeckObject = DEFINEFEMORALNECK(fh, hObject, femoralHead,
%   chosenSide) returns a struct femoralNeckObject containing the line
%   objects overlayed to the position of a UIControl imline object for the
%   femoral neck and its consequent perpendicular bisector.
%	
%   Note: DEFINEFEMORALNECK waits until the user has double-clicked the
%	object before returning an output.
%   
%   See also FEMORALNECKPERPENDICULARBISECTORXY, FLIPBISECTOR,
%   DEFINEFEMORALHEAD, DEFINEWIRESLOPE, REMOVEFEMORALNECK, BUILDINTERFACEDHS.
%==========================================================================

% Initialize plotted line object.
mainAxis    = fh.get('CurrentAxes');
femoralNeckObject	= struct('Plot',...
    line(NaN(2,1), NaN(2,1),...
    'tag', hObject.get('Tag'),...
    'parent', mainAxis,...
    'linewidth', 1, 'linestyle', '-', 'color', 'm',...
    'markerfacecolor', 'm', 'marker', 'o', 'markersize', 2.5),...
    'Bisector',...
    line(NaN(2,1), NaN(2,1),...
    'tag', [hObject.get('Tag'), ' Bisector'],...
    'parent', mainAxis,...
    'linewidth',1, 'linestyle', '-', 'color','m',...
    'markerfacecolor', 'm', 'marker', 'o','markersize', 2.5));

% Create line that is constrained by the points of the femoral head ellipse.
xyPX	= [];                                        	% Points of intersection.
while isempty(xyPX) || numel(xyPX) ~= 4
    % Select two points along the head-ellipse that are adequetly spaced
    % apart and lie with respect to the left/right side of hip.
    xyEllipse	= vertcat(femoralHead.get('XData'), femoralHead.get('YData'));
    if chosenSide(1) == 'L'
        % Select points closer to the right limit of the axis.
        [~, iminy]	= max(xyEllipse(1,:));
        [~, imaxx]	= max(xyEllipse(2,:));
        iPoints	= xyEllipse(:, [iminy,imaxx])';
    else
        % Select points closer to the left limit of the axis.
        [~, iminy]	= max(xyEllipse(2,:));
        [~, iminx]	= min(xyEllipse(1,:));
        iPoints	= xyEllipse(:,[iminy, iminx])';
    end
    
    % Draw a green line constrained by points given from the head-ellipse.
    [minXY, maxXY]	= bounds(xyEllipse, 2);
    L	= imline(mainAxis, iPoints);
    L.setColor('m');
    L.setPositionConstraintFcn(makeConstrainToRectFcn('imline',...
        [minXY(1) maxXY(1)],[minXY(2) maxXY(2)]));
    posL	= L.wait;               % [x1 y1; x2 y2]
    while ~isvalid(L)
        L	= imline(mainAxis);
        L.setColor('m');
        L.setPositionConstraintFcn(makeConstrainToRectFcn('imline',...
            [minXY(1) maxXY(1)],[minXY(2) maxXY(2)]));
        posL	= L.wait;           % [x1 y1; x2 y2]
    end
    posL	= posL';             	% [x1 x2; y1 y2]
    
    % Assume that the user wants the geometry of the current line.
    mL	= diff(posL(2,:))/diff(posL(1,:));
    bL	= posL(2,1) - mL*posL(1,1);
    newX	= mainAxis.get('XLim');
    newY	= newX.*mL + bL;
    xyL	= vertcat(newX, newY);     	% [x1 x2; y1 y2]
    
    % Find the points of intersection of the line and the ellipse.
    xyPX	= InterX(xyL, xyEllipse);
    if size(xyPX, 2) > 2
        % No idea why this happens.
        [~,ixyPX]   = unique(floor(xyPX)', 'rows');
        xyPX    = xyPX(:, ixyPX);
    end
    delete(L);
end

% Plot the points of intersection and find, plot the perpendicular bisector.
mPX	= diff(xyPX(2,:))/diff(xyPX(1,:));
xyPB	= femoralNeckPerpendicularBisectorXY(xyPX, mPX, xyEllipse, chosenSide);
femoralNeckObject.Plot.set('XData', xyPX(1,:), 'YData', xyPX(2,:));
femoralNeckObject.Bisector.set('XData', xyPB(1,:), 'YData', xyPB(2,:));
drawnow;

