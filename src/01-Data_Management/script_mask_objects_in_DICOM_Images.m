%% 0. Script: Saves DICOM Image Data to Specified Folder.
% Get original dicoms.
directoryName   = uigetdir(mfilename('fullpath'), 'Select folder of DICOMS.');

% Specify Save Directory.
saveDirectoryName   = uigetdir(fullfile(directoryName,'..'), 'Select folder to save DICOM image files.');

% Adjust path.
if contains(pwd, 'AHRQ')
    p	= pwd;
    iAHRQ	= strfind(p, 'AHRQ');
    addpath(genpath(p(1:iAHRQ+3)));
end

if saveDirectoryName > 0
    imgType	= questdlg('What image type?', 'Image Type Selection', 'TIFF', 'PNG', 'JPG', 'TIFF');
end

% Waitbar?
waitbarOn	= true;

% DHS has 559 images, pshf has only 200. need 359 more.

%% 1. Iterate Through Surgeries in Folder and Their Fluoros, Masking Objects,...
%% ...Saving to Corresponding Folder Name in Specified Directory.

% Get names of folders that we're iterating through.
surgeryFolders = dir(directoryName);
surgeryFolderNames = {surgeryFolders(3:end).name}';
nSurgeries  = length(surgeryFolderNames);
saveFolderNames	= cell(nSurgeries, 1);
for idx = 1:nSurgeries-1
    % Check if there are duplicates of this surgery; erase them from list.
    surgeryID = surgeryFolderNames{idx};
    if isempty(surgeryID)
        continue
    end
    iDuplicate = contains(surgeryFolderNames, surgeryID(1:3));
    iDuplicate(idx)	= false;
    surgeryFolderNames(iDuplicate) = repmat({''}, length(find(iDuplicate)), 1);
    
    % If no duplicates, add surgeryID to an array of saveFolderNames.
    saveFolderNames(find(cellfun(@isempty, saveFolderNames), 1, 'first'), 1) = {surgeryID(1:3)};
end

% Prep.
idx = 1;
needNum = 359;
count = 0;

fh  = figure;
a = gca;
imshow('D:\OG_Fluoros\Pediatric_Elbow\DICOM\2_Wires\003A\3301987.dcm'); % Just prep the axis.
fh.set('WindowState', 'maximized');

%% 2. Iterate (constructing this as while loops so I can quit and restart).
while idx <= nSurgeries
    surgeryID = surgeryFolderNames{idx};
    if isempty(surgeryID)
        idx = idx + 1;
        continue
    else
        surgeryID = fullfile(directoryName, surgeryID);
    end
    
    % Itereate through DICOMS of surgery.
    surgeryIDdir = dir(surgeryID);
    dicomNames = fullfile(surgeryID, {surgeryIDdir(3:end).name}');
    nDicoms = length(dicomNames);
    jdx = 1;
    while jdx <= nDicoms
        % Plot dicom.
        dicomFileName = dicomNames{jdx};
        dicom = dicomread(dicomFileName);
        a.Children.set('CData', dicom);
        
        % Get name for saving image; adjust title appropriately.
        [~, maskFileName] = fileparts(dicomFileName);
        title(['Surgery: ', surgeryFolderNames{idx}, ', Img: ',...
            maskFileName, '; # Remaining: ', num2str(needNum-count)]);
        
        % Mask the wire.
        try
            % If user clicks 'escape' then don't save an image.
            H = impoly(gca);
            bw = createMask(H);
            pos = wait(H);
            delete(H);
            
        catch
            delete(findobj(a.Children, 'tag', 'impoly'));
            pos = [];
        end
        
        % Names for saved files.
        xTrainFolderName = fullfile(saveDirectoryName, 'xTrain');
        yTrainFolderName = fullfile(saveDirectoryName, 'yTrain');
        pngName = strcat(fullfile(xTrainFolderName, surgeryFolderNames{idx}(1:3),...
            maskFileName), '.', lower(imgType));
        maskName = strrep(pngName, 'xTrain', 'yTrain');
        if ~exist(fileparts(pngName), 'dir')
            mkdir(fileparts(pngName))
        end
        if ~exist(fileparts(maskName), 'dir')
            mkdir(fileparts(maskName))
        end
        
        % Save original image and mask as pngs in xtrain and ytrain, resp.
        if ~isempty(pos)
            imwrite(dicom, pngName, 'png');
            imwrite(bw, maskName, 'png');
            count = count + 1
        end
        jdx = jdx + 1
    end
    idx = idx + 1
end

