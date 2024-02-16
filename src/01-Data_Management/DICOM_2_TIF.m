%% Script Description.
%--------------------------This may be a depreciated script (09-27-19); see
%'script_save_DICOM_image_data.m'------------------------------------------
%%% Section summary:
% Read in DICOM image files from a directory, view those images in-sequence
% within a continuous figure window, then save the image sequence as .tif
% files in a new folder located within the same original directory.
%%% MATLAB Documentation inspiration (link).
% Read DICOM files:
% https://www.mathworks.com/help/images/ref/dicomread.html
% Labeling images
% https://www.mathworks.com/help/vision/ug/define-ground-truth-for-image-collections.html

%% Read DICOM Image Files.
% Select directory; manually select dir, manually type dir, or use predefined dir.
clearvars;	close all;	clc;
% dirName	= uigetdir;                         	% UI file selection.
% dirName	= '';                               	% Manual string entry.
dirName	= 'Z:\DHS_Automation_Project\TestCases_DICOM_Files';

% folderName  = '0578105';
% folderName  = '04201875';
folderName  = '38191305';

pathName    = [dirName,'\',folderName];
fileName    = dir(pathName);

% Read DICOM image file(s) data.
startIdx= 4;                                        % First image at 4th index.
nDICOM  = length({fileName.name});
X   = cell(nDICOM,1);                               % DICOM data.
cmap    = X;                                        % Colormap of images.
alpha   = X;                                        % Alpha channel matrix for X.
overlays= X;                                        % Overlays from DICOMS.
for idx = startIdx:nDICOM
    [X{idx},cmap{idx},alpha{idx},overlays{idx}] =...
        dicomread([pathName,'\',fileName(idx).name]);
end

%% View Image Sequence.
figure; hold on;
for idx = startIdx:nDICOM
    imshow(X{idx});
    if idx == 4; pause; end
    pause(.3);
end
pause; close;

%% Save Image Sequence As .tif Files.
% Select directory for saving image files as .tifs.
% savePathName = uigetdir;                         	% UI file selection.
% savePathName = '';                               	% Manual string entry.
savePathName = 'Z:\DHS_Automation_Project\TestCases_DICOM2TIF_Files';
newFolderName   = ['Z:\DHS_Automation_Project\TestCases_DICOM2TIF_Files','\',folderName];

% Create folder for image files, if it does not already exist.
if exist(newFolderName,'file') == 7                 % Folder exists.
    % Do not make new folder.
elseif exist(newFolderName,'file') == 0             % Folde does not exist.
    mkdir('Z:\DHS_Automation_Project\TestCases_DICOM2TIF_Files',['\',folderName]);
end

% Write images to .tif files.
for idx = startIdx:nDICOM
    % Check for file extension in fileName.
    if strcmp(fileName(idx).name(end-3),'.') == 1
        saveFileName = [savePathName,'\',folderName,'\',fileName(idx).name(1:end-4),'.tif'];
    else
        saveFileName = [savePathName,'\',folderName,'\',fileName(idx).name,'.tif'];
    end
    imwrite(X{idx},saveFileName);
end


