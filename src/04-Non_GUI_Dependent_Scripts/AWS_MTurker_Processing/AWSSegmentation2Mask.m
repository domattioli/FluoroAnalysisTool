function [BW, conBW, sens, specs, dsc] = AWSSegmentation2Mask( varargin )
%AWSSEGMENTATION2MASK Convert AWS formatted semantic segmentations to masks
%   BW = AWSSEGMENTATION2MASK( data, Procedure ) returns a binary mask from
%   each MTurker's semantic segmentation for this case. BW is an Nx1 cell
%   array of logicals, where N is the number of turkers in the data.
%   imgSize is assumed to be 966x966.
%   
%   All this function does is parse the json formatted data for the
%   so-called 'pngImageData' field and then converts that utf-8 data into
%   a MATLAB readable image.
%   
%   Information on the encoded, packaged json data:
%   https://docs.aws.amazon.com/sagemaker/latest/dg/sms-ui-template-crowd-semantic-segmentation.html
%   
%   Information on the consolidation algorithm, STAPLE:
%   https://ieeexplore.ieee.org/document/1309714
%   
%   See also STAPLE.
%==========================================================================

p = inputParser;
p.addRequired( 'mainData', @( x ) isstruct( x ) );
p.addParameter( 'imgSize', [966, 966], @(x) ismatrix( x ) );
p.addParameter( 'thresh', 0.90, @(x) ( x > 0.0 ) && isnumeric( x ) && ( x < 1.0 ) );
p.parse( varargin{ : } );
narginchk( 1, -1 + 2*numel( p.Parameters ) );
nargoutchk( 0, 5 );

% Folder for temporarily writing encoded image data to be re-read.
addpath( genpath( pwd ) );
try
    tempFolderName = fullfile( sourceCodeDirectory(), 'data', 'temp' );
catch
    tempFolderName = pwd;
end

% Read all data, temporarily write as image, store in output.
nTurkers    = length( p.Results.mainData );
BW  = cell( nTurkers, 1 );
unrolledBW  = NaN( prod( p.Results.imgSize ), nTurkers );
for idx = 1:nTurkers
    d   = p.Results.mainData( idx ).answerContent.crowd_semantic_segmentation.labeledImage.pngImageData;
    raw = matlab.net.base64decode( d );
    tempImageName	= fullfile( tempFolderName, 'tempImage.png' );
    fid = fopen( tempImageName, 'wb' );
    fwrite( fid, raw, 'uint8' );
    fclose( fid );
    BW{ idx }	= logical( imread( tempImageName ) );
    unrolledBW( :, idx ) = BW{ idx }( : );
end

% Consolidate masks, determine which masks do not meet input threshold.
[W, sens, specs]	= STAPLE( unrolledBW );
sens    = reshape( sens, nTurkers, 1 ); % Sensitivity is the true positive fraction (relative frequency of Dec == 1 when Truth == 1).
specs	= reshape( specs, nTurkers, 1 );% Sensitivity is the true negative fraction (relative frequency of Dec == 0 when Truth == 0).
conBW   = reshape( W >= .99, p.Results.imgSize );
dsc = NaN( nTurkers, 1 );
for idx = 1:nTurkers
    dsc( idx ) = dice( conBW, BW{ idx } );
end

% Delete temporary image.
delete( tempImageName );

