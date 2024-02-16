classdef Wire < FluoroObject
    %WIRE The k-wire captured in fluoroscopic images.
    %   obj = WIRE( mask ) returns an object defining a WIRE given a black
    %   and WIRE image mask. The object is a subclass of FLUORO, which is a
    %   class for defining DICOM images.
    %   
    %   obj = WIRE( boundary ) returns a WIRE object defined by Mx2 array
    %   of x- and y-coordinates that encompass all pixels of the WIRE.
    %   
    %   obj = WIRE( mask, 'Parent', fluoroObj ) defines a WIRE object with
    %   the Parent property set as a pre-defined FLUORO object. The setting
    %   of this property will trigger an attempt to identify the Driver of
    %   the WIRE, who is assumed to be the surgeon named in the fluoroObj's
    %   DICOM data.
    %   
    %   obj = WIRE( mask, 'Driver', 'Adam Smith' ) defines a WIRE object
    %   with the Driver property set as a specific string name to indicate
    %   the surgeon whom drove the wire during surgery. This property is 
    %   set as 'Unknown' if there is no FLUORO parent of the WIRE, or if
    %   the DICOM data of the FLUORO does not specify a surgeon by name.
    %   
    %   obj = WIRE( mask, 'WidthMM', 10 ) sets the Driver property
    %   of WIRE to indicate the surgeon who drove the wire during surgery.
    %   This property is set as 'Unknown' if there is no FLUORO parent of
    %   the WIRE, or if the DICOM data of the FLUORO does not specify a
    %   surgeon by name.
    %   
    %   WIRE is an object with the minimum required information for
    %   defining an object, that is the binary pixel mask.
    %   - You cannot assume that a wire is not bent/curved, so giving a set
    %   of points (base and tip x, y ) cannot be expected to give you all
    %   pixels that the wire is located in.
    %   
    %   See also FLUORO, FEMUR, HUMERUS.
    %======================================================================
    %{
    properties
    %BASE (x,y) coordinates of the WIRE base.
    %   BASE is computed given a mask/boundary input.
    %
    %   See also WIRE, WIRE/TIP.
    %BASE;
    %
    %BOUNDARY (x,y) coordinates of the WIRE outline.
    %   BOUNDARY is computed given mask input.
    %
    %   See also WIRE, WIRE/EQUATION, WIRE/MASK.
    %BOUNDARY;
    %   
    %DRIVER Surgeon who placed the WIRE.
    %    DRIVER is defined by the user or the parent FLUORO
    %
    %   See also WIRE.
    %DRIVER;
    %   
    %EQUATION Linear equation approximating the centerline of the WIRE.
    %    EQUATION is computed given mask/boundary input.
    %
    %   See also WIRE, WIRE/BOUNDARY, WIRE/MASK.
    %EQUATION;
    %   
    %LENGTH Pixel length of the WIRE.
    %   LENGTH is computed given a mask/boundary input.
    %
    %   See also WIRE, WIRE/WIDTHPX, WIRE/WIDTHMM.
    %LENGTH;
    %   
    %MASK Binary (black and white) image of the WIRE.
    %   MASK is computed given mask/boundary input.
    %
    %   See also WIRE, WIRE/BOUNDARY, WIRE/EQUATION.
    %MASK;
    %   
    %PARENT Parent (FLUORO) object of the WIRE.
    %   PARENT is defined by either the user, or the parent FLUORO.
    %
    %   See also WIRE.
    %PARENT;
    %   
    %TIP (x,y) coordinates of the WIRE tip.
    %   TIP is computed given a mask/boundary input.
    %
    %   See also WIRE, WIRE/BASE.
    %TIP;
    %   
    %WIDTHMM Millimeter width of the WIRE.
    %   WIDTHMM is defined by the user.
    %
    %   See also WIRE, WIRE/WIDTHPX, WIRE/LENGTH.
    %WIDTHMM;
    %   
    %WIDTHPX Pixel width of the WIRE.
    %   WIDTHPX is computed given a mask/boundary input.
    %
    %   See also WIRE, WIRE/WIDTHMM, WIRE/LENGTH.
    %WIDTHPX;
    end
    %}
    
    properties ( GetAccess = public, SetAccess = protected, Hidden = true )
        Base;       % (x,y) coordinates of the WIRE base
        Equation;  	% Linear equation approximating the centerline of the WIRE.           
        Length;     % Pixel length of the WIRE.
        Tip;        % (x,y) coordinates of the WIRE tip.
        WidthPX;	% Pixel width of the WIRE.
    end
    
    properties ( GetAccess = public, SetAccess = public, Hidden = true ) 
        Driver;     % Surgeon who placed the WIRE.
        WidthMM;    % Millimeter width of the WIRE.
    end
    
    methods
        function obj = Wire( varargin ) % Constructor.
            %WIRE Construct an instance of a WIRE object.
            %   See the class help.
            %
            %   See also WIRE, WIRE/DELETE, WIRE/PLOT.
            %==============================================================
            
            % Construct instance, depending on input.
            if nargin > 0
                p = inputParser;
                p.addRequired( 'Parent', @(x) isvalid( x ) );
                p.addParameter( 'Boundary', obj.defaultBoundary(), @(x) isnumeric( x ) );
                p.addParameter( 'Mask', obj.defaultMask(), @(x) islogical( x ) );
                p.addParameter( 'Tag', 'Wire: 1', @(x) ischar( x ) );
                p.addParameter( 'Driver', obj.defaultSurgeon(), @(x) ischar( x ) );
                p.addParameter( 'WidthMM', obj.defaultWidthMM(), @(x) isnumeric( x ) );
                p.addParameter( 'WidthPX', obj.defaultWidthPX(), @(x) isnumeric( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 - 1 );
                fields	= fieldnames( p.Results );
                for idx = 1:numel( fields )
                    try
                        obj.set( fields{ idx }, p.Results.( fields{ idx } ) );
                    catch
                        obj.( fields{ idx } ) = p.Results.( fields{ idx } );
                    end
                end
            end
            obj.resetDisplay();
        end
        
        function alignWithDirection( obj, direction )
            %ALIGNWITHDIRECTION Align wire to a direction.
            %   ALIGNWITHDIRECTION( obj, direction ) orient's the wire's
            %   base and tip (x) coordinates with respect to the specified
            %   direction, e.g. a direction of 'Right' will set the
            %   right-most x-coordinate as the tip of the wire.
            %   
            %   See also WIRE, SETBASE, SETTIP, DEFINEWIRE.
            %==============================================================
            
            wtbXY	= sortrows( obj.generateXY(), 'ascend' );
            if strcmpi( 'R', direction( 1 ) )
                obj.setBase( wtbXY( 1, : ) );  obj.setTip( wtbXY( 2, : ) );
            elseif strcmpi( 'L', direction( 1 ) )
                obj.setBase( wtbXY( 2, : ) );  obj.setTip( wtbXY( 1, : ) );
            end
        end
        
        function b = defaultBase( obj );	b   = NaN( 2, 1 );	end %#ok<MANU>
        function e = defaultEquation( obj );e   = NaN;          end %#ok<MANU>
        function l = defaultLength( obj ); 	l   = NaN;          end %#ok<MANU>
        function t = defaultTip( obj );  	t   = NaN( 2, 1 );	end %#ok<MANU>
        function w = defaultWidthMM( obj );	w = NaN;            end %#ok<MANU>
        function w = defaultWidthPX( obj );	w   = NaN;         	end %#ok<MANU>
        
        function [obj, fh] = defineWire( obj, data, predict )
            %DEFINEWIRE Summary of this method goes here
            %   Detailed explanation goes here
            %
            %   See also WIRE, WIRE/PREDICTWIRE.
            %==============================================================
            
            % First, try to predict the femoral head given the image.
            obj.resetBoundary();
            obj.resetMask();
            attempt	= 0;
            attemptMax	= 10;
            fh  = gcf;
            if predict
                [mask, ~, fh]	= obj.predictWire( data );
            end
            if attempt > 0 && attempt ~= ( attemptMax + 1 )
                predict = false; % TO:DO (?) screenshot this image and the eventual wire annotation for training a better model?
                wd  = warndlg( 'Please annotate the wire by hand.', 'Wire Model Failed' );
                waitfor( wd );
            end
            if ~predict
                % Manual wire drawing via poly line.
                ax  = data.get( 'Parent' );
                try
                    H	= impoly( ax, 'Closed', false );
                    H.setColor( 'r' );
                    pos	= wait( H );
                    if isempty( pos )
                        return
                    end
                catch
                    return
                end
                delete( H );
                if size( pos, 1 ) == 1
                    return
                elseif size( pos, 1 ) == 2
                    mask    = obj.line2Mask( data.get( 'Image' ), pos( :, 2 ), pos( :, 1 ) );
                else
                    mask    = obj.line2Mask( data.get( 'Image' ),...
                        pos( 1:end-1, 2 ), pos( 1:end-1, 1 ),...
                        pdist( pos( end-1:end, : ), 'Euclidean' ) );
                end
            end
            obj.set( 'Boundary', obj.mask2Boundary( mask ), 'Mask', mask );
            obj.computeGeometry();
        end
        
        function delete( obj )  % Destructor.
            %DELETE Destructor for wire object.
            %   DELETE( obj ) will remove the wire object from it's Parent
            %   and delete it's data.
            %   
            %   See also WIRE, PLOT.
            %==============================================================
            
            if ~isempty( obj )
                if isvalid( obj )
                    if ~strcmpi( 'off', obj.get( 'Display' ) )
                        delete( obj.Display(:) )
                    end
                    delete( obj )
                end
            end
        end
        
        function obj = flipWire( obj, direction )
            %FLIPWIRE Flip wire x- y- coordinate array.
            %	obj	= FLIPWIRE( obj ) returns the updated Procedure object
            %   who's wire(s) is/are flipped to the opposite of the current
            %   obj.Side.
            %	
            %   See also WIRE, DEFINEWIRE, FLIPFEMORALNECKBISECTOR.
            %==============================================================
            
            % Given the specified direction, create a new set of points.
            if isempty( obj.get( 'Parent' ) )
                return
            end
            % Get Wire Slope [x,y] data.
            wireDisplay	= obj.get( 'Display' );
            x   = fliplr( wireDisplay( 2 ).get( 'XData' ) );
            y   = fliplr( wireDisplay( 2 ).get( 'YData' ) );
            x( 1 )  = [];
            y( 1 )  = [];
            obj.Display( 2 ).set( 'XData', x, 'YData', y );
            obj.plotCenter( direction );
        end
        
        function xy = generateXY( obj )
            %GENERATEXY Generates x- and y- coordinates of wire.
            %   xy = GENERATEXY( obj ) returns a 2x2 matrix of x- and y-
            %   coordinates defining the wire's Base and Tip. The
            %   coordinates are generated from the wire's Equation.
            %   
            %   See also WIRE, GETGEOMETRY, GETEQUATION.
            %==============================================================
            
            % Coordinates should already be stored during initialization.
            eq  = obj.get( 'Equation' );
            if numel( obj ) == 1
                xy  = eq( 0:1 );
            elseif numel( obj ) > 1
                xy  = NaN( 2, 2, numel( obj ) );
                for idx = 1:numel( obj )
                    if isempty( eq{ idx } )
                        continue
                    end
                    xy( :, :, idx )	= eq{ idx }( 0:1 );
                end
            end
            
            % Reconcile with base, tip x-coordinates (temporary til
            % equation doesn't suck).
            bxy     = obj.get( 'Base' );
            if iscell( bxy )
                bxy = cell2mat( bxy );
            end
            if diff( vertcat( xy( 1, 1 ), bxy( 1, 1 ) ) ) > 1
                xy  = flipud( xy );
            end
        end
        
        function obj = computeGeometry( obj, polyDegree )
            %COMPUTEGEOMETRY Computes geometric properties of wire.
            %   obj = COMPUTEGEOMETRY( obj ) returns the current state of
            %   the wire object after computing it's 'Base', 'Length',
            %   'Tip', and 'Width', along with its linear Equation.
            %   
            %   See also WIRE, GENERATEXY, GETRATIO.
            %==============================================================
            
            % Fit second-order polynomial or fourier to wire mask.
            if nargin == 1
                polyDegree = 1;
            end
            editBW	= imdilate( obj.get( 'Mask' ), strel('disk', 4, 0 ) );
            L	= obj.mask2Line( bwmorph( editBW, 'thin', Inf ) );
            %% TO-DO - Sometimes the equation creates an enclosed poly with branches.
            len = cumsum( [0; sqrt( ( L.xy( 2:end, 1 ) - L.xy( 1:end-1, 1 ) ) .^2 ...
            + ( L.xy( 2:end, 2 ) - L.xy( 1:end-1, 2 ) ) .^2 )] );
            wireROI	= regionprops( obj.get( 'Mask' ), 'MajorAxisLength', 'MinorAxisLength' );
            if wireROI.MajorAxisLength > 20
                width   =  wireROI.MinorAxisLength;
            else
                width   =  wireROI.MajorAxisLength;
            end
            obj.set( 'Base', L.xy( 1, : ), 'Tip', L.xy( end, : ),...
                'Length', len, 'WidthPX', width, 'Equation', L.equation );
        end
        
        function r = getRatio( obj )
            %GETRATIO Computes pixel-mm ratio of wire.
            %   r = GETRATIO( obj ) returns the spatial relationship
            %   (ratio) between the wire's width in pixels and millimeters.
            %   
            %   See also WIRE, COMPUTEGEOMETRY.
            %==============================================================
            
            pxWidth	= obj.get( 'WidthPX' );
            mmWidth	= obj.get( 'WidthMM' );
            if numel( obj ) > 1
                r   = mean( cell2mat( pxWidth ) ./ cell2mat( mmWidth ) );
            else
                r   = pxWidth / mmWidth;
            end
        end
        
        function obj = plot( obj, varargin )
            %PLOT Plot wire object.
            %   obj = PLOT( obj ) returns the wire object with approximates
            %   plots of both the centerline of the wire object and the
            %   binary mask of the wire, the graphics object of which are
            %   stored as fields in plt.
            %   
            %   PLOT( obj, 'Mask', 'on' ) will only plot the wire's Mask.
            %   
            %   PLOT( obj, 'center', 'on' ) will only plot the wire's
            %   approximate centerline.
            %   
            %   See also WIRE, PLOTBOUNDARY, PLOTCENTER, FEMUR/PLOT,
            %   HUMERUS/PLOT.
            %==============================================================
            
            boundaryColor 	= [255 215 0]./255;
            colorAtt    = @(x) ischar( x ) || ( isnumeric( x ) && numel( x ) == 3 );
            p = inputParser;
            p.addRequired( 'Direction', @(x) isa( x, 'char' ) )
            p.addParameter( 'Boundary', false, @(x) islogical( x ) );
            p.addParameter( 'Center', false, @(x) islogical( x ) );
            p.addParameter( 'BoundaryColor', boundaryColor, colorAtt  );
            p.addParameter( 'CenterColor', 'r', colorAtt );
            p.parse( varargin{:} );
            narginchk( 0 , numel( p.Parameters )*2 - 1 );
            if ( p.Results.Boundary == false ) && ( p.Results.Center == false )
                plotBoth    = true;
            else
                plotBoth    = false;
            end
            
            % Prep plot for Wire.
            ax  = gca;
            ax.set( 'NextPlot', 'add' );
            if strcmpi( 'off', obj.get( 'Display' ) )
                wireDisplay     = vertcat( plot( NaN, NaN, 'Parent', ax,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Boundary' ),...
                    'Color', p.Results.BoundaryColor, 'MarkerFaceColor', p.Results.BoundaryColor,...
                    'LineStyle', '-', 'LineWidth', 1 ),...
                    plot( NaN, NaN, 'Parent', ax,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Center' ),...
                    'Color', p.Results.CenterColor, 'MarkerFaceColor', p.Results.CenterColor,...
                    'marker', 'o', 'markersize', 5,...
                    'linestyle', '--', 'lineWidth', 1 ) );
                obj.set( 'Display', wireDisplay );
            end
            d   = p.Results.Direction;
            if p.Results.Boundary || plotBoth;	obj.plotBoundary();     end
            if p.Results.Center || plotBoth;	obj.plotCenter( d );	end
            ax.set( 'NextPlot', 'replace' );
        end
        function bp = plotBoundary( obj )
            %PLOTBOUNDARY Plot the boundary pixel coordinates of the Wire.
            %   bp = PLOTBOUNDARY( obj ) returns the plot of the Wire.
            %   
            %   See also PLOTCENTER, PLOT.
            %==============================================================
            
            if isempty( obj.get( 'Boundary' ) )
                bp  = [];
                return
            end
            wireDisplay	= obj.get( 'Display' );
            wxy	= obj.get( 'Boundary' );
            if strcmpi( 'Off', wireDisplay )
                wireDisplay = plot( NaN, NaN, 'Color', [255 215 0]./255, 'LineStyle', '-' );
            end
            wireDisplay( 1 ).set( 'XData', wxy( : , 1 ), 'YData', wxy( :, 2 ), 'Visible', 'on' );
            bp  = wireDisplay( 1 );
        end
        function cp = plotCenter( obj, direction )
            %PLOTCENTER Plot the center line of the Wire.
            %   cp = PLOTCENTER( obj, direction ) returns the plot object
            %   of the Wire.
            %   
            %   See also PLOTBOUNDARY, PLOT.
            %==============================================================
            
            badDir  = contains( lower( direction ), { 'left', 'right', 'l', 'r' } );
            if isempty( obj.get( 'Boundary' ) ) || ~badDir
                cp  = [];
                return
            end
            wireDisplay	= obj.get( 'Display' );
            xy	= obj.generateXY();
            eq  = obj.get( 'Equation' );
            wireDisplay( 2 ).set( 'XData', xy( :, 1 ), 'YData', xy( :, 2 ), 'Visible', 'on' );
            wireDisplay( 2 )	= extendLine( wireDisplay( 2 ), direction, eq );
            cp  = wireDisplay( 2 );
            obj.set( 'Display', wireDisplay );
        end
        function mp = plotMask( obj );	mp	= imshow( obj.get( 'Mask' ) );      end
        
        function [mask, B, fh] = predictWire( obj, data )
            %PREDICTWIRE Apply neural network model on image.
            %	[mask, B] = PREDICTWIRE( data ) returns the binary mask of
            %   the predicted wire, along with the coordinates of its
            %   bounded segmentation, B.
            %   
            %   See also DEFINEWIRE, PROCEDURE/PREDICTFEUMR.
            %==============================================================
            
            % Get an address to a copy of this image, then write it.
            imgDir	= fullfile( sourceCodeDirectory(), 'data', 'temp', 'masks' );
            imgFFN	= strcat( fullfile( imgDir, data.get( 'FileName' ) ), '.png' );
            [imgPath, imgName, imgExt]	= fileparts( imgFFN );
            maskFFN = fullfile( imgPath, strcat( imgName, '_mask', imgExt ) );
%             img	= im2double( data.get( 'Image' ) );
            try
                img	= im2double( data.get( 'Display' ).get( 'CData' ) );
            catch
                img = im2double( data.get( 'Image' ) );
            end
            try
                imwrite( img, imgFFN, 'png' );
            catch
                imwrite( img, imgFFN, 'jpg' );
            end
            
            % Use TCP/IP connection object to input into wire-model.
            fh  = gcf;
            attempt	= 0;
%             tcp	= fh.UserData.get( 'TCP' );
            tcp = instrfindall( 'Status', 'open' );
            if numel( tcp ) > 1
                for idx = 1:numel( tcp )
                    if idx == numel( tcp ); tcp = tcp( idx ); else; fclose( tcp( idx ) ); end
                end
            end
            outMessage	= jsonencode( struct( 'Func', 'run_model',...
                'Img', imgFFN, 'thresh', '0.95' ) );
            while attempt < 5
                % Comm. w/ python the image name for inputting, reading.
                if isempty( tcp ) || strcmpi( 'closed', tcp.Status )
                    % Open a port.
                    [tcp, ~]	= initializeSocketListener();  % this tcp keeps closing -_-
                end
%                 fwrite( tcp, 'test' );
%                 echoMessage	= readServerEcho( tcp, 'test' )
                try
                    fwrite( tcp, outMessage );
                    echoMessage	= readServerEcho( tcp, outMessage );
%                     while tcp.BytesAvailable == 0
%                         fwrite( tcp, outMessage );
%                     end
                catch
                    a = 1
                end
                try
                    attempt = attempt + 1;
                    mask	= logical( imresize( imread( maskFFN ), size( img ) ) );
                    fh.UserData.set( 'TCP', tcp );
                catch
                    [tcp, ~]	= destroySocketListener( tcp ); % Goes in here bc the mask isn't being written.
                    fh.UserData.set( 'TCP', [] );
                end
            end
            
            % Fill holes, connect the largest objects in image, smooth result.
            radii   = regionprops( mask, 'MinorAxisLength' );
            se  = strel( 'disk', round( max( [radii.MinorAxisLength] ) ) );
            mask	= imclose( imfill( bwareaopen( mask, 17 ), 'holes' ), se ); % Need to remove low-potential objects - maybe bwareaopen
            [b, ~, N]	= bwboundaries( mask, 4, 'noholes' );
            if N > 1
                % Select largest object(s) in prediction mask.
                nPix    = cellfun( @length, b );
                T   = clusterdata( nPix, 'MaxClust', 2 );
                [~, iBiggest]   = max( nPix );
                mask	= bwareafilt( mask, length( find( T == T( iBiggest ) ) ) );
                [b, ~, N]	= bwboundaries( mask, 8, 'noholes' );
                if N == 1
                    mask    = activecontour( img, mask, 6, 'Chan-Vese',...
                        'SmoothFactor', 0.5, 'ContractionBias', 0.15 );
                elseif N == 2
                    [~, d]	= HausdorffDist( fliplr( b{ 1 } ), fliplr( b{ 2 } ) );
                    [~, imind]	= min( d( : ) );
                    [r1, r2]	= ind2sub( size( d ), imind );
                    xyL	= fliplr( vertcat( b{ 1 }( r1, : ), b{ 2 }( r2, : ) ) );
                    xyL	= round( interparc( 1000, xyL( :, 1 ), xyL( :, 2 ) ) );
                    mask( sub2ind( size( mask ), xyL( :, 2 ), xyL( :, 1 ) ) )	= true;
                    skel    = bwskel( mask );
                    mask    = activecontour( img, imdilate( skel, strel( 'Disk', 5 ) ),...
                        5, 'Chan-Vese', 'ContractionBias', 0.5 );
                elseif N > 2
                    pause
                end
            else
                mask    = activecontour( img, mask, 5 );
            end
            B   = fliplr( bwboundaries( mask ) );
            save( fullfile( '\\iowa.uiowa.edu\shared\engineering\home\dmattioli\windowsdata\Desktop\nn_wire_data', data.get( 'FileName' ) ), 'B' )
        end
        
        function resetWire( obj )
            obj.resetBase();
            obj.resetBoundary();
            obj.resetChildren();
            obj.resetDisplay();
            obj.resetDriver();
            obj.resetEquation();
            obj.resetLength();
            obj.resetMask();
            obj.resetParent();
            obj.resetTag();
            obj.resetTip();
            obj.resetWidthMM();
            obj.resetWidthPX();
        end
        function resetDriver( obj );    obj.Driver  = obj.defaultSurgeon();     end
        function resetBase( obj );      obj.Base  = obj.defaultBase();          end
        function resetEquation( obj );	obj.Equation  = obj.defaultEquation();	end
        function resetLength( obj );	obj.Length  = obj.defaultLength();      end
        function resetTip( obj );       obj.Tip  = obj.defaultTip();            end
        function resetWidthMM( obj );	obj.WidthMM	= obj.defaultWidthMM();     end
        function resetWidthPX( obj );	obj.WidthMM	= obj.defaultWidthPX();     end
        
        function setBase( obj, val );       obj.set( 'Base', val );     end
        function setWidthEQ( obj, val );	obj.set( 'EQ', val );       end
        function setTip( obj, val );        obj.set( 'Tip', val );      end
        function setWidthMM( obj, val );	obj.set( 'WidthMM', val );	end
        function setWidthPX( obj, val );	obj.set( 'WidthPX', val );	end
    end
end

