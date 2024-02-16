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

%% Figures.
% Plot colors
fatC = 'c';
fatAlpha = 0.50;
cNovFAT = 'r';
alphaNovFAT = 0.50;
cExpFAT = 'g';
alphaExpFAT = 0.50;
cExpOSI = 'b';
alphaExpOSI = 0.50;

% Plot circles of groups' StdDev
f1  = figure( 'Color', 'w' );
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

% Plot again but overlay with real data points -- figure out alpha
a1 = gca;
f2 = figure( 'Color', 'w' );
a2 = copyobj( a1, f2 );
hold on;
pNovFAT	= plot( l_xNovFATz, l_yNovFATz, 'Color', cNovFAT, 'MarkerFaceColor', cNovFAT, 'Marker', '*', 'LineStyle', 'None' );
pExpFAT	= plot( l_xExpFATz, l_yExpFATz, 'Color', cExpFAT, 'MarkerFaceColor', cExpFAT, 'Marker', '^', 'LineStyle', 'None' );
pExpOSI	= plot( l_xExpOSIz, l_yExpOSIz, 'Color', cExpOSI, 'MarkerFaceColor', cExpOSI, 'Marker', 'o', 'LineStyle', 'None' );
title( 'Individual Tip-Apex Locations On A Standard Femur' );
set( gca, 'FontSize', 20 );
legend( [pNovFAT, pExpOSI, pExpFAT],...
    ['FAT Novices (StdDev: ', num2str( std( rNovFAT ) ), ')'],...
    ['FAT Experts (StdDev: ', num2str( std( rExpFAT ) ), ')'],...
    ['OSIRIX Experts (StdDev: ', num2str( std( rExpOSI ) ), ')'],...
    'Location', 'Best' );



% Plot patches and coordinate.
f = figure( 'Color', 'w' );
imshow( imread( imgfn ), [] );
axis on
box on;
grid on;
grid minor;
hold on;
patzfatxy	= patch( l_xFATz( il_FATz ), l_yFATz( il_FATz ), fatC, 'FaceAlpha', fatAlpha, 'EdgeColor', fatC );
pzfatxy     = plot( xFATz, yFATz, fatC, 'Marker', '*', 'LineStyle', 'None' );
pzmfatxy	= plot( xyFATzm( :, 1 ), xyFATzm( :, 2 ) , 'Color', 'k', 'Marker', 'o', 'MarkerFaceColor', fatC, 'Linestyle', 'None' );

% patzfatnovxy	= patch( lzfatnovx( kzfatnov ), lzfatnovy( kzfatnov ), fatnovC, 'FaceAlpha', fatnovAlpha, 'EdgeColor', fatnovC );
% pzfatnovxy     = plot( zfatnovx, zfatnovy, fatnovC, 'Marker', '*', 'LineStyle', 'None' );
% pzmfatnovxy	= plot( zmfatnovxy( :, 1 ), zmfatnovxy( :, 2 ) , 'Color', 'k', 'Marker', 'o', 'MarkerFaceColor', fatnovC, 'Linestyle', 'None' );

patzfatexpxy	= patch( l_xExpFATz( il_ExpFATz ), l_yExpFATz( il_ExpFATz ), cExpFAT, 'FaceAlpha', alphaExpFAT, 'EdgeColor', cExpFAT );
pzfatexpxy     = plot( xExpFATz, yExpFATz, cExpFAT, 'Marker', '*', 'LineStyle', 'None' );
pzmfatexpxy	= plot( xyExpFATzm( :, 1 ), xyExpFATzm( :, 2 ) , 'Color', 'k', 'Marker', 'o', 'MarkerFaceColor', cExpFAT, 'Linestyle', 'None' );

title( 'Tip-Apex Locations Relative to OSIRIX Experts' );
set( gca, 'FontSize', 20 )
legend( [pzfatxy( 1 ); pzmfatxy( 1 ); pzfatexpxy( 1 ); pzmfatexpxy( 1 )],...
    ['FAT Novices, Area = ', num2str( round( v_FATz ) ), ' [px]'],...
    ['FAT Novices Midpoints, Area = ', num2str( round( v_FATzm ) ), ' [px]'],...
    ['FAT Experts, Area = ', num2str( round( v_ExpFATz ) ), ' [px]'],...
    ['FAT Experts Midpoints, Area = ', num2str( round( v_ExpFATzm ) ), ' [px]'],...
    'Location', 'Best')

