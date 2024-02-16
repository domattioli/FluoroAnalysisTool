% Script for Importing and Parsing AWS Sagemaker MTurk Data, then convert
% for use in other script

%%% User Entry %%%
defaultThresh   = 0.90;

% Path stuff.
addpath( genpath( pwd ) );

% Read in data.
[fileName, pathName]	= uigetfile( '*.*', 'Select JSON-formatted text file of MTurk Data' );
if fileName == 0
    errordlg( 'Cannot proceed without selecting a valid text file', 'Ending MTurk Processing' );
end
textData	= importdata( fullfile( pathName, fileName ) );
if length( textData ) > 1
    warndlg( 'This script is currently coded to assume only 1 line of JSON-formatted data.', 'Multiple lines in text file' );
end
try
    jsonData    = jsondecode( textData{ 1 } ); % This assumes only 1 line in text file.
catch
    errordlg( 'Could not perform a JSON decoding - Make sure that the text file follows JSON format', 'JSON Decode Failure' );
end
data    = jsonData.answers;

% Prompt user for parsing procedure.
parsingProcedure	= questdlg( 'Which MTurk Data?', 'Parsing Procedure',...
    'Polygons', 'Segmentations', 'Other', 'Segmentations' );

% Prompt user for input image dimensions.
imageDimensions	= inputdlg( { '# Rows:', '# Cols:' }, 'Input Image Dim.', [1, 10], { '966', '966' } );
S	= transpose( cellfun( @str2num, imageDimensions ) );

% Prompt user for minimum accuracy threshold.
maskThresh	= inputdlg( 'Thresh:', 'Accuracy Threshold', [1, 10], { num2str( defaultThresh ) } );
if isempty( maskThresh )
    T	= defaultThresh;
else
    T	= str2double( maskThresh );
end


%% Run procedure.
switch parsingProcedure
    case 'Polygons'
        
    case 'Segmentations'
         [BW, conBW, p, q, DSC]	= AWSSegmentation2Mask( data, 'imgSize', S, 'thresh', T );
         tbl	= array2table( [p, q, DSC], 'VariableNames', {'p', 'q', 'DSC'}, 'RowNames', {'Turker 1', 'Turker 2', 'Turker 3'} );
         disp( tbl );
         
    otherwise
        errordlg( 'Haven''t coded for this output data from MTurk, yet', 'Invalid data' );
        
end
