
close all; clear all; clc;
d = '/Users/dominik/OneDrive - University of Iowa/AHRQ_POSNA/Publications/Fluoro_Analysis_Tool';
%d = 'C:\Users\dmattioli\OneDrive - University of Iowa\Academic\Publications\01-Fluoro_Analysis_Tool';
p   = fullfile( d, 'data');
fn = fullfile( p, 'Experiment_Matrix_2.xlsx' );
imgfn = fullfile( d, 'doc','Figures', '11541797.tiff' );
cd( d );
addpath( genpath( d ) );

[num, txt, raw] = xlsread( fn );
headers = txt( 1, : );
software = txt( 2:end, 1 );
iFAST	= contains( software, 'FAST' );
iOSI	= contains( software, 'OSIRIX' );
experience  = txt( 2:end, 2 );
iNov	= contains( experience, 'Novice' );
iExp	= contains( experience, 'Expert' );
iNovFAST	= iFAST & iNov;
iExpFAST	= iFAST & iExp;
iNovOSI = iOSI & iNov; % empty
iExpOSI = iOSI & iExp; % Not needed.
name    = txt( 2:end, 3 );
view	= {'1 - AP', '2 - AP', '3 - AP', '4 - AP', '5 - AP', '6 - AP', '7 - AP',...
    '8 - AP', '9 - L', '10 - L', '11 - L', '12 - L', '13 - L', '14 - AP', '15 - AP',...
    '16 - AP', '17 - AP', '18 - L', '19 - L', '20 - L', '21 - L', '22 - AP'};
dcm	= num( :, 1 );
imgNum	= num( :, 3 );
% numImages	= nanmax( imgNum ) - nanmin( imgNum );
numImages   = 22;
xTA	= num( :, 4 );
yTA	= num( :, 5 );
xWT	= num( :, 6 );
yWT	= num( :, 7 );
timeTotal	= num( :, 8 );
pxTAD	= num( :, 9 );
WW	= num( :, 10 );
ratio	= num( :, 12 );
mmTAD	= num( :, 12 );
nnxWT	= num( :, 13 );
nnyWT	= num( :, 14 );
nnpxTAD	= num( :, 15 );
nnWW	= num( :, 16 );
nnRatio = num( :, 17 );
nnmmTAD	= num( :, 18 );
timeOSI	= num( :, 19 );
timeExcel	= num( :, 20 );


%% Wire Width.
mean_WWFAST	= nanmean( reshape( nnWW( iNovFAST ), numImages, [] ), 2 );
mean_WWFASTTrue = [7.6, 6.5, 7.4, mean_WWFAST( 4 ), 7.9, 8.2, 7.1, 8.6, 9.2, 9.4, 9.9, 10.0, 10.3, 8.3, 7.6, 7.7, 8.1, 10.0, 10.2, 10.1, 10.2, 8.5]';
mean_NovOSI	= nanmean( reshape( WW( iNovOSI ), numImages, [] ), 2 );
mean_ExpOSI	= nanmean( reshape( WW( iExpOSI ), numImages, [] ), 2 );


%% Tip-Apex Px & MM.
pxTADNovFAST	= reshape( pxTAD( iNovFAST ), numImages, [] );
pxTADExpFAST	= reshape( pxTAD( iExpFAST ), numImages, [] );
pxTADNovOSI	= reshape( pxTAD( iNovOSI ), numImages, [] );
pxTADExpOSI	= reshape( pxTAD( iExpOSI ), numImages, [] );

mean_pxTADNovFAST	= nanmean( pxTADNovFAST, 2 );
mean_pxTADExpFAST	= nanmean( pxTADExpFAST, 2 );
mean_pxTADNovOSI	= nanmean( pxTADNovOSI, 2 );
mean_pxTADExpOSI	= nanmean( pxTADExpOSI, 2 );

mmTADNovFAST	= pxTADNovFAST .* ( 3.2 ./ mean_WWFAST );
mmTADExpFAST	= pxTADExpFAST .* ( 3.2 ./ mean_WWFAST );
mmTADNovOSI	= pxTADNovOSI .* ( 3.2 ./ mean_NovOSI );
mmTADExpOSI	= pxTADExpOSI .* ( 3.2 ./ mean_ExpOSI );

mean_mmTADNovFAST	= nanmean( mmTADNovFAST, 2 );
mean_mmTADExpFAST	= nanmean( mmTADExpFAST, 2 );
mean_mmTADNovOSI	= nanmean( mmTADNovOSI, 2 );
mean_mmTADExpOSI	= nanmean( mmTADExpOSI, 2 );

mmTADNovFASTTrue	= pxTADNovFAST .* ( 3.2 ./ mean_WWFASTTrue );
mmTADExpFASTTrue	= pxTADExpFAST .* ( 3.2 ./ mean_WWFASTTrue );

mean_mmTADNovFASTTrue	= nanmean( mmTADNovFASTTrue, 2 );
mean_mmTADExpFASTTrue	= nanmean( mmTADExpFASTTrue, 2 );


%% Time Data.
timeFAST    = reshape( timeTotal( iFAST ), numImages, [] );
timeOSI	= reshape( timeTotal( iOSI ), numImages, [] );
timeNov	= reshape( timeTotal( iNov ), numImages, [] );
timeExp	= reshape( timeTotal( iExp ), numImages, [] );
timeNovFAST	= reshape( timeTotal( iNovFAST ), numImages, [] );
timeExpFAST	= reshape( timeTotal( iExpFAST ), numImages, [] );
timeNovOSI	= reshape( timeTotal( iNovOSI ), numImages, [] );
timeExpOSI	= reshape( timeTotal( iExpOSI ), numImages, [] );

cumtimeFAST	= cumsum( timeFAST );
cumtimeOSI	= cumsum( timeOSI );
cumtimeNov	= cumsum( timeNov );
cumtimeExp	= cumsum( timeExp );
cumtimeNovFAST	= cumsum( timeNovFAST );
cumtimeExpFAST	= cumsum( timeExpFAST );
cumtimeNovOSI	= cumsum( timeNovOSI );
cumtimeExpOSI	= cumsum( timeExpOSI );

mean_timeFAST   = nanmean( cumtimeFAST, 2 );
mean_timeOSI	= nanmean( cumtimeOSI, 2 );
mean_timeNov	= nanmean( cumtimeNov, 2 );
mean_timeExp	= nanmean( cumtimeExp, 2 );
mean_timeNovFAST	= nanmean( cumtimeNovFAST, 2 );
mean_timeExpFAST	= nanmean( cumtimeExpFAST, 2 );
mean_timeNovOSI	= nanmean( cumtimeNovOSI, 2 );
mean_timeExpOSI	= nanmean( cumtimeExpOSI, 2 );


%% Wire-Tip
% X-Y-coordinates of all groups, reshaped according to user.
ixWT	= contains( headers, 'WT X' );
iyWT	= contains( headers, 'WT Y' );
xWTall   = reshape( xWT, numImages, [] );
yWTall   = reshape( yWT, numImages, [] );
xWTFAST	= reshape( xWT( iFAST ), numImages, [] );
yWTFAST	= reshape( yWT( iFAST ), numImages, [] );
xWTOSI	= reshape( xWT( iOSI ), numImages, [] );
yWTOSI	= reshape( yWT( iOSI ), numImages, [] );
xWTNov  = reshape( xWT( iNov ), numImages, [] );
yWTNov  = reshape( yWT( iNov ), numImages, [] );
xWTNovFAST	= reshape( xWT( iNovFAST ), numImages, [] );
yWTNovFAST	= reshape( yWT( iNovFAST ), numImages, [] );
xWTNovOSI	= reshape( xWT( iNovOSI ), numImages, [] );
yWTNovOSI	= reshape( yWT( iNovOSI ), numImages, [] );
xWTExp  = reshape( xWT( iExp ), numImages, [] );
yWTExp  = reshape( yWT( iExp ), numImages, [] );
xWTExpFAST	= reshape( xWT( iExpFAST ), numImages, [] );
yWTExpFAST	= reshape( yWT( iExpFAST ), numImages, [] );
xWTExpOSI	= reshape( xWT( iExpOSI ), numImages, [] );
yWTExpOSI	= reshape( yWT( iExpOSI ), numImages, [] );

% Group median coordinates by image.
mean_xyWTFAST	= horzcat( nanmean( xWTFAST, 2 ), nanmean( yWTFAST, 2 ) );
mean_xyWTOSI	= horzcat( nanmean( xWTOSI, 2 ), nanmean( yWTOSI, 2 ) );
mean_xyWTNov	= horzcat( nanmean( xWTNov, 2 ), nanmean( yWTNov, 2 ) );
mean_xyWTNovFAST	= horzcat( nanmean( xWTNovFAST, 2 ), nanmean( yWTNovFAST, 2 ) );
mean_xyWTNovOSI	= horzcat( nanmean( xWTNovOSI, 2 ), nanmean( yWTNovOSI, 2 ) );
mean_xyWTExp	= horzcat( nanmean( xWTExp, 2 ), nanmean( yWTExp, 2 ) );
mean_xyWTExpFAST	= horzcat( nanmean( xWTExpFAST, 2 ), nanmean( yWTExpFAST, 2 ) );
mean_xyWTExpOSI	= horzcat( nanmean( xWTExpOSI, 2 ), nanmean( yWTExpOSI, 2 ) );

% Zero groups' midpoints with respect to osirix experts.
zeroed_xWTFAST	= xWTFAST - mean_xyWTExpOSI( :, 1 );
zeroed_yWTFAST	= yWTFAST - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTFAST_mean	= mean_xyWTFAST - mean_xyWTExpOSI ;
zeroed_xWTOSI	= xWTOSI - mean_xyWTExpOSI( :, 1 );
zeroed_yWTOSI	= yWTOSI - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTOSI_mean	= mean_xyWTOSI - mean_xyWTExpOSI;
zeroed_xWTNovFAST	= xWTNovFAST - mean_xyWTExpOSI( :, 1 );
zeroed_yWTNovFAST	= yWTNovFAST - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTNovFAST_mean	= mean_xyWTNovFAST - mean_xyWTExpOSI;
zeroed_xWTNovOSI	= xWTNovOSI - mean_xyWTExpOSI( :, 1 );
zeroed_yWTNovOSI	= yWTNovOSI - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTNovOSI_mean	= mean_xyWTNovOSI - mean_xyWTExpOSI;
zeroed_xWTExpFAST	= xWTExpFAST - mean_xyWTExpOSI( :, 1 );
zeroed_yWTExpFAST	= yWTExpFAST - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTExpFAST_mean	= mean_xyWTExpFAST - mean_xyWTExpOSI;
zeroed_xWTExpOSI	= xWTExpOSI - mean_xyWTExpOSI( :, 1 );
zeroed_yWTExpOSI	= yWTExpOSI - mean_xyWTExpOSI( :, 2 );
zeroed_xyWTExpOSI_mean	= mean_xyWTExpOSI - mean_xyWTExpOSI;

% Shift the zeroed groups' midpoints to the Tip-Apex of the final image.
xyWTTruth_LastImg	= mean_xyWTExpOSI( end, : );
shifted_xWTFAST	= zeroed_xWTFAST + xyWTTruth_LastImg( 1 );
shifted_yWTFAST	= zeroed_yWTFAST + xyWTTruth_LastImg( 2 );
shifted_xyWTFAST_mean	= zeroed_xyWTFAST_mean + xyWTTruth_LastImg;
shifted_xWTOSI	= zeroed_xWTOSI + xyWTTruth_LastImg( 1 );
shifted_yWTOSI	= zeroed_yWTOSI + xyWTTruth_LastImg( 2 );
shifted_xyWTOSI_mean	= zeroed_xyWTOSI_mean + xyWTTruth_LastImg;
shifted_xWTNovFAST	= zeroed_xWTNovFAST + xyWTTruth_LastImg( 1 );
shifted_yWTNovFAST	= zeroed_yWTNovFAST + xyWTTruth_LastImg( 2 );
shifted_xyWTNovFAST_mean	= zeroed_xyWTNovFAST_mean + xyWTTruth_LastImg;
shifted_xWTNovOSI	= zeroed_xWTNovOSI + xyWTTruth_LastImg( 1 );
shifted_yWTNovOSI	= zeroed_yWTNovOSI + xyWTTruth_LastImg( 2 );
shifted_xyWTNovOSI_mean	= zeroed_xyWTNovOSI_mean + xyWTTruth_LastImg;
shifted_xWTExpFAST	= zeroed_xWTExpFAST + xyWTTruth_LastImg( 1 );
shifted_yWTExpFAST	= zeroed_yWTExpFAST + xyWTTruth_LastImg( 2 );
shifted_xyWTExpFAST_mean	= zeroed_xyWTExpFAST_mean + xyWTTruth_LastImg;
shifted_xWTExpOSI	= zeroed_xWTExpOSI + xyWTTruth_LastImg( 1 );
shifted_yWTExpOSI	= zeroed_yWTExpOSI + xyWTTruth_LastImg( 2 );
shifted_xyWTExpOSI_mean	= zeroed_xyWTExpOSI_mean + xyWTTruth_LastImg;

% Distance of groups from a generic tip-apex.
d_WTNovFAST	= sqrt( ( shifted_xWTNovFAST( : ) - xyWTTruth_LastImg( 1 ) ) .^ 2 + ( shifted_yWTNovFAST( : ) - xyWTTruth_LastImg( 2 ) ) .^ 2 );
d_WTExpFAST	= sqrt( ( shifted_xWTExpFAST( : ) - xyWTTruth_LastImg( 1 ) ) .^ 2 + ( shifted_yWTExpFAST( : ) - xyWTTruth_LastImg( 2 ) ) .^ 2 );
d_WTNovOSI	= sqrt( ( shifted_xWTNovOSI( : ) - xyWTTruth_LastImg( 1 ) ) .^ 2 + ( shifted_yWTNovOSI( : ) - xyWTTruth_LastImg( 2 ) ) .^ 2 );
d_WTExpOSI	= sqrt( ( shifted_xWTExpOSI( : ) - xyWTTruth_LastImg( 1 ) ) .^ 2 + ( shifted_yWTExpOSI( : ) - xyWTTruth_LastImg( 2 ) ) .^ 2 );
r_WTNovFAST	= nanmean( d_WTNovFAST) + nanstd( d_WTNovFAST );
r_WTExpFAST	= nanmean( d_WTExpFAST) + nanstd( d_WTExpFAST );
r_WTNovOSI	= nanmean( d_WTNovOSI) + nanstd( d_WTNovOSI );
r_WTExpOSI	= nanmean( d_WTExpOSI) + nanstd( d_WTExpOSI );

% Print a table showing error results.
TWT	= table( basicStats( d_WTNovFAST ), basicStats( d_WTExpFAST ), basicStats( d_WTNovOSI ), basicStats( d_WTExpOSI ),...
    'VariableNames', { 'FAST_Novice', 'FAST_Expert', 'OSIRIX_Novice', 'OSIRIX_Expert' },...
    'RowNames', { 'Median', 'Mean', 'StdDev.', 'Min.', 'Max.', 'H_0', 'P' } );
disp( TWT );

% Get polar coordinates.
xyWire  = horzcat( 317, 179 );
wire_tip_offset  = abs( xyWire - xyWTTruth_LastImg );
[thetaWTNovFAT, rhoWTNovFAT]	= cart2pol( xWTNovFAST - mean_xyWTExpOSI( :, 1 ) + wire_tip_offset( 1 ),...
    ( ( yWTNovFAST - mean_xyWTExpOSI( :, 2 ) ) * -1 ) + wire_tip_offset( 2 ) );
[thetaWTExpFAT, rhoWTExpFAT]	= cart2pol( xWTExpFAST - mean_xyWTExpOSI( :, 1 ) + wire_tip_offset( 1 ),...
    ( ( yWTExpFAST - mean_xyWTExpOSI( :, 2 ) ) * -1 ) + wire_tip_offset( 2 ) );
[thetaWTNovOSI, rhoWTNovOSI]	= cart2pol( xWTNovOSI - mean_xyWTExpOSI( :, 1 ) + wire_tip_offset( 1 ),...
    ( ( yWTNovOSI - mean_xyWTExpOSI( :, 2 ) ) * -1 ) + wire_tip_offset( 2 ) );
[thetaWTExpOSI, rhoWTExpOSI]	= cart2pol( xWTExpOSI - mean_xyWTExpOSI( :, 1 ) + wire_tip_offset( 1 ),...
    ( ( yWTExpOSI - mean_xyWTExpOSI( :, 2 ) ) * -1 ) + wire_tip_offset( 2 ) );

% Convert stats of theta and rho into polar line plots.
npts = 25;
thetaWTNovFASTStats	= basicStats( thetaWTNovFAT );
rhoWTNovFASTStats	= basicStats( rhoWTNovFAT );
WTpxtnf = linspace( thetaWTNovFASTStats( 2 ) - thetaWTNovFASTStats( 3 ), thetaWTNovFASTStats( 2 ) + thetaWTNovFASTStats( 3 ), npts );
WTpytnf = repmat( rhoWTNovFASTStats( 2 ), 1, npts );
WTpyrnf = linspace( rhoWTNovFASTStats( 2 ) - rhoWTNovFASTStats( 3 ), rhoWTNovFASTStats( 2 ) + rhoWTNovFASTStats( 3 ), npts );
WTpxrnf = repmat( thetaWTNovFASTStats( 2 ), 1, npts );
thetaWTExpFASTStats	= basicStats( thetaWTExpFAT );
rhoWTExpFASTStats	= basicStats( rhoWTExpFAT );
WTpxtef = linspace( thetaWTExpFASTStats( 2 ) - thetaWTExpFASTStats( 3 ), thetaWTExpFASTStats( 2 ) + thetaWTExpFASTStats( 3 ), npts );
WTpytef = repmat( rhoWTExpFASTStats( 2 ), 1, npts );
WTpyref = linspace( rhoWTExpFASTStats( 2 ) - rhoWTExpFASTStats( 3 ), rhoWTExpFASTStats( 2 ) + rhoWTExpFASTStats( 3 ), npts );
WTpxref = repmat( thetaWTExpFASTStats( 2 ), 1, npts );
thetaWTNovOSIStats	= basicStats( thetaWTNovOSI );
rhoWTNovOSIStats	= basicStats( rhoWTNovOSI );
WTpxtno	= linspace( thetaWTNovOSIStats( 2 ) - thetaWTNovOSIStats( 3 ), thetaWTNovOSIStats( 2 ) + thetaWTNovOSIStats( 3 ), npts );
WTpytno = repmat( rhoWTNovOSIStats( 2 ), 1, npts );
WTpyrno = linspace( rhoWTNovOSIStats( 2 ) - rhoWTNovOSIStats( 3 ), rhoWTNovOSIStats( 2 ) + rhoWTNovOSIStats( 3 ), npts );
WTpxrno = repmat( thetaWTNovOSIStats( 2 ), 1, npts );
thetaWTExpOSIStats	= basicStats( thetaWTExpOSI );
rhoWTExpOSIStats	= basicStats( rhoWTExpOSI );
WTpxteo	= linspace( thetaWTExpOSIStats( 2 ) - thetaWTExpOSIStats( 3 ), thetaWTExpOSIStats( 2 ) + thetaWTExpOSIStats( 3 ), npts );
WTpyteo = repmat( rhoWTExpOSIStats( 2 ), 1, npts );
WTpyreo = linspace( rhoWTExpOSIStats( 2 ) - rhoWTExpOSIStats( 3 ), rhoWTExpOSIStats( 2 ) + rhoWTExpOSIStats( 3 ), npts );
WTpxreo = repmat( thetaWTExpOSIStats( 2 ), 1, npts );

% Map polar coordinate data back to image coordinates.
[x, y] = pol2cart( WTpxtnf, WTpytnf );
WTcxtnf = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcytnf = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxrnf, WTpyrnf );
WTcxrnf = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcyrnf = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxtef, WTpytef );
WTcxtef = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcytef = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxref, WTpyref );
WTcxref = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcyref = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxtno, WTpytno );
WTcxtno = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcytno = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxreo, WTpyreo );
WTcxrno = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcyrno = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxteo, WTpyteo );
WTcxteo = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcyteo = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );
[x, y] = pol2cart( WTpxreo, WTpyreo );
WTcxreo = x + xyWTTruth_LastImg( 1 ) - wire_tip_offset( 1 );
WTcyreo = ( y - xyWTTruth_LastImg( 2 ) ) * -1 + wire_tip_offset( 2 );


%% Tip-Apex
% X-Y-coordinates of all groups, reshaped according to user.
ixTA	= contains( headers, 'TA X' );
iyTA	= contains( headers, 'TA Y' );
xTAall   = reshape( xTA, numImages, [] );
yTAall   = reshape( yTA, numImages, [] );
xTAFAST	= reshape( xTA( iFAST ), numImages, [] );
yTAFAST	= reshape( yTA( iFAST ), numImages, [] );
xTAOSI	= reshape( xTA( iOSI ), numImages, [] );
yTAOSI	= reshape( yTA( iOSI ), numImages, [] );
xTANov  = reshape( xTA( iNov ), numImages, [] );
yTANov  = reshape( yTA( iNov ), numImages, [] );
xTANovFAST	= reshape( xTA( iNovFAST ), numImages, [] );
yTANovFAST	= reshape( yTA( iNovFAST ), numImages, [] );
xTANovOSI	= reshape( xTA( iNovOSI ), numImages, [] );
yTANovOSI	= reshape( yTA( iNovOSI ), numImages, [] );
xTAExp  = reshape( xTA( iExp ), numImages, [] );
yTAExp  = reshape( yTA( iExp ), numImages, [] );
xTAExpFAST	= reshape( xTA( iExpFAST ), numImages, [] );
yTAExpFAST	= reshape( yTA( iExpFAST ), numImages, [] );
xTAExpOSI	= reshape( xTA( iExpOSI ), numImages, [] );
yTAExpOSI	= reshape( yTA( iExpOSI ), numImages, [] );

% Group median coordinates by image.
mean_xyTAFAST	= horzcat( nanmean( xTAFAST, 2 ), nanmean( yTAFAST, 2 ) );
mean_xyTAOSI	= horzcat( nanmean( xTAOSI, 2 ), nanmean( yTAOSI, 2 ) );
mean_xyTANov	= horzcat( nanmean( xTANov, 2 ), nanmean( yTANov, 2 ) );
mean_xyTANovFAST	= horzcat( nanmean( xTANovFAST, 2 ), nanmean( yTANovFAST, 2 ) );
mean_xyTANovOSI	= horzcat( nanmean( xTANovOSI, 2 ), nanmean( yTANovOSI, 2 ) );
mean_xyTAExp	= horzcat( nanmean( xTAExp, 2 ), nanmean( yTAExp, 2 ) );
mean_xyTAExpFAST	= horzcat( nanmean( xTAExpFAST, 2 ), nanmean( yTAExpFAST, 2 ) );
mean_xyTAExpOSI	= horzcat( nanmean( xTAExpOSI, 2 ), nanmean( yTAExpOSI, 2 ) );

% Zero groups' midpoints with respect to osirix experts.
zeroed_xTAFAST	= xTAFAST - mean_xyTAExpOSI( :, 1 );
zeroed_yTAFAST	= yTAFAST - mean_xyTAExpOSI( :, 2 );
zeroed_xyTAFAST_mean	= mean_xyTAFAST - mean_xyTAExpOSI ;
zeroed_xTAOSI	= xTAOSI - mean_xyTAExpOSI( :, 1 );
zeroed_yTAOSI	= yTAOSI - mean_xyTAExpOSI( :, 2 );
zeroed_xyTAOSI_mean	= mean_xyTAOSI - mean_xyTAExpOSI;
zeroed_xTANovFAST	= xTANovFAST - mean_xyTAExpOSI( :, 1 );
zeroed_yTANovFAST	= yTANovFAST - mean_xyTAExpOSI( :, 2 );
zeroed_xyTANovFAST_mean	= mean_xyTANovFAST - mean_xyTAExpOSI;
zeroed_xTANovOSI	= xTANovOSI - mean_xyTAExpOSI( :, 1 );
zeroed_yTANovOSI	= yTANovOSI - mean_xyTAExpOSI( :, 2 );
zeroed_xyTANovOSI_mean	= mean_xyTANovOSI - mean_xyTAExpOSI;
zeroed_xTAExpFAST	= xTAExpFAST - mean_xyTAExpOSI( :, 1 );
zeroed_yTAExpFAST	= yTAExpFAST - mean_xyTAExpOSI( :, 2 );
zeroed_xyTAExpFAST_mean	= mean_xyTAExpFAST - mean_xyTAExpOSI;
zeroed_xTAExpOSI	= xTAExpOSI - mean_xyTAExpOSI( :, 1 );
zeroed_yTAExpOSI	= yTAExpOSI - mean_xyTAExpOSI( :, 2 );
zeroed_xyTAExpOSI_mean	= mean_xyTAExpOSI - mean_xyTAExpOSI;

% Shift the zeroed groups' midpoints to the Tip-Apex of the final image.
xyTATruth_LastImg	= mean_xyTAExpOSI( end, : );
shifted_xTAFAST	= zeroed_xTAFAST + xyTATruth_LastImg( 1 );
shifted_yTAFAST	= zeroed_yTAFAST + xyTATruth_LastImg( 2 );
shifted_xyTAFAST_mean	= zeroed_xyTAFAST_mean + xyTATruth_LastImg;
shifted_xTAOSI	= zeroed_xTAOSI + xyTATruth_LastImg( 1 );
shifted_yTAOSI	= zeroed_yTAOSI + xyTATruth_LastImg( 2 );
shifted_xyTAOSI_mean	= zeroed_xyTAOSI_mean + xyTATruth_LastImg;
shifted_xTANovFAST	= zeroed_xTANovFAST + xyTATruth_LastImg( 1 );
shifted_yTANovFAST	= zeroed_yTANovFAST + xyTATruth_LastImg( 2 );
shifted_xyTANovFAST_mean	= zeroed_xyTANovFAST_mean + xyTATruth_LastImg;
shifted_xTANovOSI	= zeroed_xTANovOSI + xyTATruth_LastImg( 1 );
shifted_yTANovOSI	= zeroed_yTANovOSI + xyTATruth_LastImg( 2 );
shifted_xyTANovOSI_mean	= zeroed_xyTANovOSI_mean + xyTATruth_LastImg;
shifted_xTAExpFAST	= zeroed_xTAExpFAST + xyTATruth_LastImg( 1 );
shifted_yTAExpFAST	= zeroed_yTAExpFAST + xyTATruth_LastImg( 2 );
shifted_xyTAExpFAST_mean	= zeroed_xyTAExpFAST_mean + xyTATruth_LastImg;
shifted_xTAExpOSI	= zeroed_xTAExpOSI + xyTATruth_LastImg( 1 );
shifted_yTAExpOSI	= zeroed_yTAExpOSI + xyTATruth_LastImg( 2 );
shifted_xyTAExpOSI_mean	= zeroed_xyTAExpOSI_mean + xyTATruth_LastImg;

% Distance of groups from a generic tip-apex.
d_TANovFAST	= sqrt( ( shifted_xTANovFAST( : ) - xyTATruth_LastImg( 1 ) ) .^ 2 + ( shifted_yTANovFAST( : ) - xyTATruth_LastImg( 2 ) ) .^ 2 );
d_TAExpFAST	= sqrt( ( shifted_xTAExpFAST( : ) - xyTATruth_LastImg( 1 ) ) .^ 2 + ( shifted_yTAExpFAST( : ) - xyTATruth_LastImg( 2 ) ) .^ 2 );
d_TANovOSI	= sqrt( ( shifted_xTANovOSI( : ) - xyTATruth_LastImg( 1 ) ) .^ 2 + ( shifted_yTANovOSI( : ) - xyTATruth_LastImg( 2 ) ) .^ 2 );
d_TAExpOSI	= sqrt( ( shifted_xTAExpOSI( : ) - xyTATruth_LastImg( 1 ) ) .^ 2 + ( shifted_yTAExpOSI( : ) - xyTATruth_LastImg( 2 ) ) .^ 2 );
r_TANovFAST	= ( nanmean( d_TANovFAST) + nanstd( d_TANovFAST ) );
r_TAExpFAST	= ( nanmean( d_TAExpFAST) + nanstd( d_TAExpFAST ) );
r_TANovOSI = ( nanmean( d_TANovOSI) + nanstd( d_TANovOSI ) );
r_TAExpOSI = ( nanmean( d_TAExpOSI) + nanstd( d_TAExpOSI ) );

% Print a table showing error results.
TTA	= table( basicStats( d_TANovFAST ), basicStats( d_TAExpFAST ), basicStats( d_TANovOSI ), basicStats( d_TAExpOSI ),...
    'VariableNames', { 'FAST_Novice', 'FAST_Expert', 'OSIRIX_Novice', 'OSIRIX_Expert' },...
    'RowNames', { 'Median', 'Mean', 'StdDev.', 'Min.', 'Max.', 'H_0', 'P' } );
disp( TTA );

% Get polar coordinates.
xyFemur	= horzcat( 227, 181 );
femur_apex_offset  = abs( xyFemur - xyTATruth_LastImg );
[thetaTANovFAT, rhoTANovFAT] = cart2pol( xTANovFAST - mean_xyTAExpOSI( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yTANovFAST - mean_xyTAExpOSI( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaTAExpFAT, rhoTAExpFAT] = cart2pol( xTAExpFAST - mean_xyTAExpOSI( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yTAExpFAST - mean_xyTAExpOSI( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaTANovOSI, rhoTANovOSI] = cart2pol( xTANovOSI - mean_xyTAExpOSI( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yTANovOSI - mean_xyTAExpOSI( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaTAExpOSI, rhoTAExpOSI] = cart2pol( xTAExpOSI - mean_xyTAExpOSI( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yTAExpOSI - mean_xyTAExpOSI( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );

% Convert stats of theta and rho into polar line plots.
npts = 25;
thetaTANovFASTStats	= basicStats( thetaTANovFAT );
rhoTANovFASTStats  = basicStats( rhoTANovFAT );
TApxtnf = linspace( thetaTANovFASTStats( 2 ) - thetaTANovFASTStats( 3 ), thetaTANovFASTStats( 2 ) + thetaTANovFASTStats( 3 ), npts );
TApytnf = repmat( rhoTANovFASTStats( 2 ), 1, npts );
TApyrnf = linspace( rhoTANovFASTStats( 2 ) - rhoTANovFASTStats( 3 ), rhoTANovFASTStats( 2 ) + rhoTANovFASTStats( 3 ), npts );
TApxrnf = repmat( thetaTANovFASTStats( 2 ), 1, npts );
thetaTAExpFASTStats	= basicStats( thetaTAExpFAT );
rhoTAExpFASTStats	= basicStats( rhoTAExpFAT );
TApxtef = linspace( thetaTAExpFASTStats( 2 ) - thetaTAExpFASTStats( 3 ), thetaTAExpFASTStats( 2 ) + thetaTAExpFASTStats( 3 ), npts );
TApytef = repmat( rhoTAExpFASTStats( 2 ), 1, npts );
TApyref = linspace( rhoTAExpFASTStats( 2 ) - rhoTAExpFASTStats( 3 ), rhoTAExpFASTStats( 2 ) + rhoTAExpFASTStats( 3 ), npts );
TApxref = repmat( thetaTAExpFASTStats( 2 ), 1, npts );
thetaTANovOSIStats	= basicStats( thetaTANovOSI );
rhoTANovOSIStats	= basicStats( rhoTANovOSI );
TApxtno = linspace( thetaTANovOSIStats( 2 ) - thetaTANovOSIStats( 3 ), thetaTANovOSIStats( 2 ) + thetaTANovOSIStats( 3 ), npts );
TApytno = repmat( rhoTANovOSIStats( 2 ), 1, npts );
TApyrno = linspace( rhoTANovOSIStats( 2 ) - rhoTANovOSIStats( 3 ), rhoTANovOSIStats( 2 ) + rhoTANovOSIStats( 3 ), npts );
TApxrno = repmat( thetaTANovOSIStats( 2 ), 1, npts );
thetaTAExpOSIStats	= basicStats( thetaTAExpOSI );
rhoTAExpOSIStats	= basicStats( rhoTAExpOSI );
TApxteo = linspace( thetaTAExpOSIStats( 2 ) - thetaTAExpOSIStats( 3 ), thetaTAExpOSIStats( 2 ) + thetaTAExpOSIStats( 3 ), npts );
TApyteo = repmat( rhoTAExpOSIStats( 2 ), 1, npts );
TApyreo = linspace( rhoTAExpOSIStats( 2 ) - rhoTAExpOSIStats( 3 ), rhoTAExpOSIStats( 2 ) + rhoTAExpOSIStats( 3 ), npts );
TApxreo = repmat( thetaTAExpOSIStats( 2 ), 1, npts );

% Map polar coordinate data back to image coordinates.
[x, y]	= pol2cart( TApxtnf, TApytnf );
TAcxtnf = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcytnf = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxrnf, TApyrnf );
TAcxrnf = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcyrnf = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxtef, TApytef );
TAcxtef = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcytef = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxref, TApyref );
TAcxref = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcyref = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxtno, TApytno );
TAcxtno = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcytno = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxrno, TApyrno );
TAcxrno	= x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcyrno = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxteo, TApyteo );
TAcxteo = x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcyteo = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;
[x, y]	= pol2cart( TApxreo, TApyreo );
TAcxreo	= x - femur_apex_offset( 1 ) + xyTATruth_LastImg( 1 );
TAcyreo = ( y - femur_apex_offset( 2 ) - xyTATruth_LastImg( 2 ) ) * -1;


%% Figures.
% Define plot characteristics.
set( 0, 'DefaultFigureWindowStyle', 'docked' )
cFAST = 'c';
alphaFAST = 0.60;
markerFAST = '*';
cNovFAST = 'r';
alphaNovFAST = 0.60;
markerNovFAST = 'o';
cExpFAST = 'b';
alphaExpFAST = 0.60;
markerExpFAST = '^';
cNovOSI = 'm';
alphaNovOSI = 0.60;
markerNovOSI = 'p';
cExpOSI = 'c';
alphaExpOSI = 0.60;
markerExpOSI = 's';

% Plot TAD Px.
fTApx = figure( 'Color', 'w' );
bplot = bar( [mean_pxTADNovFAST, mean_pxTADExpFAST, mean_pxTADNovOSI, mean_pxTADExpOSI],...
    'BarWidth', 1.0, 'LineWidth', 1.5 );
bplot( 1 ).set( 'FaceColor', cNovFAST, 'FaceAlpha', alphaNovFAST );
bplot( 2 ).set( 'FaceColor', cExpFAST, 'FaceAlpha', alphaExpFAST );
bplot( 3 ).set( 'FaceColor', cNovOSI, 'FaceAlpha', alphaNovOSI );
bplot( 4 ).set( 'FaceColor', cExpOSI, 'FaceAlpha', alphaExpOSI );
axis on;    box on;	grid on;    grid minor;
title( 'Per-Image Tip-Apex Distance Over Fluoroscopy Sequence (Averaged by Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Tip-Apex Distance [px]' )
legend( 'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'NorthEast', 'Interpreter', 'Latex' );
set( gca, 'FontSize', 20, 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );


% Plot TAD mm.
fTAmm = figure( 'Color', 'w' );
bplot = bar( [mean_mmTADNovFAST, mean_mmTADExpFAST, mean_mmTADNovOSI, mean_mmTADExpOSI],...
    'BarWidth', 1.0, 'LineWidth', 1.5 );
bplot( 1 ).set( 'FaceColor', cNovFAST, 'FaceAlpha', alphaNovFAST );
bplot( 2 ).set( 'FaceColor', cExpFAST, 'FaceAlpha', alphaExpFAST );
bplot( 3 ).set( 'FaceColor', cNovOSI, 'FaceAlpha', alphaNovOSI );
bplot( 4 ).set( 'FaceColor', cExpOSI, 'FaceAlpha', alphaExpOSI );
axis on;    box on;	grid on;    grid minor;
title( 'Per-Image Tip-Apex Distance Over Fluoroscopy Sequence (Averaged by Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Tip-Apex Distance [mm]' )
legend( 'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'NorthEast', 'Interpreter', 'Latex' );
set( gca, 'FontSize', 20, 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );


% Plot TAD mm -- nn true values
fTAmmTrue = figure( 'Color', 'w' );
bplot = bar( [mean_mmTADNovFASTTrue, mean_mmTADExpFASTTrue, mean_mmTADNovOSI, mean_mmTADExpOSI],...
    'BarWidth', 1.0, 'LineWidth', 1.5 );
bplot( 1 ).set( 'FaceColor', cNovFAST, 'FaceAlpha', alphaNovFAST );
bplot( 2 ).set( 'FaceColor', cExpFAST, 'FaceAlpha', alphaExpFAST );
bplot( 3 ).set( 'FaceColor', cNovOSI, 'FaceAlpha', alphaNovOSI );
bplot( 4 ).set( 'FaceColor', cExpOSI, 'FaceAlpha', alphaExpOSI );
axis on;    box on;	grid on;    grid minor;
title( 'Per-Image Tip-Apex Distance Over Fluoroscopy Sequence (Averaged by Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Tip-Apex Distance [mm]' )
legend( 'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'NorthEast', 'Interpreter', 'Latex' );
set( gca, 'FontSize', 20, 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );


% Plot TAD error wrt mm nn true values
fTAmmTrueError = figure( 'Color', 'w' );
bplot = bar( [mean_mmTADNovFASTTrue-mean_mmTADExpOSI, mean_mmTADExpFASTTrue-mean_mmTADExpOSI, mean_mmTADNovOSI-mean_mmTADExpOSI],...
    'BarWidth', 1.0, 'LineWidth', 1.5 );
bplot( 1 ).set( 'FaceColor', cNovFAST, 'FaceAlpha', alphaNovFAST );
bplot( 2 ).set( 'FaceColor', cExpFAST, 'FaceAlpha', alphaExpFAST );
bplot( 3 ).set( 'FaceColor', cNovOSI, 'FaceAlpha', alphaNovOSI );
axis on;    box on;	grid on;    grid minor;
title( 'Per-Image Tip-Apex Distance Error Over Fluoroscopy Sequence (Averaged by Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Tip-Apex Distance [mm]' )
legend( 'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'NorthEast', 'Interpreter', 'Latex' );
set( gca, 'FontSize', 20, 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );


% Plot time.
ftime   = figure( 'Color', 'w' );
hold on;
timex   = horzcat( 1:numImages, numImages, 1 );
timeNovOSIpatch	= patch( timex, [mean_timeNovOSI; 0; 0], cNovOSI, 'FaceAlpha', alphaNovOSI, 'EdgeColor', cNovOSI );
timeExpOSIpatch	= patch( timex, [mean_timeExpOSI; 0; 0], cExpOSI, 'FaceAlpha', alphaExpOSI, 'EdgeColor', cExpOSI );
timeNovFastpatch	= patch( timex, [mean_timeNovFAST; 0; 0], cNovFAST, 'FaceAlpha', alphaExpFAST, 'EdgeColor', cNovFAST );
timeExpFastpatch	= patch( timex, [mean_timeExpFAST; 0; 0], cExpFAST, 'FaceAlpha', alphaExpOSI, 'EdgeColor', cExpFAST );
axis on;    box on;	grid on;    grid minor;
title( 'Cumulative Per-Image Time Over Fluoroscopy Sequence (Averaged by Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Cumulative Time [s]' )
legend( 'OSIRIX Novices',...
    'OSIRIX Experts',...
    'FASTER Novices',...
    'FASTER Experts',...
    'Location', 'NorthWest', 'Interpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );
atime   = gca;
set( atime, 'FontSize', 20, 'XLim', horzcat( 1, numImages ), 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
% ftimeoverlay = figure( 'Color', 'w' );
% atimeoverlay = copyobj( atime, ftimeoverlay );
% hold on;
% plotExpOSI = plot( repmat( ( 1:numImages )', 1, size( timeExpOSI, 2 ) ), cumsum( timeExpOSI ), 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI, 'LineStyle', '-' );
% plotNovFAST = plot( repmat( ( 1:numImages )', 1, size( timeNovFAST, 2 ) ), cumsum( timeNovFAST ), 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST, 'LineStyle', '-' );
% plotExpFAST = plot( repmat( ( 1:numImages )', 1, size( timeExpFAST, 2 ) ), cumsum( timeExpFAST ), 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST, 'LineStyle', '-' );
% legend( [plotExpOSI( 1 ), plotNovFAST( 1 ), plotExpFAST( 1 )],...
%     'OSIRIX Experts', 'FASTER Novices', 'FASTER Experts', 'Location', 'Best', 'Interpreter', 'Latex' );
% xticklabels( view );    xtickangle( 45 );

% Plot wire width.
fWW = figure( 'Color', 'w' );
wwx = horzcat( reshape( repmat( 0:numImages, 2, 1 ), 1, [] ) );
wwyNovFAST	= horzcat( 0, reshape( repmat( mean_WWFAST', 2, 1 ), 1, [] ), 0 );
% wwyNovOSI	= horzcat( 0, reshape( repmat( mean_NovOSI', 2, 1 ), 1, [] ), 0 );
wwyExpOSI	= horzcat( 0, reshape( repmat( mean_ExpOSI', 2, 1 ), 1, [] ), 0 );
wwyFASTTRUE	= horzcat( 0, reshape( repmat( mean_WWFASTTrue', 2, 1 ), 1, [] ), 0 );
wwNovFASTpatch	= patch( wwx, wwyNovFAST, 'r', 'FaceAlpha', alphaNovFAST-.25, 'EdgeColor', 'r' );
wwExpOSIpatch	= patch( wwx, wwyExpOSI, 'c', 'FaceAlpha', alphaExpOSI, 'EdgeColor', 'c' );
% wwNovOSIpatch	= patch( wwx, wwyNovOSI, cNovOSI, 'FaceAlpha', alphaNovOSI, 'EdgeColor', cNovOSI );
wwTruepatch	= patch( wwx, wwyFASTTRUE, 'g', 'FaceAlpha', alphaExpOSI-0.25, 'EdgeColor', 'g' );
axis on;    box on;	grid on;    grid minor;
title( 'Per-Image Measured Wire Width Over Fluoroscopy Sequence (Averaged By Group)', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
xlabel( 'Image in Sequence' );
ylabel( 'Wire Width [px]' )
% legend( [wwNovFASTpatch, wwExpOSIpatch, wwNovOSIpatch], 'AI', 'OSIRIX Experts', 'OSIRIX Novices', 'Location', 'SouthEast', 'Interpreter', 'Latex' );
legend( [wwNovFASTpatch, wwExpOSIpatch, wwTruepatch], 'AI', 'OSIRIX Experts', 'AI - Corrected', 'Location', 'SouthEast', 'Interpreter', 'Latex' );
set( gca, 'FontSize', 20, 'XLim', horzcat( 0, numImages ), 'XTick', 1:numImages, 'TickLabelInterpreter', 'Latex' );
xticklabels( view );    xtickangle( 45 );


% Polar plot of Tip-Apex data zeroed to middle of femur.
f0TA	= figure( 'Color', 'w' );
polarpTANovFAT = polarplot( thetaTANovFAT, rhoTANovFAT, 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST, 'LineStyle', 'None'  );
hold on;
polarpTAExpFAT = polarplot( thetaTAExpFAT, rhoTAExpFAT, 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST, 'LineStyle', 'None' );
polarpTANovOSI = polarplot( thetaTANovOSI, rhoTANovOSI, 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI, 'LineStyle', 'None' );
polarpTAExpOSI = polarplot( thetaTAExpOSI, rhoTAExpOSI, 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI, 'LineStyle', 'None' );
grid on;    grid minor;
title( 'Tip-Apex Annotations', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [polarpTANovFAT( 1 ), polarpTAExpFAT( 1 ), polarpTANovOSI( 1 ), polarpTAExpOSI( 1 )],...
    'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'Best', 'Interpreter', 'Latex' );


% Polar plot of Wire-Tip data zeroed to middle of femur.
f0WT	= figure( 'Color', 'w' );
polarpWTNovFAT = polarplot( thetaWTNovFAT, rhoWTNovFAT, 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST, 'LineStyle', 'None'  );
hold on;
polarpWTExpFAT = polarplot( thetaWTExpFAT, rhoWTExpFAT, 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST, 'LineStyle', 'None' );
polarpWTNovOSI = polarplot( thetaWTNovOSI, rhoWTNovOSI, 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI, 'LineStyle', 'None' );
polarpWTExpOSI = polarplot( thetaWTExpOSI, rhoWTExpOSI, 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI, 'LineStyle', 'None' );
grid on;	grid minor;
title( 'Group Wire-Tip Annotations', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [polarpWTNovFAT( 1 ), polarpWTExpFAT( 1 ), polarpWTNovOSI( 1 ), polarpWTExpOSI( 1 )],...
    'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'Best', 'Interpreter', 'Latex' );


% Polar plot with Tip-Apex whiskers, zeroed to middle of femur.
f1TA	= figure( 'Color', 'w' );
TAptnf	= polarplot( TApxtnf, TApytnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAST );
hold on;
TAprnf	= polarplot( TApxrnf, TApyrnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAST );
TAprnfep	= polarplot( TApxrnf( [1 end] ), TApyrnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
TAptnfep	= polarplot( TApxtnf( [1 end] ), TApytnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
TAptef	= polarplot( TApxtef, TApytef, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAST );
TApref	= polarplot( TApxref, TApyref, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAST );
TAprefep	= polarplot( TApxref( [1 end] ), TApyref( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
TAptefep	= polarplot( TApxtef( [1 end] ), TApytef( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
TAptno	= polarplot( TApxtno, TApytno, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovOSI );
TAprno	= polarplot( TApxrno, TApyrno, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovOSI );
TAprnoep	= polarplot( TApxrno( [1 end] ), TApyrno( [1 end] ), 'LineStyle', 'None', 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
TAptnoep	= polarplot( TApxtno( [1 end] ), TApytno( [1 end] ), 'LineStyle', 'None', 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
TApteo	= polarplot( TApxteo, TApyteo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
TApreo	= polarplot( TApxreo, TApyreo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
TApreoep	= polarplot( TApxreo( [1 end] ), TApyreo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
TApteoep	= polarplot( TApxteo( [1 end] ), TApyteo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
grid on;    grid minor;
title( 'Group Tip-Apex Precision \& Accuracy', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [TAprnf, TAptef, TAptno, TApteo],...
    'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'Best', 'Interpreter', 'Latex' );


% Polar plot with Wire-Tip whiskers, zeroed to middle of femur.
f1WT	= figure( 'Color', 'w' );
WTptnf	= polarplot( WTpxtnf, WTpytnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAST );
hold on;
WTprnf	= polarplot( WTpxrnf, WTpyrnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAST );
WTprnfep	= polarplot( WTpxrnf( [1 end] ), WTpyrnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
WTptnfep	= polarplot( WTpxtnf( [1 end] ), WTpytnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAST, 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
WTptef	= polarplot( WTpxtef, WTpytef, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAST );
WTpref	= polarplot( WTpxref, WTpyref, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAST );
WTprefep	= polarplot( WTpxref( [1 end] ), WTpyref( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
WTptefep	= polarplot( WTpxtef( [1 end] ), WTpytef( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAST, 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
WTptno	= polarplot( WTpxtno, WTpytno, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovOSI );
WTprno	= polarplot( WTpxrno, WTpyrno, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovOSI );
WTprnoep	= polarplot( WTpxrno( [1 end] ), WTpyrno( [1 end] ), 'LineStyle', 'None', 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
WTptnoep	= polarplot( WTpxtno( [1 end] ), WTpytno( [1 end] ), 'LineStyle', 'None', 'Color', cNovOSI, 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
WTpteo	= polarplot( WTpxteo, WTpyteo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
WTpreo	= polarplot( WTpxreo, WTpyreo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
WTpreoep	= polarplot( WTpxreo( [1 end] ), WTpyreo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
WTpteoep	= polarplot( WTpxteo( [1 end] ), WTpyteo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
grid on;    grid minor;
title( 'Group Wire-Tip Precision \& Accuracy', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [WTprnf, WTptef, WTprno, WTpteo],...
    'FASTER Novices',...
    'FASTER Experts',...
    'OSIRIX Novices',...
    'OSIRIX Experts',...
    'Location', 'Best', 'Interpreter', 'Latex' );


% Plot polar Tip-Apex wiskers (converted to cartesians) overlayed onto image.
ftaw2  = figure( 'Color', 'w' );
imshow( imread( imgfn ), [] );
hold on;
TActnf	= plot( TAcxtnf, TAcytnf, 'Color', cNovFAST, 'LineStyle', '-', 'LineWidth', 3 );
TActnfep  = plot( TAcxtnf( [1 end] ), TAcytnf( [1 end] ), 'Color', cNovFAST, 'LineStyle', 'None', 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
TAcrnf	= plot( TAcxrnf, TAcyrnf, 'Color', cNovFAST, 'LineStyle', '-', 'LineWidth', 3  );
TAcrnfep  = plot( TAcxrnf( [1 end] ), TAcyrnf( [1 end] ), 'Color', cNovFAST, 'LineStyle', 'None', 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
TActef	= plot( TAcxtef, TAcytef, 'Color', cExpFAST, 'LineStyle', '-', 'LineWidth', 3  );
TActefep  = plot( TAcxtef( [1 end] ), TAcytef( [1 end] ), 'Color', cExpFAST, 'LineStyle', 'None', 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
TAcref	= plot( TAcxref, TAcyref, 'Color', cExpFAST, 'LineStyle', '-', 'LineWidth', 3  );
TAcrefep  = plot( TAcxref( [1 end] ), TAcyref( [1 end] ), 'Color', cExpFAST, 'LineStyle', 'None', 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
TActno	= plot( TAcxtno, TAcytno, 'Color', cNovOSI, 'LineStyle', '-', 'LineWidth', 3  );
TActnoep  = plot( TAcxtno( [1 end] ), TAcytno( [1 end] ), 'Color', cNovOSI, 'LineStyle', 'None', 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
TAcrno	= plot( TAcxrno, TAcyrno, 'Color', cNovOSI, 'LineStyle', '-', 'LineWidth', 3  );
TAcrnoep  = plot( TAcxrno( [1 end] ), TAcyrno( [1 end] ), 'Color', cNovOSI, 'LineStyle', 'None', 'Marker', markerNovOSI, 'MarkerFaceColor', cNovOSI );
TActeo	= plot( TAcxteo, TAcyteo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
TActeoep  = plot( TAcxteo( [1 end] ), TAcyteo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
TAcreo	= plot( TAcxreo, TAcyreo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
TAcreoep  = plot( TAcxreo( [1 end] ), TAcyreo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );


% Plot polar Wire-Tip wiskers (converted to cartesians) overlayed onto the same image.
hold on;
WTctnf	= plot( WTcxtnf, WTcytnf, 'Color', cNovFAST, 'LineStyle', '-', 'LineWidth', 3 );
WTctnfep  = plot( WTcxtnf( [1 end] ), WTcytnf( [1 end] ), 'Color', cNovFAST, 'LineStyle', 'None', 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
WTcrnf	= plot( WTcxrnf, WTcyrnf, 'Color', cNovFAST, 'LineStyle', '-', 'LineWidth', 3  );
WTcrnfep  = plot( WTcxrnf( [1 end] ), WTcyrnf( [1 end] ), 'Color', cNovFAST, 'LineStyle', 'None', 'Marker', markerNovFAST, 'MarkerFaceColor', cNovFAST );
WTctef	= plot( WTcxtef, WTcytef, 'Color', cExpFAST, 'LineStyle', '-', 'LineWidth', 3  );
WTctefep  = plot( WTcxtef( [1 end] ), WTcytef( [1 end] ), 'Color', cExpFAST, 'LineStyle', 'None', 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
WTcref	= plot( WTcxref, WTcyref, 'Color', cExpFAST, 'LineStyle', '-', 'LineWidth', 3  );
WTcrefep  = plot( WTcxref( [1 end] ), WTcyref( [1 end] ), 'Color', cExpFAST, 'LineStyle', 'None', 'Marker', markerExpFAST, 'MarkerFaceColor', cExpFAST );
WTctno	= plot( WTcxtno, WTcytno, 'Color', cNovOSI, 'LineStyle', '-', 'LineWidth', 3  );
WTctnoep  = plot( WTcxtno( [1 end] ), WTcytno( [1 end] ), 'Color', cNovOSI, 'LineStyle', 'None', 'Marker', markerNovOSI, 'MarkerFaceColor', cExpOSI );
WTcrno	= plot( WTcxrno, WTcyrno, 'Color', cNovOSI, 'LineStyle', '-', 'LineWidth', 3  );
WTcrnoep  = plot( WTcxrno( [1 end] ), WTcyrno( [1 end] ), 'Color', cNovOSI, 'LineStyle', 'None', 'Marker', markerNovOSI, 'MarkerFaceColor', cExpOSI );
WTcteo	= plot( WTcxteo, WTcyteo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
WTcteoep  = plot( WTcxteo( [1 end] ), WTcyteo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
WTcreo	= plot( WTcxreo, WTcyreo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
WTcreoep  = plot( WTcxreo( [1 end] ), WTcyreo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
title( 'Group Tip-Apex, Wire-Tip Precision \& Accuracy Mapped To A Standard Fluoro', 'Interpreter', 'Latex', 'FontWeight', 'Bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [TActnf, TActnfep, WTctnfep, TActef, TActefep, WTctefep, TActno, TActnoep, WTctnoep, TActeo, TActeoep, WTcteoep],...
    'FASTER Novices',...
    ['TA Error StDev: \theta = ', num2str( round( thetaTANovFASTStats( 3 )*180/pi, 0 ) ),...
    ' deg; \rho = ', num2str( round( rhoTANovFASTStats( 3 ), 1 ) ), ' [px]'],...
    ['WT Error StDev: \theta = ', num2str( round( thetaWTNovFASTStats( 3 )*180/pi, 0 ) ),...
    ' deg; \rho = ', num2str( round( rhoWTNovFASTStats( 3 ), 1 ) ), ' [px]'],...
    'FASTER Experts',...
    ['TA Error StDev: \theta = ', num2str( round( thetaTAExpFASTStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoTAExpFASTStats( 3 ), 1 ) ), ' [px]'],...
    ['WT Error StDev: \theta = ', num2str( round( thetaWTExpFASTStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoWTExpFASTStats( 3 ), 1 ) ), ' [px]'],...
    'OSIRIX Novices',...
    ['TA Error StDev: \theta = ', num2str( round( thetaTANovOSIStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoTANovOSIStats( 3 ), 1 ) ), ' [px]'],...
    ['WT StDev: \theta = ', num2str( round( thetaWTNovOSIStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoWTNovOSIStats( 3 ), 1 ) ), ' [px]'],...
    'OSIRIX Experts',...
    ['TA Error StDev: \theta = ', num2str( round( thetaTAExpOSIStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoTAExpOSIStats( 3 ), 1 ) ), ' [px]'],...
    ['WT StDev: \theta = ', num2str( round( thetaWTExpOSIStats( 3 )*180/pi ), 0 ),...
    ' deg; \rho = ', num2str( round( rhoWTExpOSIStats( 3 ), 1 ) ), ' [px]'],...
    'Location', 'SouthEast', 'Interpreter', 'Latex' );


% Plot circles of groups' Tip-Apex StdDev
f3  = figure( 'Color', 'w' );
imshow( imread( imgfn ), [] );
hold on;
t   = linspace( 0, 2 * pi );
patNovFAST	= patch( r_TANovFAST * cos( t ) + nanmean( shifted_xTANovFAST( : ) ),...
    r_TANovFAST * sin( t ) + mean( shifted_yTANovFAST( : ) ),...
    cNovFAST, 'FaceAlpha', alphaNovFAST, 'EdgeColor', cNovFAST );
patNovOSI	= patch( r_TANovOSI * cos( t ) + nanmean( shifted_xTANovOSI( : ) ),...
    r_TANovOSI * sin( t ) + mean( shifted_yTANovOSI( : ) ),...
    cNovOSI, 'FaceAlpha', alphaNovOSI, 'EdgeColor', cNovOSI );
patExpOSI	= patch( r_TAExpOSI * cos( t ) + nanmean( shifted_xTAExpOSI( : ) ),...
    r_TAExpOSI * sin( t ) + nanmean( shifted_yTAExpOSI( : ) ),...
    cExpOSI, 'FaceAlpha', alphaExpOSI, 'EdgeColor', cExpOSI );
patExpFAST	= patch( r_TAExpFAST * cos( t ) + nanmean( shifted_xTAExpFAST( : ) ),...
    r_TAExpFAST * sin( t ) + nanmean( shifted_yTAExpFAST( : ) ),...
    cExpFAST, 'FaceAlpha', alphaExpFAST, 'EdgeColor', cExpFAST );
patWTNovFAST	= patch( r_WTNovFAST * cos( t ) + nanmean( shifted_xWTNovFAST( : ) ),...
    r_WTNovFAST * sin( t ) + mean( shifted_yWTNovFAST( : ) ),...
    cNovFAST, 'FaceAlpha', alphaNovFAST, 'EdgeColor', cNovFAST );
patWTNovOSI	= patch( r_WTNovOSI * cos( t ) + nanmean( shifted_xWTNovOSI( : ) ),...
    r_WTNovOSI * sin( t ) + mean( shifted_yWTNovOSI( : ) ),...
    cNovOSI, 'FaceAlpha', alphaNovOSI, 'EdgeColor', cNovOSI );
patWTExpOSI	= patch( r_WTExpOSI * cos( t ) + nanmean( shifted_xWTExpOSI( : ) ),...
    r_WTExpOSI * sin( t ) + nanmean( shifted_yWTExpOSI( : ) ),...
    cExpOSI, 'FaceAlpha', alphaExpOSI, 'EdgeColor', cExpOSI );
patWTExpFAST	= patch( r_WTExpFAST * cos( t ) + nanmean( shifted_xWTExpFAST( : ) ),...
    r_WTExpFAST * sin( t ) + nanmean( shifted_yWTExpFAST( : ) ),...
    cExpFAST, 'FaceAlpha', alphaExpFAST, 'EdgeColor', cExpFAST );
title( 'Group Tip-Apex, Wire-Tip Precision Mapped To A Standard Fluoro', 'Interpreter', 'Latex', 'FontWeight', 'bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [patWTNovFAST, patWTNovOSI, patWTExpFAST, patWTExpOSI],...
    ['FASTER Novices Error - StDev: TA = ', num2str( round( r_TANovFAST, 2 ) ),...
    ', WT = ', num2str( round( r_WTNovFAST, 2 ) )],...
    ['OSIRIX Novices Error - StDev: TA = ', num2str( round( r_TANovOSI, 2 ) ),...
    ', WT = ', num2str( round( r_WTNovOSI, 2 ) )],...
    ['FASTER Experts Error - StDev: TA = ', num2str( round( r_TAExpFAST, 2 ) ),...
    ', WT = ', num2str( round( r_WTExpFAST, 2 ) )],...
    ['OSIRIX Experts Error - StDev: TA = ', num2str( round( r_TAExpOSI, 2 ) ),...
    ', WT = ', num2str( round( r_WTExpOSI, 2 ) )],...
    'Location', 'SouthEast', 'Interpreter', 'Latex' );
a3 = gca;

% Plot again but overlay with real data points -- figure out alpha
f4 = figure( 'Color', 'w' );
a4 = copyobj( a3, f4 );
hold on;
pTANovFAST	= plot( shifted_xTANovFAST( : ), shifted_yTANovFAST( : ), 'Color', cNovFAST, 'MarkerFaceColor', cNovFAST, 'Marker', markerNovFAST, 'LineStyle', 'None' );
pTAExpFAST	= plot( shifted_xTAExpFAST( : ), shifted_yTAExpFAST( : ), 'Color', cExpFAST, 'MarkerFaceColor', cExpFAST, 'Marker', markerExpFAST, 'LineStyle', 'None' );
pTANovOSI	= plot( shifted_xTANovOSI( : ), shifted_yTANovOSI( : ), 'Color', cNovOSI, 'MarkerFaceColor', cNovOSI, 'Marker', markerNovOSI, 'LineStyle', 'None' );
pTAExpOSI	= plot( shifted_xTAExpOSI( : ), shifted_yTAExpOSI( : ), 'Color', cExpOSI, 'MarkerFaceColor', cExpOSI, 'Marker', markerExpOSI, 'LineStyle', 'None' );
pWTNovFAST	= plot( shifted_xWTNovFAST( : ), shifted_yWTNovFAST( : ), 'Color', cNovFAST, 'MarkerFaceColor', cNovFAST, 'Marker', markerNovFAST, 'LineStyle', 'None' );
pWTNovOSI	= plot( shifted_xWTNovOSI( : ), shifted_yWTNovOSI( : ), 'Color', cNovOSI, 'MarkerFaceColor', cNovOSI, 'Marker', markerNovOSI, 'LineStyle', 'None' );
pWTExpFAST	= plot( shifted_xWTExpFAST( : ), shifted_yWTExpFAST( : ), 'Color', cExpFAST, 'MarkerFaceColor', cExpFAST, 'Marker', markerExpFAST, 'LineStyle', 'None' );
pWTExpOSI	= plot( shifted_xWTExpOSI( : ), shifted_yWTExpOSI( : ), 'Color', cExpOSI, 'MarkerFaceColor', cExpOSI, 'Marker', markerExpOSI, 'LineStyle', 'None' );
title( 'Individual Tip-Apex \& Wire-Tip Annotations Mapped To A Standard Fluoro', 'Interpreter', 'Latex', 'FontWeight', 'Bold' );
set( gca, 'FontSize', 20, 'TickLabelInterpreter', 'Latex' );
legend( [pTANovFAST, pTANovOSI, pTAExpFAST, pTAExpOSI],...
    ['FASTER Novices Error - StDev: TA = ', num2str( round( r_TANovFAST, 2 ) ),...
    ', WT = ', num2str( round( r_WTNovFAST, 2 ) )],...
    ['OSIRIX Novices Error - StDev: TA = ', num2str( round( r_TANovOSI, 2 ) ),...
    ', WT = ', num2str( round( r_WTNovOSI, 2 ) )],...
    ['FASTER Experts Error - StDev: TA = ', num2str( round( r_TAExpFAST, 2 ) ),...
    ', WT = ', num2str( round( r_WTExpFAST, 2 ) )],...
    ['OSIRIX Experts Error - StDev: TA = ', num2str( round( r_TAExpOSI, 2 ) ),...
    ', WT = ', num2str( round( r_WTExpOSI, 2 ) )],...
    'Location', 'SouthEast', 'Interpreter', 'Latex' );



