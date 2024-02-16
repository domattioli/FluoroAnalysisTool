function wireWidthObject    = defineWireWidth(h)

% Initialize plotted line object.
wireWidthObject    = struct('Plot',line([NaN; NaN],[NaN; NaN],'tag','Width Of Wire',...
    'parent',h.MainAxis,...
    'color','g','linewidth',1,...
    'linestyle','-','marker','>',...
    'markerfacecolor','g','markersize',3.5));

% % Draw line.
% l	= imline(h.MainAxis);
% pos = wait(l);
% wireWidthObject.Plot.XData = pos(:,1);
% wireWidthObject.Plot.YData = pos(:,2);
% delete(l);

bw = edge(h.Figure.UserData.Image);
figure;imshow(bw);

% Get wire-slope
h.Figure.UserData.Procedure.Data.WireSlope.Plot