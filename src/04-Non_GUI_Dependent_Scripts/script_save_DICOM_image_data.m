%% 0. Script: Saves DICOM Image Data to Specified Folder.
% Get original dicoms.
directoryName   = uigetdir(mfilename('fullpath'), 'Select folder with original DICOMS.');

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

%% 1. Save All Dicoms in Specified Directory As PNGs.
% Get folder names of all cases in DICOM directory.
d	= dir(directoryName);
folderNames	= {d(3:end).name}';

% Prep waitbar.
nIter   = length(folderNames);
if waitbarOn
    nFiles  = 0;
    for idx = 1:nIter
        fileNames	= getFiles(fullfile(directoryName, folderNames{idx}));
        nFiles  = nFiles + length(fileNames);
    end
    wb	= waitbar(0, ['Folder 1: ''', folderNames{1}, ''' (0% complete)...']);
end

% Iterate through each folder in directory, creating analog folder of images.
iFile   = 1;
success = cell(nIter, 1);
for idx = 1:nIter
    if waitbarOn
        str = ['Folder ', num2str(idx), ': ''', folderNames{idx},...
                ''' (', num2str(round((iFile/nFiles)*100)), '% complete)...'];
        waitbar(iFile/nFiles, wb, str);
    end
    
    % Get all filenames of dicoms in directory.
    fileNames	= getFiles(fullfile(directoryName, folderNames{idx}));
    iremove     = strcmpi(fileNames, 'test') |...
        contains(cellfun(@lower, fileNames, 'uniformoutput', 0), 'results');
    fileNames(iremove)	= [];
    
    % Create folder in saveDirectoryName if it does not exist already.
    saveFolderName  = fullfile(saveDirectoryName, folderNames{idx});
    if ~exist(saveFolderName, 'dir')
        mkdir(saveDirectoryName, folderNames{idx});
    end
    
    % Create cell array of DICOM Names.
    if isempty(fileNames)
        continue
    end
    imgNames	= strcat(fullfile(repmat({directoryName},...
         length(fileNames), 1), folderNames{idx}, fileNames));
    
    % Save images.
    success{idx}	= DICOM2Img(imgNames, saveFolderName, imgType);
    if waitbarOn
        nDicoms = length(fileNames);
        for jdx = 1:nDicoms
            str = ['Folder ', num2str(idx), ': ''', folderNames{idx},...
                ''' (', num2str(round((iFile/nFiles)*100)), '% complete)...'];
            waitbar(iFile/nFiles, wb, str);
            iFile   = iFile + 1;
            pause(.05);
            if idx == nIter && iFile < nFiles
                for kdx = 1:nFiles-iFile
                    prcnt	= round((iFile/nFiles)*100);
                    if prcnt >= 100
                        kdx = (nFiles-iFile); %#ok<FXSET>
                    end
                    str = ['Folder ', num2str(idx), ': ''', folderNames{idx},...
                        ''' (', num2str(round((iFile/nFiles)*100)), '% complete)...'];
                    waitbar(iFile/nFiles, wb, str);
                    iFile   = iFile + 1;
                    pause(.005);
                end
            end
        end
    end
end

% Notify user; delete waitbar.
mb = msgbox('Writing of DICOMs as images: Complete!');
if waitbarOn
    waitbar(iFile/nFiles, wb, str);
    waitfor(mb);
    delete(wb);
end

