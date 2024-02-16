% Get files.
AHRQdata	= 'C:\Users\dmattioli\OneDrive - University of Iowa\AHRQ\data\Pediatric_Elbow';
imdir = uigetdir(AHRQdata);
cd(imdir);
folder = dir;
fileNames = {folder.name};
fileNames(1:2) = [];
% fileNames(end-2:end) = [];

% Set working path.
projectFolderName = 'FluoroProcessingTool';
cdStr   = 'C:\Users\dmattioli\OneDrive - University of Iowa\AHRQ\FluoroProcessingTool';
pathStr = cdStr(1:strfind(cdStr,projectFolderName)+length(projectFolderName)-1);
addpath(genpath(pathStr));

% View images in folder.
figure;
for idx = 1:length(fileNames)
    fluoro	= fluoroProcess(fullfile(imdir,fileNames{idx}));
    ax	= gca;  imshow(fluoro.image,'parent',ax);
%     newI	= fluoro.histeq(fluoro.image,ax);
%     imshow(newI,'parent',ax);
    imshow(fluoro.image,'parent',ax);
    
    pause
    cla;
end
