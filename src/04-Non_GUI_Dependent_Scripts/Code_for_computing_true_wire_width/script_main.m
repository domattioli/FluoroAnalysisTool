p = 'C:\Users\dmattioli\OneDrive - University of Iowa\Academic\Publications\01-Fluoro_Analysis_Tool';
nnfolder = fullfile( p, 'nn_wire_data' );
imgfolder = fullfile( p, '053' );

fn1 = '11541776';
nImages = 21;
meanWidth   = NaN( nImages, 1 );
gfn = 'C:\Users\dmattioli\OneDrive - University of Iowa\Spring_2020\IGPI_7480-Advanced_Digital_Image_Processing\Project\movie.gif';
figure;
for idx = 0:nImages
    % Load data.
    dcmffn	= strcat( fullfile( imgfolder, num2str( str2double( fn1 ) + idx ) ), '.dcm' );
    img = dicomread( dcmffn );
    [nrows, ncols] = size( img );
    ffn = strcat( fullfile( nnfolder, num2str( str2double( fn1 ) + idx ) ), '.mat' );
    b	= load( ffn );
    if idx == 3
        continue
    end
    
    % Get centerline of masks
    figure;imshow(img,[]);
    BW  = imfill( poly2mask( b.B{ 1 }( :, 2 ), b.B{ 1 }( :, 1 ), nrows, ncols ), 'holes' );
    smoothedBW 	= imopen( BW, strel( 'disk', 2 ) );
%     d2BW = bwdist( ~smoothedBW, 'Euclidean' );
%     figure;imcontour(d2BW);
    
    skel    = bwskel( smoothedBW );
    
%     skel	= bwmorph( bwmorph( smoothedBW, 'skel', inf ), 'spur', 2 );
%     g	= binaryImageGraph( BW );
%     count	= 0;
%     while sum( g.degree() == 1 ) ~= 2  % Remove spurious branch edges.
%         count = count + 1;
%         skel  = bwmorph( skel, 'spur', 1 );
        g   = binaryImageGraph( skel );
%     end
    nodes   = table2array( g.Nodes( :, 1:2 ) );
    maskPath	= g.dfsearch( find( g.degree() == 1, 1, 'first' ) );
    [xyIntp, ~, eq]	= interparc( ceil( size( nodes, 1 ) ),...
        nodes( maskPath, 1 ), nodes( maskPath, 2 ), 'linear' );
    L	= struct( 'equation', eq, 'xy', xyIntp );
    [x, y]  = deal( L.xy( :, 1 ), L.xy( :, 2 ) );
    
    % Create orthogonals - length no greater than dimensions of BW.
    npx = length( x );
    os	= {};
    rprops = regionprops( BW, 'All' );
    minDim = min( [rprops.MinorAxisLength, rprops.MajorAxisLength] );
    olength = ceil( minDim / 5 ) * 5;
    for jdx = 1:npx-1
        m	= diff( y( jdx:jdx + 1 ) ) / diff( x( jdx:jdx + 1 ) );
        if m == inf || m == -inf
            continue
        elseif abs( m ) > .01
            mp	= -1/m;
        end
        yint	= y( jdx ) - m*x( jdx );
        
        % Center xy of the line segment.
        c( 1 )	= mean( x( jdx:jdx + 1 ) );
        c( 2 )	= m * c( 1 ) + yint;
        hold on; plot( c( 1 ), c( 2 ), 'y.' );
        
        % Create lines from center.
        yintp	= c( 2 ) - mp * c( 1 );
        ox	= c( 1 ) + ( olength * sqrt( 1 / ( 1 + mp^2 ) ) ) * [-1 1];
        oy	= c( 2 ) + ( mp * olength * sqrt( 1 / (1 + mp^2 ) ) ) * [-1 1];
        ols	= transpose( vertcat( horzcat( ox( 1 ), c( 1 ), ox( 2 ), c( 1 ) ),...
            horzcat( oy( 1 ), c( 2 ), oy( 2 ), c( 2 ) ) ) );
        os	= [ os; horzcat( { ols( 1:2, : ) }, { ols( 3:4, : ) } )];
    end
    
    % "Orthogonal" for the tip.
    numOrthos = length( os );
    if numOrthos > 6
        m	= median( diff( y( ( end - 5 ):end ) ) ./ diff( x( ( end - 5 ):end ) ) );
    else
        m	= mean( diff( y( 1:end ) ) ./ diff( x( 1:end ) ) );
    end
    yint    = y( end ) + m*x( end );
    ox	= x( end ) + ( olength * 1.5 * sqrt( 1 / ( 1 + m^2 ) ) );
    oy	= y( end ) + ( m * olength * sqrt( 1 / (1 + m^2 ) ) );
    ospoly	= vertcat( os( :, 1 ),...
        { horzcat( vertcat( ox, x( end ) ), vertcat( oy, y( end ) ) ) },...
        flipud( os( :, 2 ) ) );
    
    % Edge image stuff.
    bb = [];
    for jdx = 1:length( ospoly )
        bb	= [bb; ospoly{ jdx }( 1, : )];
    end
    [m,n]	= size( BW );
    bw	= poly2mask( bb( :, 1 ), bb( :, 2 ), m, n );
    wireimg	= img;
    wireimg( ~bw )	= false;
    
    % Get pixel intensities along all orthogonals.
    halfWidths	= NaN( length( ospoly ), 1 );
    nprofpts	= olength*1;
    edgeimg = edge( wireimg );
    for jdx = 1:length( ospoly )
        [cx, cy, c]	= improfile( img, ospoly{ jdx }( :, 1 ), ospoly{ jdx }( :, 2 ), nprofpts );
        [cx, cy, c]	= improfile( edgeimg, ospoly{ jdx }( :, 1 ), ospoly{ jdx }( :, 2 ), nprofpts );
        c	= flipud( c );
        dydx	= gradient( c( : ) ) ./ gradient( transpose( 1:nprofpts ) );
        dy2dx	= gradient( dydx( : ) ) ./ gradient( transpose( 1:length( dydx ) ) );
        dy2dxInterp	= interp1( 1:length( dy2dx ), dy2dx, linspace( 1 , length( dy2dx ) ) );
        
        % Threshold of wire half-width occurs at first sign change in 2nd derivative.
        for kdx = 2:length( dy2dxInterp )
            if sign( dy2dxInterp( kdx-1 ) ) > 0 && sign( dy2dxInterp( kdx ) ) <= 0
                imind	= kdx/length( dy2dx );
                break
            end
        end
        
        halfWidths( jdx )	= ( imind/nprofpts ) * olength;
%         poo = interparc( olength, ospoly{jdx}(:,1), ospoly{jdx}(:,2));
%         hold on
%         plot(poo(:,1),poo(:,2),'g.-');
%         f=figure( 'Color', 'w' );
%         f.WindowStyle = 'Docked';
%         subplot( 3, 1, 1 );
%         plot( 1:length( c ), c, 'r.-' );grid on;
%         ylabel( 'Pixel-Value', 'FontSize', 12 );
%         title( 'Pixel-Value Cross-Sectional Profile Along Orthogonal', 'FontSize', 20 )
%         set( gca, 'TickLabelInterpreter', 'Latex' );
%         subplot( 3, 1, 2 );
%         plot( 1:length( dydx ), dydx, 'g.-' );grid on;
%         ylabel( 'First Derivative' );
%         set( gca, 'FontSize', 12, 'TickLabelInterpreter', 'Latex' );
%         subplot( 3, 1, 3 );
%         plot( 1:length( dy2dx ), dy2dx, 'b.-' );grid on;
%         ylabel( 'Second Derivative' );
%         xlabel( 'Point Along Orthogonal' );
%         set( gca, 'FontSize', 12, 'TickLabelInterpreter', 'Latex' );
%         pause;
%         close;
    end
    
    % Sum the two half-widths of each orthogonal.
    widths = nansum( horzcat( halfWidths( 1:size( os, 1 )+1 ),...
        vertcat( halfWidths( size( os, 1 ) + 2:end ), NaN ) ), 2 );
    
    % Take mean for average wire width in image.
    ibadEstimates	= isoutlier( widths( 1:end-1 ), 'ThresholdFactor', 3 );
    if any( ibadEstimates  )
        ibadEstimates   = vertcat( ibadEstimates, false );
%         disp( ['outlier widths for img ', num2str( idx ), ' are: '] )
%         poo = find(ibadEstimates);
%         for jdx = 1:sum( ibadEstimates )
%             disp( num2str( widths( poo( jdx ) ) ) );
%         end
%         disp( ['Original Width:', num2str(nanmean(widths(1:end-1)))]);
        widths( ibadEstimates , : )    = NaN;
     end
     meanWidth( idx + 1 )	= nanmean( widths( 1:end-1 ) );
%     disp( ['Estimated Width:', num2str(nanmean(widths(1:end-1)))]);

     imshow(img,[]);
     frame=getframe(gca);
     im=rgb2gray(frame2im(frame));
     if idx == 0
         imwrite( im, gfn, 'gif', 'Loopcount', inf );
     else
         imwrite( im, gfn, 'gif', 'WriteMode', 'append' );
     end
end
disp(meanWidth)
