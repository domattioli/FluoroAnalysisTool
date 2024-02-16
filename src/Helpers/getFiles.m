function fileNames = getFiles( pathName, extension )
%GETFILES Retrieves file namess of specific extension.
%   fileNames = GETFILES(pathName, extension) uses the 'dir' function with
%   a wildcard specifying a file extension to return a cell array of file
%   names as character strings.
%   
%   Extension must be a string, beginning with '.', e.g. '.txt'. Omission 
%   of 'extension' input is the same as dir(pathName).
%   
%   See also
%==========================================================================

% Get all files in directory, remove niche outputs of dir function.
if nargin == 1
    extension = '*';
else
    extension = strcat( '*', extension );
end
D   = dir( fullfile( pathName, extension ) );
D   = D( ~ismember( { D.name }, { '.', '..' } ) );
[~, fileNames] 	= cellfun( @fileparts, { D( : ).name }, 'uniformoutput', 0 );
fileNames   = fileNames';

