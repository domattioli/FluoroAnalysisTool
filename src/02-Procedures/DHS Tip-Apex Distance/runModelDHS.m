function [result, status] = runModelDHS(imgDir, thresh, imgType)
%RUNDHSMODEL Pre-processing step to compute object locations for all images.
%   [result, status] = RUNDHSMODEL(imgDir, thresh, imgType) returns 0 if
%   the DHS neural net models are successfully loaded.
%   
%   See also
%==========================================================================

% Get file name of model.
nnModelsDirName     = 'Neural_Net_Models';
p	= strsplit(path, ';');
pathNames	= p(contains(p, nnModelsDirName));
nnModelsPathName	= pathNames{~contains(pathNames, strcat(nnModelsDirName, filesep))};
fullFileName   = fullfile(nnModelsPathName, 'WireDetection.h5');

% Using system call instead of matlab-python integration functionality.
[result, status]	= python('loadAndRunNNmodel.py',...
    fullFileName, imgDir, char(thresh), imgType);

