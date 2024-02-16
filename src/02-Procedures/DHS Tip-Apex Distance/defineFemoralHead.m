function femoralHeadObject	= defineFemoralHead(fh, hObject)
%DEFINEFEMORALHEAD Creates imellipse for circumscribing the femoral head.
%	femoralHeadObject = DEFINEFEMORALHEAD(fh, hObject) returns the plot
%	object overlayed to the position of a UIControl imellipse object for
%	the femoral head.
%	
%   Note: DEFINEFEMORALHEAD waits until the user has double-clicked the
%	object before returning an output.
%   
%   See also DEFINEFEMORALNECK, DEFINEWIRESLOPE, REMOVEFEMORALHEAD,
%   BUILDINTERFACEDHS.
%==========================================================================

% Initialize plotted ellipse (line) object.
mainAxis    = fh.get('CurrentAxes');
femoralHeadObject   = struct('Plot',...
    line(NaN(2,1), NaN(2,1),...
    'tag', hObject.get('Tag'),...
    'parent', mainAxis,...
    'linewidth', 2, 'linestyle', '-', 'color', 'c'),...
    'MinInfo',...
    struct('Center_XY', NaN(1,2), 'Left_XY', NaN(1,2), 'Top_XY', NaN(1,2)));

% Draw ellipse.
e	= imellipse(mainAxis);
pos = wait(e);
while ~isvalid(e)
    e	= imellipse(mainAxis);
    pos = wait(e);
end
hold on;
femoralHeadObject.Plot.XData    = pos(:,1);
femoralHeadObject.Plot.YData    = pos(:,2);
hold off;
delete(e);                                          % Overlay imroi.

% Compute minimum necessary information.
[~,ileftPt]	= min(pos(:,1));
[~,itopPt]	= max(pos(:,2));
femoralHeadObject.MinInfo.Left_XY	= pos(ileftPt,:);
femoralHeadObject.MinInfo.Top_XY	= pos(itopPt,:);
femoralHeadObject.MinInfo.Center_XY	= horzcat(pos(itopPt,1), pos(ileftPt,2));

