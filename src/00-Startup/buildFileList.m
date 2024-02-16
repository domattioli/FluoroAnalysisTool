function [fileNames, success] = buildFileList( fh, pathName )
%BUILDFILELIST Creates list of files to display in box.
%
%   See also FLUORODICOM_GUI/FILELIST_CALLBACK
%==========================================================================

% Get all files in directory, remove niche outputs of dir function.
fileNames = getFiles( pathName, '.dcm' );

% Check if director is valid.
if isempty( fileNames )
    % No dicoms found, check for images.
    count = 0;
    imgTypes = { '.tif', '.jpg', '.png' };
    while count < length( imgTypes ) && isempty( fileNames )
        count	= count + 1;
        fileNames	= getFiles( pathName, imgTypes{ count } );
        if ~isempty( fileNames )
            fileNames	= strcat( fileNames, imgTypes{ count } );
            break
        end
    end
    if ~isempty( fileNames )
        convertQ	= questdlg( ['No DICOMs found in folder, but ',...
            num2str( length( fileNames ) ), ' ', imgTypes{ count },...
            ' images were found; Convert these to DICOMS?'], 'DICOM Convert' );
    else
        convertQ    = 'No';
    end
    if strcmp( 'Yes', convertQ )
        endDir	= uigetdir( pathName, 'Select folder to save the DICOM files to' );
        [success, dcm]	= img2DICOM( fileNames, pathName, endDir );
        fileNames   = getFiles( endDir, '.dcm' );
        
    else
        fileNames   = [];
    end
    
    if isempty( fileNames )
        success	= false;
        fileNames	= 'No .dcm files in directory';
        return
        
    else
        success	= true;
    end
else
    success	= true;
end

% Populate list of files in selected directory.
charAppendedToTop   = char( 'No file selected' );
differenceInSizes	= length( charAppendedToTop ) - size( fileNames, 2 );
if differenceInSizes == 0
    fileNames	= [charAppendedToTop; fileNames];
    
else
    try                                             % Append spaces to equalize cols.
        fileNames	= [charAppendedToTop; fileNames];
    catch
       printToLog( fh, 'Must select folder containing DICOM Files', 'Error' );% Never happens? Revist this (first look: 12/19/18).
       return
    end
end

% Temp fix for situation when we convert images to dicoms and need to
% change the pathname on the outside of this function.
if exist( 'endDir', 'var' )
    if ~strcmpi( pathName, endDir )
        fileNames	= fullfile( endDir, fileNames );
    end
end

