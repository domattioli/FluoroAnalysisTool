classdef FluoroObject < handle & matlab.mixin.SetGet &...
        matlab.mixin.CustomDisplay & matlab.mixin.Heterogeneous
    %FLUOROOBJECT Objects located in Fluoro images.
    %   Various objects derived from a fluoroscopy DICOM require a unique
    %   data structure.
    %
    %   See also FLUOROOBJECT, FLUORO, WIRE, FEMUR, HUMERUS.
    %======================================================================
    %{
    properties
    %
    %BOUNDARY (x,y) coordinates of the FLUOROOBJECT outline.
    %   BOUNDARY is computed given mask input. *****TO-DO*****
    %
    %   See also FLUOROOBJECT/MASK.
    BOUNDARY;
    %
    %CHILDREN Child object(s).
    %   CHILDREN is defined by the user.
    %
    %   See also FLUOROOBJECT/PARENT.
    CHILDREN;
    %
    %MASK Binary (black and white) image of the FLUOROOBJECT.
    %   MASK is computed given mask/boundary input.*****TO-DO*****
    %
    %   See also FLUOROOBJECT/BOUNDARY.
    MASK;
    %
    %PARENT Parent object.
    %   PARENT is defined by the user.
    %
    %   See also FLUOROOBJECT/CHILDREN.
    PARENT;
    end
    %}
    
    % Instantiation properties.
    properties ( GetAccess = public, SetAccess = protected, Hidden = false )
        Boundary;	% (x,y) coordinates of the FEMUR outline.
        Children;	% Child FluoroObjects.
        Display;	% Displayed graphics object.
        Mask;		% Binary (black and white) image of the FEMUR.
        Parent;     % Fluoro object.
        Tag;        % Unique registry ID.
    end
    
    methods
        function obj = FluoroObject( varargin ) % Constructor
            %FLUOROOBJECT Construct a generic FLUOROOBJECT.
            %   Once it's made it can't be changed (?).
            %
            %   See also FLUOROOBJECT, FLUORO, WIRE, FEMUR, HUMERUS.
            %==============================================================
            
            % Construct instance, depending on input.
            if nargin > 0
                p = inputParser;
                p.addRequired( 'Parent', @(x) isvalid( x ) ); % Need to revisit - parent needs to be a handle.
                p.addParameter( 'Boundary', obj.defaultBoundary(), @(x) isnumeric( x ) );
                p.addParameter( 'Children', obj.defaultChildren(), @(x) isvalid( x ) );
                p.addParameter( 'Display', obj.defaultDisplay(), @(x)...
                    isa( x, 'matlab.graphics.primitive.Image' ) ||...
                    isa( x, 'matlab.graphics.primitive.Line' ) ||...
                    isa( x, 'matlab.graphics.chart.primitive.Line' ) );
                p.addParameter( 'Mask', obj.defaultMask(), @(x) islogical( x ) );
                p.addParameter( 'Tag', obj.defaultTag(), @(x) ischar( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 - 1 );
                
                % Assign inputted values.
                fields	= fieldnames( p.Results );
                for idx = 1:numel( fields )
                    try
                        obj.set( fields{ idx }, p.Results.( fields{ idx } ) );
                    catch
                        obj.( fields{ idx } ) = p.Results.( fields{ idx } );
                    end
                end
            end
        end
        
        function addChild( obj, child )
            %ADDCHILD Append FluoroObject child to FluoroObject's children.
            %   ADDCHILD( obj, child ) updates the list of children.
            %   
            %   See also REMOVECHILD, FLUOROOBJECT.
            %==============================================================
            
            if isa( child, 'FluoroObject' )
                obj.set( 'Children', vertcat( child, obj.get( 'Children' ) ) );
            else
                error( 'Cannot add child; wrong type.' )
            end
        end
        
        function delete( obj )  % Destructor
            %DELETE Destructor for a FluoroObject.
            %   DELETE( obj ) will destroy the FluoroObject.
            %   
            %   See also FLUOROOBJECT.
            %==============================================================
            
            if ~strcmpi( 'off', obj.get( 'Display' ) )
                if isvalid( obj.get( 'Display' ) )
                    delete( obj.get( 'Display' ) )
                end
            end
            delete( obj );
        end
        
        function b = defaultBoundary( obj );    b   = [];           end %#ok<MANU>
        function c = defaultChildren( obj );	c   = [];           end %#ok<MANU>
        function d = defaultDisplay( obj );     d   = 'off';        end %#ok<MANU>
        function m = defaultMask( obj );        m   = [];           end %#ok<MANU>
        function p = defaultParent( obj );      p   = [];           end %#ok<MANU>
        function t = defaultTag( obj );         t   = '';           end %#ok<MANU>
        function s = defaultSurgeon( obj );   	s   = 'Unknown';	end %#ok<MANU>
        
        
        function removeChild( obj, child )
            %REMOVECHILD Remove FluoroObject child from FluoroObject's children.
            %   REMOVECHILD( obj, child ) updates the list of children.
            %   
            %   See also ADDCHILD, FLUOROOBJECT.
            %==============================================================
            
            if isempty( obj.get( 'Children' ) )
                obj.resetChildren();
            else
                obj.set( 'Children', setdiff( obj.get( 'Children' ), child ) );
            end
        end
        
        function resetBoundary( obj );  obj.Boundary	= obj.defaultBoundary();	end
        function resetChildren( obj );  obj.Children	= obj.defaultChildren();	end
        function resetDisplay( obj )
            handles = get( 0 );
            if ~isempty( handles.CurrentFigure )
                a   = gca;
                for idx = 1:length( obj.Display )
                    ichild = findobj( a.Children, 'Tag', obj.Display( idx ).Tag );
                    delete( ichild );
                    delete( obj.Display( idx ) );
                end
            end
            obj.Display	= obj.defaultDisplay();
        end
        function resetMask( obj );      obj.Mask	= obj.defaultMask();	end
        function resetParent( obj );   	obj.Parent	= obj.defaultParent();	end
        function resetTag( obj );       obj.Tag	= obj.defaultTag();	end
        
        function setBoundaryAndMaskAndDisplay( obj, valueBoundary, valueMask )
            obj.Boundary    = valueBoundary;
            obj.Mask	= valueMask;
        end
    end
    
    % For displaying properties.
    methods ( Access = protected )
        function propgrp = getPropertyGroups( self )
            proplist = sort( properties( self ) );
            propgrp = matlab.mixin.util.PropertyGroup( proplist );
        end
    end
    
    methods ( Static )
        function BW = boundary2Mask( image, B )
            %BOUNDARY2MASK Convert array of boundary points to mask.
            %   BW = BOUNDARY2MASK( B ) returns a logical matrix, where the
            %   true values correspond to all image pixels located within
            %   the boundary defined by B, where B is an Mx2 array of x-
            %   and y-coordinates.
            %   
            %   See also FLUOROOBJECT, BOUNDARY2LINE, MASK2BOUNDARY.
            %==============================================================
            
            narginchk( 2, 2 );
            [x, y]	= deal( B( :, 1 ), B( :, 2 ) );
            [m, n]	= deal( size( image, 2 ), size( image, 1 ) );
            BW	= poly2mask( x, y, m, n );
        end
        function L = boundary2Line( B, degree )
            %BOUNDARY2LINE Convert array of boundary points to a lin. EQ.
            %   L = BOUNDARY2LINE( B ) returns a function handle to a
            %   linear equation derived to fit the defined x- and y-
            %   coordinates of the boundary, where B is fitted by default
            %   using 'fourier1' series.
            %   
            %   L = BOUNDARY2LINE( B, degree ) returns a function handle to
            %   a fourier series of a specified degree.
            %   
            %   See also FLUOROOBJECT, BOUNDARY2MASK, LINE2BOUNDARY.
            %==============================================================
            
            % First, try linear; try fourier if linear sucks.
            narginchk( 1, 2 );
            fittedFunc  = fitlm( B( :, 1 ), B( :, 2 ) );
            fx	= '@(x)';
            if fittedFunc.Rsquared.Ordinary >= 0.95
                mb = table2array( fittedFunc.Coefficients( :, 1 ) );
                fs = strcat( fx, num2str( mb( 2 ) ), '*x + ', num2str( mb( 1 ) ) );
            else
                fitType	= 'fourier';
                if nargin == 1
                    fitType	= strcat( fitType, '1' );
                else
                    fitType	= strcat( fitType, num2str( degree ) );
                end
                fittedFunc	= fit( B( :, 1 ), B( :, 2 ), fitType );
                fx  = strcat( fx, formula( fittedFunc ) );
                names   = coeffnames( fittedFunc );
                values	= coeffvalues( fittedFunc );
                for idx = 1:length( names )
                    fx	= strrep( fx, names( idx ), num2str( values( idx ) ) );
                end
                fs   = '';
                for idx = 1:length( fx{ 1 } )
                    if ~isstrprop( fx{ 1 }( idx ), 'wspace' )
                        fs	= strcat( fs, fx{ 1 }( idx ) );
                    end
                end
            end
            L	= str2func( fs );
        end
        
        function B = centerline2Boundary( CL, offset )
            verts	= interparc( 10, CL( :, 1 ), CL( :, 2 ) );
            Lines   = vertcat( 1:length( verts( :, 1 ) ) - 1, 2:length( verts( :, 1 ) ) );
            norms   = LineNormals2D( verts, Lines' );
            tipSlope    = diff( verts( 1:2, 2 ) ) ./ diff( verts( 1:2, 1 ) );
            if tipSlope > 0.0
                B	= horzcat(...% Try to guess the tip.
                    vertcat( CL( 1, 1 ) - offset * cos( atan( tipSlope ) ),...
                    verts( :, 1 ) - offset * norms( :, 1 ),...
                    flipud( verts( :, 1 ) + offset * norms( :, 1 ) ) ),...
                    vertcat( CL( 1, 2 ) - offset * sin( atan( tipSlope ) ),...
                    verts( :, 2 ) - offset * norms( :, 2 ),...
                    flipud( verts( :, 2 ) + offset * norms( :, 2 ) ) ) );
            else
                B	= horzcat(...
                    vertcat( CL( 1, 1 ) + offset * cos( atan( tipSlope ) ),...
                    verts( :, 1 ) - offset * norms( :, 1 ),...
                    flipud( verts( :, 1 ) + offset * norms( :, 1 ) ) ),...
                    vertcat( CL( 1, 2 ) + offset * sin( atan( tipSlope ) ),...
                    verts( :, 2 ) - offset * norms( :, 2 ),...
                    flipud( verts( :, 2 ) + offset * norms( :, 2 ) ) ) );
            end
        end
        function BW = centerline2Mask( CL, offset )
            BW  = FluoroObject.boundary2Mask(...
                FluoroObject.centerline2Boundary( CL, offset ) );
        end
        
        function b = createBisector( xy )
            %CREATEBISECTOR Create perpendicular bisector to a line.
            %   b = CREATEBISECTOR( xy ) returns a struct representing the
            %   the perpendicular bisector to the line segment specifed by
            %   xy, where xy takes the form [x1 y1; x2 y2]. The resulting
            %   bisector struct contains the slope and y intercept.
            %   
            %   See also FLUOROOBJECT, LINE2MASK.
            %==============================================================
            
            xySlope	= diff( xy( :, 2 ) ) / diff( xy( :, 1 ) );
            bSlope	= -1/xySlope;
            b   = struct( 'm', bSlope, 'b', mean( xy( :, 2 ) ) - bSlope*mean( xy( :, 1 ) ) );
        end
        
        function BW = line2Mask( image, L, xStartEnd, offset )
            %LINE2MASK Convert linear equation into a binary mask.
            %   BW = LINE2MASK( image, L, xStartEnd, offset ) returns a
            %   logical matrix, where the true values correspond to all
            %   image pixels located within a polygon of a specified width
            %   and defined by the linear equation L.
            %   
            %   See also FLUOROOBJECT, LINE2BOUNDARY, MASK2LINE.
            %==============================================================
            
            narginchk( 3, 4 );
            if nargin == 3
                offset = 5;
            end
%             hold on;p=plot(nan,nan,'r--');
            N = 1000;
            xy	= round( interparc( N, xStartEnd, L ) );
            BW  = false( size( image ) );
            BW( sub2ind( size( image ), xy( :, 2 ), xy( :, 1 ) ) )	= true;
            BW  = imdilate( BW, strel( 'disk', floor( offset ) ) );%figure;imshow(BW,[]);pause;close;
            BW	= activecontour( image, BW, 1, 'edge' );
%             BW  = FluoroObject.boundary2Mask( image,...
%                 FluoroObject.line2Boundary( L, xStartEnd, offset ) );
        end
        function B = line2Boundary( L, xStartEnd, offset )
            %LINE2BOUNDARY Convert 
            %   B = LINE2BOUNDARY( L, xStartEnd, offset ) returns the x-
            %   and y- coordinates defining a boundary represented by the
            %   linear equation function handle L, the beginning and ending
            %   x-coordinates for that function, and the normals of
            %   specifed offset.
            %   
            %   Note, I'm assumming that xStartEnd is in the format of tip
            %   to base. Undefined behaviour will occur otherwise.
            %   
            %   See also FLUOROOBJECT, LINE2MASK, BOUNDARY2LINE.
            %==============================================================
            
            narginchk( 2, 3 );
            if isa( L, 'function_handle' )
                points  = horzcat( xStartEnd, L( xStartEnd ) );
            else
                points  = horzcat( xStartEnd, L );
            end
            B   = FluoroObject.centerline2Boundary( points, offset );
        end
        function B = mask2Boundary( BW )
            %MASK2BOUNDARY Convert mask to array of boundary points.
            %   B = MASK2BOUNDARY( BW ) returns an an Mx2 array of x- and
            %   y-coordinates defining the boundary of the mask (binary)
            %   image, where the first column of B are the x-coordinates,
            %   the second column of B are the y-coordinates, and BW is a
            %   logical matrix.
            %   
            %   See also FLUOROOBJECT, MASK2LINE, BOUNDARY2MASK.
            %==============================================================
            
            narginchk( 1, 1 );
            [b, ~, numB]	= bwboundaries( BW, 4, 'noholes' );
            ib	= 1;
            if numB > 1
                % Select largest object in prediction mask, include boundaries.
                [~, ib]	= max( cellfun( @length, b ) );
            end
            B	= fliplr( b{ ib } );
        end
        function L = mask2Line( BW )
            %MASK2LINE Convert mask to line.
            %   L = MASK2LINE( BW ) returns a linear equation approximating
            %   the center points of the primary masked blob.
            %   
            %   See also FLUOROOBJECT, MASK2BOUNDARY, LINE2MASK.
            %==============================================================
            
            narginchk( 1, 2 );
            g	= binaryImageGraph( BW );
            count = 0;
            while sum( g.degree() == 1 ) ~= 2  % Remove spurious branch edges.
                count = count + 1;
                BW  = bwmorph( BW, 'spur', 1 );
                g   = binaryImageGraph( BW );
            end
            nodes   = table2array( g.Nodes( :, 1:2 ) );
            maskPath	= g.dfsearch( find( g.degree() == 1, 1, 'first' ) );
            [xyIntp, ~, eq]	= interparc( 10, nodes( maskPath, 1 ), nodes( maskPath, 2 ), 'linear' );
            L	= struct( 'equation', eq, 'xy', xyIntp );
        end
    end
end

