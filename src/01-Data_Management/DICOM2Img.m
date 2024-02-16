function success = DICOM2Img(dicomNames, saveDirectoryName, imgType)
%DICOM2IMG Extracts and writes DICOM image data as an image file.
%   success = DICOM2IMG(dicomNames) converts the image data of the DICOM
%   file(s) into .jpg(s); img is an Nx1 cell array of images corresponding
%   to each file in DICOMNames, which itself must be a cell array. Image
%   resolution isforced to uint8.
%
%   success = DICOM2IMG(dicomNames, saveDirectoryName) saves images to the
%   specified path. Without this input, images save to their inputted path.
%
%   success = DICOM2IMG(dicomNames, saveDirectoryName, imgType) specifies
%   the image type. DICOM2IMGv currently only accomodates .png and .tif;
%   note that imgType must be a string of all caps corresponding to the
%   "summary of supported image types" in help imwrite.
%   
%   See also DEIDENTIFYDICOM.
%==========================================================================

% Check input.
if ~iscell(dicomNames)
    error('DICOMNames input must be a cell array of characters or strings');
end
if nargin == 1
    saveDirectoryName = dicomNames;
end
if ~iscell(saveDirectoryName)
    saveDirectoryName = repmat({saveDirectoryName}, length(dicomNames), 1);
end
if nargin == 2
    imgType	= 'PNG';
end
if strcmp(imgType, 'JPEG')
    imgExt  = '.jpg';
    error('cant do jpgs right now because I cant figure out how to write them with the correct bit depth');
    
else
    imgExt  = strcat('.', lower(imgType));
end

% Initialize output.
nImages	= length(dicomNames);
success = false(size(dicomNames));

% Iterate through each DICOM, converting to an image file and then saving.
for idx = 1:nImages
    % Get image data.
    [pathName, fileName]	= fileparts(dicomNames{idx});
    dicom	= fullfile(pathName, fileName);
    [img, map]	= dicomread(dicom);
    
    % Convert to writable pixel data (might be hardcoded for 16-bit tiff).
    if (isa(img, 'uint16'))
        img = img.*(65535/max(img(:)));
        
    elseif (any(img(:) < 0))
        img = im2uint16(img);
    end
    
%     % Convert so that output is 8 bits.
%     min_img	= min(img(:));
%     img = double(img - min_img)./double(max(img(:)) - min_img);
    
    % Write image file.
    newFileName	= strcat(fullfile(saveDirectoryName{idx}, fileName), imgExt);
    try
        switch lower(imgType)
            case {'.png', 'png'}
                imwrite(img, newFileName, imgType);
                
            case {'.jpg', '.jpeg', 'jpg', 'jpeg'}
                metaData    = dicominfo(dicom);
                bd	= metaData.BitDepth;
%                 if bd == 16
%                     bd = 12;
%                 end
                try
                    imwrite(img, map, newFileName, imgType, 'bitdepth', bd, 'mode', 'lossless');
                catch
                    imwrite(img, newFileName, imgType, 'bitdepth', bd, 'mode', 'lossless');
                end
            case {'.tiff', '.tif', 'tiff', 'tif'}
                try
                    imwrite(img, map, newFileName, imgType);
                catch
                    imwrite(img, newFileName, imgType);
                end
            otherwise
                error('Image output type not supported; must be JPEG, PNG, or TIFF');
        end
        success(idx)    = true;
        
    catch
        success(idx)    = false;
    end
end

