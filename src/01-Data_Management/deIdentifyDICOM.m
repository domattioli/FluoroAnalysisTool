function success = deIdentifyDICOM(dicomNames, saveDirectoryName)
%DEIDENTIFYDICOM Overwrites sensative DICOM data in original files.
%   success = DEIDENTIFYDICOM(dicomNames) returns an Nx1 boolean vector
%   corresponding to each dicome file in dicomNames and wheher it was
%   successfully de-identified. De-identification occurs by overwriting the
%   'PatientName' field in the original metadata. dicomNames must be a cell
%   array containing the full path names of each dicom file.
%   DEIDENTIFYDICOM does not assume a file extension, e.g. 'path/file.dcm'.
%   
%   success = DEIDENTIFYDICOM(dicomNames, saveDirectoryName) saves the
%   de-identified .dcm file to a new address, as opposed to overwriting the
%   original file given by the full path in each dicomNames, where the
%   saveDirectoryName is either a 1xM char array (M being the length of the
%   string), or a N-lengthed cell array of 1xM char corresponding to
%   dicomNames.
%   
%   **DEIDENTIFYDICOM without the second input argument will permanently
%   overwrite the original file!**
%   
%   See also DICOM2IMG.
%==========================================================================

% Parse input -- need to write error exceptions for second argument.
if nargin == 1
    saveDirectoryName = dicomNames;
end
if ~iscell(saveDirectoryName)
    saveDirectoryName = repmat({saveDirectoryName}, length(dicomNames), 1);
end

% Initialize output.
nDicoms	= length(dicomNames);
success = false(size(dicomNames));

% Iterate through each DICOM, overwriting sensative data.
newPatientNameInfo = struct('FamilyName', [], 'GivenName',[], 'MiddleName', []);
for idx = 1:nDicoms
    % Original DICOM data.
    [pathName, fileName]   = fileparts(dicomNames{idx});
    DICOM	= fullfile(pathName, fileName);
    imgData = dicomread(DICOM);
    try
        metaData	= dicominfo(DICOM);
    catch
        % Filename is probably wrong.
        continue
    end
    % De-Identify by overwriting pertinent meta fields.
    metaData.PatientName    = newPatientNameInfo;
    newFileName	= strcat(fullfile(saveDirectoryName{idx}, fileName), '.dcm');
    
    % Write new dicomfile.
    try
        dicomwrite(imgData, newFileName, metaData, 'CreateMode', 'Copy');
        success(idx)    = true;
    catch
        success(idx)    = false;
    end
end



