function fid = writeResult( fh, saveFullFileName, TEXT )
%WRITERESULT Write .json text to results.json text file.
%   fid = writeResult( fh, saveFullFileName, TEXT ) returns the file
%   identifier fid, the values of which correspond to classic file MATLAB.
%   interaction.
%   
%   See also FOPEN, FWRITE, FLUORO/SAVE.
%==========================================================================

% Get figure handles and fluoro data.
[~, ~, fhHandles]	= getFluoroData( fh );

% Write new data to Results.json file; create one if doesn't already exist.
fileList	= findobj( fhHandles.Load_Foreground, 'Tag', 'File List' );
numFiles	= size( fileList.get( 'String' ), 1 )-1;
[d, fileName, ext]   = fileparts( saveFullFileName );
saveDir	= dir( d );
existingData    = cell( numFiles, 1 );
if any( ismember( { saveDir.name }', strcat( fileName, ext ) ) )
    % Read in all existing data.
    fid	= fopen( saveFullFileName, 'r' );
    for idx = 1:numFiles
        existingData{ idx }	= fgetl( fid );
    end
    fclose( fid );
    
    % Overwrite current file's line.
    currentFile	= fileList.get( 'Value' ) - 1;
    fid	= fopen( saveFullFileName, 'r+t' );
    for idx = 1:numFiles
        if idx == currentFile
            fprintf( fid, '%s\n', TEXT );
        else
            fprintf( fid, '%s\n', existingData{ idx } );
        end
    end
    
else
    % File does not exist; initialize one wrt all DICOMS in folder.
    fid	= fopen( saveFullFileName, 'wt' );
    for idx = 1:numFiles
        if idx == fileList.get('Value' ) - 1
            fprintf( fid, '%s\n', TEXT );
            
        else
            fprintf( fid, '\n' );
        end
    end
end
fclose( fid );


