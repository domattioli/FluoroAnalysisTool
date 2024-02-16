function out = estimateWireWidth(fh, data, wireObj)

% Get wire attributes and approximate it as a line a of best fit.
pos = [wireObj.get('XData')', wireObj.get('YData')'];
mW	= wireObj.get('UserData').Slope;
bW	= wireObj.get('UserData').yIntercept;
angleOfWire = abs(atand(mW));                    	% Angle of inclination.

% Equalize histogram of fluoro in I irrespective of surrounding black.
I   = data.get('Image');
newI	= fluoroProcess.histeq(I, wireObj.get('parent'));

% Create box around wire to mask the irrelevant data.
N	= 25;                                           % Mask beyond N pix on either side of line.
pmb = [ceil(bW+N); floor(bW-N)];
boxXY	= [pos(1,1) mW*pos(1,1)+pmb(1);...
    pos(1,1) mW*pos(1,1)+pmb(end);...
    pos(2,1) mW*pos(2,1)+pmb(end);...
    pos(2,1) mW*pos(2,1)+pmb(1)];
mask	= roipoly(newI,boxXY(:,1),boxXY(:,2));

% Create slightly smaller box so we can ignore artificial edges.
N2	= floor(N*.90);
pmb2	= [ceil(bW+N2); floor(bW-N2)];
box2XY	= [pos(1,1) mW*pos(1,1) + pmb2(1); pos(1,1) mW*pos(1,1) + pmb2(end);...
    pos(2,1) mW*pos(2,1) + pmb2(end); pos(2,1) mW*pos(2,1) + pmb2(1)];
mask2	= roipoly(newI, box2XY(:,1), box2XY(:,2));

% Create mask.
newIBW = newI;
newIBW(~mask)    = false;
newIBW = imbinarize(newIBW);

% Compute edges of masked image.
edgeI	= edge(newIBW,'canny');
edgeI(~mask2)	= false;                         	% Remove noise from 1st box
edgeI(1:size(edgeI,2),[(box2XY(1,1)-1):(box2XY(1,1)+1);...
    (box2XY(3,1)-1):(box2XY(3,1)+1)])   = false;    % Perp. boundary lines.

% Inpolygon the pixels on either side of the wire.
[y,x] = find(edgeI);
wireSidePoly = {[pos(1,:); boxXY(2,:); boxXY(3,:); pos(2,:)],...
    [pos(1,:); boxXY(1,:); boxXY(4,:); pos(2,:)]};
clusterXY	= cell(2,1);
for idx = 1:2
    IN	= inpolygon(x,y,wireSidePoly{idx}(:,1),wireSidePoly{idx}(:,2));
    clusterXY{idx} = [x(IN),y(IN)];
end

% Fit lines to clustered data points.
angleOfCluster	= zeros(2,1);
fittedXY    = cell(2,1);
for idx = 1:2
    % Find equation of line, compute new approximate coordinates.
    cxy	= clusterXY{idx};
    coeff	= polyfit(cxy(:,1),cxy(:,2),1);
    fittedXY{idx}(:,1)   = linspace(pos(1,1), pos(2,1), 100);
    fittedXY{idx}(:,2)   = polyval(coeff, fittedXY{idx}(:,1));
    
    % Compute angle of inclination.
    angleOfCluster(idx) = abs(atand(coeff(1)));
end

% Select cluster w angle nearest to wire angle.
[~,idetectedEdge]	= min(abs(angleOfWire - angleOfCluster));
detectedEdgeXY  = fittedXY{idetectedEdge};

% Define perpendicular bisectors of wire's & detectedEdgeXY endpoints.
xLim = get(gca,'xlim');
mWPB	= -1/mW;
bWPB	= [pos(1,2) - mWPB*pos(1,1); pos(2,2) - mWPB*pos(2,1)];
wirePBXY	= cellfun(@transpose, {[xLim; mWPB.*xLim + bWPB(1)],...
    [xLim; mWPB.*xLim + bWPB(2)]}, 'UniformOutput',false);
mDE	= diff(detectedEdgeXY([1 end],2))/diff(detectedEdgeXY([1 end],1));
mDEPB	= -(1/mDE);
bDEPB	= detectedEdgeXY([1 end],2) - mDEPB*detectedEdgeXY([1 end],1);
detectedEdgePBXY	= cellfun(@transpose, {[xLim; mDEPB.*xLim + bDEPB(1)],...
    [xLim; mDEPB.*xLim + bDEPB(2)]}, 'UniformOutput',false);

% Find intersection pts along wire, detected edge wrt each's perp. bisect.
intersectionPoints  = cell(2,2);
intersectionPoints{1,1}     = InterX(pos(1:2,:)',detectedEdgePBXY{1}')';
intersectionPoints{1,2}     = InterX(pos(1:2,:)',detectedEdgePBXY{2}')';
intersectionPoints{2,1}     = InterX(detectedEdgeXY([1 end],:)',wirePBXY{1}')';
intersectionPoints{2,2}     = InterX(detectedEdgeXY([1 end],:)',wirePBXY{2}')';

% Truncate wire and detectedEdge for better comparison.
if ~isempty(intersectionPoints{1,1}) && isempty(intersectionPoints{1,2})
    truncatedWireXY	= [intersectionPoints{1,1}; pos(2,:)];
    
elseif isempty(intersectionPoints{1,1}) && ~isempty(intersectionPoints{1,2})
    truncatedWireXY	= [pos(1,:); intersectionPoints{1,2}];
    
else
    printToLog(fh,'Could not fully detect wire due to image quality (likely a result of contrasts)','Error')
    out = [];return
end
if ~isempty(intersectionPoints{2,1}) && isempty(intersectionPoints{2,2})
    truncatedEdgeXY	= [intersectionPoints{2,1}; detectedEdgeXY(end,:)];
    
elseif isempty(intersectionPoints{2,1}) && ~isempty(intersectionPoints{2,2})
    truncatedEdgeXY	= [detectedEdgeXY(1,:); intersectionPoints{2,1}];
    
else
    printToLog(fh,'Could not fully detect wire due to image quality (likely a result of contrasts)','Error')
    out = [];return
end

% Compute avg distance between the two lines.
D   = sqrt((truncatedEdgeXY(:,2)-truncatedWireXY(:,2)).^2 +...
        (truncatedEdgeXY(:,1)-truncatedWireXY(:,1)).^2);
out = 2*mean(D);
end

function otherstuff
%% Generic Data Clustering Algorithm.
% Cluster the pixels defining the edges into 2 clusters.
[y,x] = find(edgeI);
ixy	= clusterdata([x y],'maxclust',2);
clusterXY   = {[x(ixy==1), y(ixy==1)], [x(ixy==2), y(ixy==2)]};

%% Can try filtering image.
% Adjust rgb data, then smooth so that edges are more easily detectable.
adjI	= imgaussfilt(imadjust(I,[0.0 0.5]),2);

%% Hough Stuff.
% Compute Stand. Hough Transf., find lines within range of possible angles.
[HTM,Theta,rhosOfTheta]	= hough(edgeI,'Theta',range_angleOfWire);
% pxWidthOfWire	= ceil(data.operations.WireWidth*data.pxPerMM);
peaksHTM	= houghpeaks(HTM,2,'threshold',0.5*max(HTM(:)))
linesHTM	= houghlines(edgeI,Theta,rhosOfTheta,peaksHTM,'minlength',0.1*lengthOfWire)

% Ensure xy of lines correspond to wire markers.
xy = [linesHTM(1:2).point1; linesHTM(1:2).point2];
figure;subplot(2,2,1);imshowpair(I,mask);subplot(2,2,2);imshow(newIBW);
subplot(2,1,2);imshowpair(newI,edgeI,'montage');
figure;imshow(HTM,[],'XData',Theta,'YData',rhosOfTheta,'initialmagnification','fit');
axis on, axis normal, hold on;
xlabel('theta');ylabel('rho');
figure;
subplot(1,2,1);imshow(edgeI);
subplot(1,2,2);imshow(I); hold on;
for idx = 1:length(linesHTM)
    xy = [linesHTM(idx).point1; linesHTM(idx).point2];
    plot(xy(:,1),xy(:,2),'linewidth',2,'color','g');
    plot(xy(1,1),xy(1,2),'x','linewidth',2,'color','y');
    plot(xy(2,1),xy(2,2),'x','linewidth',2,'color','r');
end

%% Custom hough line detection.
% Identify angle with brightest bands.
sHTM    = sum(HTM,1);
[brightest,ibrightest] = max(sHTM)

% Compute angle of wire.
wTheta = abs(atand(m));
wThetaRange	= floor(wTheta)-1:ceil(wTheta);

% Given known range of theta, find 2 strongest parallel lines in that range.
nLines  = 10;
nAngles = length(wThetaRange);
maxRhosInEachTheta   = zeros(nLines*2,nAngles);
for idx	= 1:nAngles
    [maxRhosInEachTheta(1:nLines,idx),maxRhosInEachTheta(nLines+1:nLines*2,idx)]...
        = maxk(HTM(:,wThetaRange(idx)),nLines);
end

% Find distances between each pair of lines for each angle.
dists	= zeros(nLines,nLines,nAngles);
for idx = 1:nAngles
    data	= repmat(maxRhosInEachTheta(nLines+1:end,idx),1,nLines);
    dists(:,:,idx)	= abs(data-data');
end
dists(dists == 0)   = NaN;

% Compute average distance between pairs for each angle.
estPxOfWire = floor(mean(reshape(permute(nanmean(dists,1),[2 1 3]),[],1)))
end
