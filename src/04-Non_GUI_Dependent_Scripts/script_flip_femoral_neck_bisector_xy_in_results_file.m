%% Correct Andrew's Femoral Neck Issue.
% Add AHRQ source code to path.
addpath(genpath(...
    uigetdir('OneDrive - University of Iowa', 'Select FluoroAnalysisTool folder to add to MATLAB path.')));

% Get 'Results' file and pathname.
[pathName, resultsFileName]	= fileparts(uigetdir('D:\', 'Select DICOM Results Folder.'));
folderName	= fullfile(pathName, resultsFileName);
directory   = dir(folderName);
directory([1:2, end])	= [];
fileNames   = {directory(:).name}';

% Retrieve results.
resultsFileName     = fullfile(folderName, 'Results.json');
results	= retrieveResults(resultsFileName);

% Save directory.
if ~exist(fullfile(pathName, 'Images'), 'dir')
    mkdir(fullfile(pathName, 'Images'))
end
saveDirectory   = fullfile(pathName, 'Images');

%% Invert Femoral Neck Bisector
figure; hold on;
for idx = 1:length(results)
    % Get relevant data.
    data	= results(idx).Geometry;
    
    % Femoral head xy data.
    femoralHead	= data.Femoral_Head;
    femoralHeadXY	= generateFemoralHeadEllipse(femoralHead);
    
    % Femoral neck xy data.
    femoralNeckBisectorXY	= [data.Femoral_Neck.Bisector_X1Y1,...
        data.Femoral_Neck.Bisector_X2Y2]';
    femoralNeckBisectorM	= diff(femoralNeckBisectorXY(:,2))/...
        diff(femoralNeckBisectorXY(:,1));
    femoralNeckBisectorB    = femoralNeckBisectorXY(1,2) -...
        femoralNeckBisectorXY(1,1)*femoralNeckBisectorM;
    
    % Compute intersection coordinates.
    xval	= linspace(min(femoralHeadXY(:,1)), max(femoralHeadXY(:,1)), 1000);
    yval    = xval.*femoralNeckBisectorM + femoralNeckBisectorB;
    intersectionXY	= InterX([xval; yval], femoralHeadXY')';
    
    % Determine point to inflect about.
    iInflection     = ~ismember(floor(femoralNeckBisectorXY), floor(intersectionXY), 'rows');
    iIntersection   = ~ismember(floor(intersectionXY), floor(femoralNeckBisectorXY), 'rows');
    new_femoralNeckBisectorXY = [femoralNeckBisectorXY(iInflection,:);...
        intersectionXY(iIntersection,:)];
    
    % Compute femoral neck coordinates.
    % Find a linear EQ for the perpendicular bisector of the labeled fem. neck.
    xlim= get(gca,'XLim');
    femoralNeckM	= -1/femoralNeckBisectorM;
    xy  = femoralNeckBisectorXY(iInflection,:);
    femoralNeckB	= xy(1,2) - femoralNeckM*xy(:,1);
    yval    = xval*femoralNeckM + femoralNeckB;
    femoralNeckXY   = InterX([xval; yval], femoralHeadXY')';
    
    % Plot image data and annotations, save, remove from axis.
    imshow(fullfile(folderName, fileNames{idx}));   axis equal;
    hold on; plot(femoralHeadXY(:,1), femoralHeadXY(:,2), 'c-');
    hold on; plot(femoralHead.Center_XY(1), femoralHead.Center_XY(2), 'go','markerfacecolor','g');
    hold on; plot(femoralHead.Left_XY(1), femoralHead.Left_XY(2), 'ro','markerfacecolor','r');
    hold on; plot(femoralHead.Top_XY(1), femoralHead.Top_XY(2), 'bo','markerfacecolor','b');
    hold on; plot(femoralNeckBisectorXY(:,1), femoralNeckBisectorXY(:,2), 'm.-');
    hold on; plot(femoralNeckXY(:,1), femoralNeckXY(:,2), 'm.');
    hold on; plot(femoralNeckXY(:,1), femoralNeckXY(:,2), 'm--');
    hold on; plot(new_femoralNeckBisectorXY(:,1), new_femoralNeckBisectorXY(:,2), 'y*-');
    img	= frame2im(getframe(gca));
    imwrite(img, strcat(fullfile(saveDirectory, num2str(idx)), '.png'));
    pause
    a = gca; delete(a.Children(1:end-1));
    
    % Update data.
    data.Femoral_Neck.X1Y1	= femoralNeckXY(2,:);
    data.Femoral_Neck.X2Y2	= femoralNeckXY(2,:);
    data.Femoral_Neck.Bisector_X1Y1 = new_femoralNeckBisectorXY(2,:);
    data.Femoral_Neck.Bisector_X2Y2	= new_femoralNeckBisectorXY(2,:);
end
