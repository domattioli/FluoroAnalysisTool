p = '/Users/dominik/OneDrive - University of Iowa/Academic/Publications/01-Fluoro_Analysis_Tool';
fn = fullfile( p, 'Tip Apex data.xlsx' );
imgfn = fullfile( p, '11541797.tiff' );
cd( p );

[num, txt, raw] = xlsread( fn );
headers = txt( 1, : );
txt( 1, : ) = [];
numImages = max( num( :, 1 ) );

iFAT = contains( txt( :, 1 ), 'FAT' );
iOSI = contains( txt( :, 1 ), 'OSIRIX' );
iNov = contains( txt( :, 2 ), 'Novice' );
iExp = contains( txt( :, 2 ), 'Expert' );
iNovFAT = iFAT & iNov;
iExpFAT = iFAT & iExp;
iNovOSI = iOSI & iNov; % empty
iExpOSI = iOSI & iExp; % Not needed.

% X-Y-coordinates of all groups, reshaped by user.
xFAT	= reshape( num( iFAT, 2 ), numImages, [] );
yFAT	= reshape( num( iFAT, 3 ), numImages, [] );
xOSI	= reshape( num( iOSI, 2 ), numImages, [] );
yOSI	= reshape( num( iOSI, 3 ), numImages, [] );
xNovFAT = reshape( num( iNovFAT, 2 ), numImages, [] );
yNovFAT = reshape( num( iNovFAT, 3 ), numImages, [] );
xExpFAT = reshape( num( iExpFAT, 2 ), numImages, [] );
yExpFAT = reshape( num( iExpFAT, 3 ), numImages, [] );
xNovOSI = reshape( num( iNovOSI, 2 ), numImages, [] );
yNovOSI = reshape( num( iNovOSI, 3 ), numImages, [] );
xExpOSI = reshape( num( iExpOSI, 2 ), numImages, [] );
yExpOSI = reshape( num( iExpOSI, 3 ), numImages, [] );

% Group median coordinates by image.
xyFATm	= horzcat( mean( xFAT, 2 ), mean( yFAT, 2 ) );
xyOSIm	= horzcat( mean( xOSI, 2 ), mean( yOSI, 2 ) );
xyNovFATm	= horzcat( mean( xNovFAT, 2 ), mean( yNovFAT, 2 ) );
xyExpFATm	= horzcat( mean( xExpFAT, 2 ), mean( yExpFAT, 2 ) );
xyNovOSIm   = horzcat( mean( xNovOSI, 2 ), mean( yNovOSI, 2 ) );
xyExpOSIm   = horzcat( mean( xExpOSI, 2 ), mean( yExpOSI, 2 ) );

% Groups with respect to osirix experts.
xyTipApex	= xyExpOSIm( end, : );
xFATz = xFAT - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yFATz = yFAT - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xOSIz = xOSI - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yOSUz = yOSI - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xNovFATz = xNovFAT - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yNovFATz = yNovFAT - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xExpFATz = xExpFAT - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yExpFATz = yExpFAT - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xNovOSIz = xNovOSI - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yNovOSIz = yNovOSI - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xExpOSIz = xExpOSI - xyExpOSIm( :, 1 ) + xyTipApex( 1 );
yExpOSIz = yExpOSI - xyExpOSIm( :, 2 ) + xyTipApex( 2 );
xyFATzm	= xyFATm - xyExpOSIm + xyTipApex;
xyNovFATzm	= xyNovFATm - xyExpOSIm + xyTipApex;
xyExpFATzm	= xyExpFATm - xyExpOSIm + xyTipApex;
xyNovOSIzm	= xyNovOSIm - xyExpOSIm + xyTipApex;
xyExpOSIzm	= xyExpOSIm - xyExpOSIm + xyTipApex;

% Boundaries of groups.
l_xFATz	= xFATz( : );
l_yFATz = yFATz( : );
[il_FATz, v_FATz]	= boundary( l_xFATz, l_yFATz );
[il_FATzm, v_FATzm]	= boundary( xyFATzm( :, 1 ), xyFATzm( :, 2 ) );
l_xNovFATz	= xNovFATz( : );
l_yNovFATz  = yNovFATz( : );
[il_NovFATz, v_NovFATz]	= boundary( l_xNovFATz, l_yNovFATz );
[il_NovFATzm, v_NovFATzm]	= boundary( xyNovFATzm( :, 1 ), xyNovFATzm( :, 2 ) );
l_xExpFATz  = xExpFATz( : );
l_yExpFATz  = yExpFATz( : );
[il_ExpFATz, v_ExpFATz]	= boundary( l_xExpFATz, l_yExpFATz );
[il_ExpFATzm, v_ExpFATzm]	= boundary( xyExpFATzm( :, 1 ), xyExpFATzm( :, 2 ) );
l_xNovOSIz	= xNovOSIz( : );
l_yNovOSIz	= yNovOSIz( : );
try
    [il_NovOSIz, v_NovOSIz]	= boundary( l_xNovOSIz, l_yNovOSIz );
    [il_NovOSIzm, v_NovOSIzm]	= boundary( xyNovOSIzm( :, 1 ), xyNovOSIzm( :, 2 ) );
end
l_xExpOSIz	= xExpOSIz( : );
l_yExpOSIz	= yExpOSIz( : );
[il_ExpOSIz, v_ExpOSUz]	= boundary( l_xExpOSIz, l_yExpOSIz );
[il_ExpOSIzm, v_ExpOSUzm]	= boundary( xyExpOSIzm( :, 1 ), xyExpOSIzm( :, 2 ) );

% Distance of groups from a generic tip-apex.
dNovFAT = sqrt( ( l_xNovFATz - xyTipApex( 1 ) ) .^ 2 + ( l_yNovFATz - xyTipApex( 2 ) ) .^ 2 );
dExpFAT = sqrt( ( l_xExpFATz - xyTipApex( 1 ) ) .^ 2 + ( l_yExpFATz - xyTipApex( 2 ) ) .^ 2 );
dNovOSI = sqrt( ( l_xNovOSIz - xyTipApex( 1 ) ) .^ 2 + ( l_yNovOSIz - xyTipApex( 2 ) ) .^ 2 );
dExpOSI = sqrt( ( l_xExpOSIz - xyTipApex( 1 ) ) .^ 2 + ( l_yExpOSIz - xyTipApex( 2 ) ) .^ 2 );
rNovFAT = mean( dNovFAT) + std( dNovFAT );
rExpFAT = mean( dExpFAT) + std( dExpFAT );
rNovOSI = mean( dNovOSI) + std( dNovOSI );
rExpOSI = mean( dExpOSI) + std( dExpOSI );

% Print a table showing error results.
T = table( basicStats( dNovFAT ), basicStats( dExpFAT ), basicStats( dNovOSI ), basicStats( dExpOSI ),...
    'VariableNames', { 'FAST_Novice', 'FAST_Expert', 'OSIRIX_Novice', 'OSIRIX_Expert' },...
    'RowNames', { 'Median', 'Mean', 'StdDev.', 'Min.', 'Max.', 'H_0', 'P' } );
disp( T );

% Get polar coordinates.
xyFemur	= horzcat( 292, 181 );
femur_apex_offset  = abs( xyFemur - xyTipApex );
[thetaNovFAT, rhoNovFAT] = cart2pol( xNovFAT - xyExpOSIm( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yNovFAT - xyExpOSIm( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaExpFAT, rhoExpFAT] = cart2pol( xExpFAT - xyExpOSIm( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yExpFAT - xyExpOSIm( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaNovOSI, rhoNovOSI] = cart2pol( xNovOSI - xyExpOSIm( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yNovOSI - xyExpOSIm( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );
[thetaExpOSI, rhoExpOSI] = cart2pol( xExpOSI - xyExpOSIm( :, 1 ) + femur_apex_offset( 1 ),...
    ( ( yExpOSI - xyExpOSIm( :, 2 ) ) * -1 ) + femur_apex_offset( 2 ) );

% Convert stats of theta and rho into polar line plots.
npts = 25;
thetaNovFASTStats	= basicStats( thetaNovFAT );
rhoNovFASTStats  = basicStats( rhoNovFAT );
pxtnf = linspace( thetaNovFASTStats( 2 ) - thetaNovFASTStats( 3 ), thetaNovFASTStats( 2 ) + thetaNovFASTStats( 3 ), npts );
pytnf = repmat( rhoNovFASTStats( 2 ), 1, npts );
pyrnf = linspace( rhoNovFASTStats( 2 ) - rhoNovFASTStats( 3 ), rhoNovFASTStats( 2 ) + rhoNovFASTStats( 3 ), npts );
pxrnf = repmat( thetaNovFASTStats( 2 ), 1, npts );
thetaExpFASTStats	= basicStats( thetaExpFAT );
rhoExpFASTStats	= basicStats( rhoExpFAT );
pxtef = linspace( thetaExpFASTStats( 2 ) - thetaExpFASTStats( 3 ), thetaExpFASTStats( 2 ) + thetaExpFASTStats( 3 ), npts );
pytef = repmat( rhoExpFASTStats( 2 ), 1, npts );
pyref = linspace( rhoExpFASTStats( 2 ) - rhoExpFASTStats( 3 ), rhoExpFASTStats( 2 ) + rhoExpFASTStats( 3 ), npts );
pxref = repmat( thetaExpFASTStats( 2 ), 1, npts );
thetaNovOSIStats	= basicStats( thetaNovOSI );
rhoNovOSIStats	= basicStats( rhoNovOSI );
thetaExpOSIStats	= basicStats( thetaExpOSI );
rhoExpOSIStats	= basicStats( rhoExpOSI );
pxteo = linspace( thetaExpOSIStats( 2 ) - thetaExpOSIStats( 3 ), thetaExpOSIStats( 2 ) + thetaExpOSIStats( 3 ), npts );
pyteo = repmat( rhoExpOSIStats( 2 ), 1, npts );
pyreo = linspace( rhoExpOSIStats( 2 ) - rhoExpOSIStats( 3 ), rhoExpOSIStats( 2 ) + rhoExpOSIStats( 3 ), npts );
pxreo = repmat( thetaExpOSIStats( 2 ), 1, npts );

% Map polar coordinate data back to image coordinates.
[x, y] = pol2cart( pxtnf, pytnf );
cxtnf = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cytnf = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;
[x, y] = pol2cart( pxrnf, pyrnf );
cxrnf = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cyrnf = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;
[x, y] = pol2cart( pxtef, pytef );
cxtef = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cytef = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;
[x, y] = pol2cart( pxref, pyref );
cxref = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cyref = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;
[x, y] = pol2cart( pxteo, pyteo );
cxteo = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cyteo = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;
[x, y] = pol2cart( pxreo, pyreo );
cxreo = x - femur_apex_offset( 1 ) + xyTipApex( 1 );
cyreo = ( y - femur_apex_offset( 2 ) - xyTipApex( 2 ) ) * -1;


%% Figures.
% Define plot characteristics.
set( 0, 'DefaultFigureWindowStyle', 'docked' )
cFAT = 'c';
alphaFAT = 0.50;
markerFAT = '*';
cNovFAT = 'r';
alphaNovFAT = 0.50;
markerNovFAT = 'o';
cExpFAT = 'g';
alphaExpFAT = 0.50;
markerExpFAT = '^';
cExpOSI = 'b';
alphaExpOSI = 0.50;
markerExpOSI = 's';

% Polar plot of data zeroed to middle of femur.
f0	= figure( 'Color', 'w' );
polarpNovFAT = polarplot( thetaNovFAT, rhoNovFAT, 'Color', cNovFAT, 'Marker', markerNovFAT, 'MarkerFaceColor', cNovFAT, 'LineStyle', 'None'  );
hold on;
polarpExpFAT = polarplot( thetaExpFAT, rhoExpFAT, 'Color', cExpFAT, 'Marker', markerExpFAT, 'MarkerFaceColor', cExpFAT, 'LineStyle', 'None' );
polarpExpOSI = polarplot( thetaExpOSI, rhoExpOSI, 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI, 'LineStyle', 'None' );
grid on;
grid minor;
title( 'Group Tip-Apex Precision' );
set( gca, 'FontSize', 20 );
legend( [polarpNovFAT( 1 ), polarpExpFAT( 1 ), polarpExpOSI( 1 )],...
    'FAST Novices',...
    'FAST Experts',...
    'OSIRIX Experts',...
    'Location', 'Best' );

% Polar plot with whiskers, zeroed to middle of femur.
f1	= figure( 'Color', 'w' );
ptnf = polarplot( pxtnf, pytnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAT );
hold on;
prnf = polarplot( pxrnf, pyrnf, 'Linestyle', '-', 'LineWidth', 3, 'Color', cNovFAT );
prnfep = polarplot( pxrnf( [1 end] ), pyrnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAT, 'Marker', markerNovFAT, 'MarkerFaceColor', cNovFAT );
ptnfep = polarplot( pxtnf( [1 end] ), pytnf( [1 end] ), 'LineStyle', 'None', 'Color', cNovFAT, 'Marker', markerNovFAT, 'MarkerFaceColor', cNovFAT );
ptef = polarplot( pxtef, pytef, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAT );
pref = polarplot( pxref, pyref, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpFAT );
prefep = polarplot( pxref( [1 end] ), pyref( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAT, 'Marker', markerExpFAT, 'MarkerFaceColor', cExpFAT );
ptefep = polarplot( pxtef( [1 end] ), pytef( [1 end] ), 'LineStyle', 'None', 'Color', cExpFAT, 'Marker', markerExpFAT, 'MarkerFaceColor', cExpFAT );
pteo = polarplot( pxteo, pyteo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
preo = polarplot( pxreo, pyreo, 'Linestyle', '-', 'LineWidth', 3, 'Color', cExpOSI );
preoep = polarplot( pxreo( [1 end] ), pyreo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
pteoep = polarplot( pxteo( [1 end] ), pyteo( [1 end] ), 'LineStyle', 'None', 'Color', cExpOSI, 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
grid on;
grid minor;
title( 'Group Tip-Apex Precision & Accuracy' );
set( gca, 'FontSize', 20 );
legend( [prnf, ptef, pteo],...
    'FAST Novices',...
    'FAST Experts',...
    'OSIRIX Experts',...
    'Location', 'Best' );

% Plot polar wiskers (converted to cartesians) overlayed onto image.
f2  = figure( 'Color', 'w' );
imshow( imread( imgfn ), [] );
hold on;
ctnf	= plot( cxtnf, cytnf, 'Color', cNovFAT, 'LineStyle', '-', 'LineWidth', 3 );
ctnfep  = plot( cxtnf( [1 end] ), cytnf( [1 end] ), 'Color', cNovFAT, 'LineStyle', 'None', 'Marker', markerNovFAT, 'MarkerFaceColor', cNovFAT );
crnf	= plot( cxrnf, cyrnf, 'Color', cNovFAT, 'LineStyle', '-', 'LineWidth', 3  );
crnfep  = plot( cxrnf( [1 end] ), cyrnf( [1 end] ), 'Color', cNovFAT, 'LineStyle', 'None', 'Marker', markerNovFAT, 'MarkerFaceColor', cNovFAT );
ctef	= plot( cxtef, cytef, 'Color', cExpFAT, 'LineStyle', '-', 'LineWidth', 3  );
ctefep  = plot( cxtef( [1 end] ), cytef( [1 end] ), 'Color', cExpFAT, 'LineStyle', 'None', 'Marker', markerExpFAT, 'MarkerFaceColor', cExpFAT );
cref	= plot( cxref, cyref, 'Color', cExpFAT, 'LineStyle', '-', 'LineWidth', 3  );
crefep  = plot( cxref( [1 end] ), cyref( [1 end] ), 'Color', cExpFAT, 'LineStyle', 'None', 'Marker', markerExpFAT, 'MarkerFaceColor', cExpFAT );
cteo	= plot( cxteo, cyteo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
cteoep  = plot( cxteo( [1 end] ), cyteo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
creo	= plot( cxreo, cyreo, 'Color', cExpOSI, 'LineStyle', '-', 'LineWidth', 3  );
creoep  = plot( cxreo( [1 end] ), cyreo( [1 end] ), 'Color', cExpOSI, 'LineStyle', 'None', 'Marker', markerExpOSI, 'MarkerFaceColor', cExpOSI );
title( 'Group Tip-Apex Precision & Accuracy' );
set( gca, 'FontSize', 20 );
legend( [ctnf, ctnfep, ctef, ctefep, cteo, cteoep],...
    'FAST Novices',...
    ['\theta \sigma^2 = ', num2str( thetaNovFASTStats( 3 )*180/pi ), 'deg; \rho \sigma^2 = ', num2str( rhoNovFASTStats( 3 ) ), ' [px]'],...
    'FAST Experts',...
    ['\theta \sigma^2 = ', num2str( thetaExpFASTStats( 3 )*180/pi ), 'deg; \rho \sigma^2 = ', num2str( rhoExpFASTStats( 3 ) ), ' [px]'],...
    'OSIRIX Experts',...
    ['\theta \sigma^2 = ', num2str( thetaExpOSIStats( 3 )*180/pi ), 'deg; \rho \sigma^2 = ', num2str( rhoExpOSIStats( 3 ) ), ' [px]'],...
    'Location', 'Best' );


% Plot circles of groups' StdDev
f3  = figure( 'Color', 'w' );
imshow( imread( imgfn ), [] );
hold on;
t   = linspace( 0, 2 * pi );
patNovFat1  = patch( rNovFAT * cos( t ) + mean( l_xNovFATz ),...
    rNovFAT * sin( t ) + mean( l_yNovFATz ),...
    cNovFAT, 'FaceAlpha', alphaNovFAT, 'EdgeColor', cNovFAT );
patExpOSI1  = patch( rExpOSI * cos( t ) + mean( l_xExpOSIz ),...
    rExpOSI * sin( t ) + mean( l_yExpOSIz ),...
    cExpOSI, 'FaceAlpha', alphaExpOSI, 'EdgeColor', cExpOSI );
patExpFat1  = patch( rExpFAT * cos( t ) + mean( l_xExpFATz ),...
    rExpFAT * sin( t ) + mean( l_yExpFATz ),...
    cExpFAT, 'FaceAlpha', alphaExpFAT, 'EdgeColor', cExpFAT );
title( 'Group Tip-Apex Precision On A Standard Femur' );
set( gca, 'FontSize', 20 );
legend( [patNovFat1, patExpFat1, patExpOSI1],...
    ['FAT Novices (StdDev: ', num2str( std( rNovFAT ) ), ')'],...
    ['FAT Experts (StdDev: ', num2str( std( rExpFAT ) ), ')'],...
    ['OSIRIX Experts (StdDev: ', num2str( std( rExpOSI ) ), ')'],...
    'Location', 'Best' );
a3 = gca;

% Plot again but overlay with real data points -- figure out alpha
f4 = figure( 'Color', 'w' );
a4 = copyobj( a1, f2 );
hold on;
pNovFAT	= plot( l_xNovFATz, l_yNovFATz, 'Color', cNovFAT, 'MarkerFaceColor', cNovFAT, 'Marker', markerNovFAT, 'LineStyle', 'None' );
pExpFAT	= plot( l_xExpFATz, l_yExpFATz, 'Color', cExpFAT, 'MarkerFaceColor', cExpFAT, 'Marker', markerExpFAT, 'LineStyle', 'None' );
pExpOSI	= plot( l_xExpOSIz, l_yExpOSIz, 'Color', cExpOSI, 'MarkerFaceColor', cExpOSI, 'Marker', markerExpOSI, 'LineStyle', 'None' );
title( 'Individual Tip-Apex Locations On A Standard Femur' );
set( gca, 'FontSize', 20 );
legend( [pNovFAT, pExpOSI, pExpFAT],...
    ['FAT Novices (StdDev: ', num2str( std( rNovFAT ) ), ')'],...
    ['FAT Experts (StdDev: ', num2str( std( rExpFAT ) ), ')'],...
    ['OSIRIX Experts (StdDev: ', num2str( std( rExpOSI ) ), ')'],...
    'Location', 'Best' );



