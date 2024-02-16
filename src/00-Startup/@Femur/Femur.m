classdef Femur < FluoroObject
    %FEMUR The femur in fluoroscopic images.
    %   obj = FEMUR(  ) returns an...
    %
    %   See also FLUOROOBJECT, WIRE, HUMERUS.
    %======================================================================
    %{
    properties
    %BOUNDARY (x,y) coordinates of the WIRE outline.
    %   BOUNDARY is computed given mask input.
    %
    %   See also WIRE, WIRE/EQUATION, WIRE/MASK.
    BOUNDARY;
    % 
    %HEAD (x,y) defining a circumscribing ellipse of the femoral head.
    %   HEAD may be an ellipse that is fitted to the mask of the entire
    %   femur (smart location of the head), or user-defined.
    %
    %   See also FEMUR, MASK, NECK, SHAFT.
    HEAD;
    %
    %MASK Binary (black and white) image of the FEMUR.
    %   MASK is computed given mask/boundary input.*****TO-DO*****
    %
    %   See also FEMUR, BOUNDARY.
    MASK;
    %
    %NECK (x,y) defining the centerline of the femoral neck.
    %   NECK may be a line that is fitted to the mask of the entire
    %   femur (smart location of the neck), or user-defined. NECK is
    %   defined as the (x,y) coordinates of the perpendicular bisector
    %   running along the (approximate) centerline of the NECK.
    %
    %   See also FEMUR, MASK, HEAD, SHAFT.
    NECK;
    %
    %PARENT Parent (FLUORO) object of the Femur.
    %   PARENT is defined by either the user, or the parent FLUORO.
    %
    %   See also FEMUR, CHILDREN.
    PARENT;
    %
    %SHAFT (x,y) defining the centerline of the femoral shaft.
    %   SHAFT may be a line that is fitted to the mask of the entire
    %   femur (smart location of the shaft), or user-defined.****TO-DO*****
    %
    %   See also FEMUR, MASK, HEAD, NECK.
    SHAFT;
    %
    %TIPAPEX (x,y) defining the tip-apex of the femoral head.
    %   SHAFT may be a line that is fitted to the mask of the entire
    %   femur (smart location of the shaft), or user-defined.****TO-DO*****
    %
    %   See also FEMUR, HEAD, NECK.
    TIPAPEX;
    end
    %}
    
    % User-Definable properties (editable, derivable).
    properties ( GetAccess = public, SetAccess = protected, Hidden = false )
        Head;	% FluoroObject defining the femoral head.
        Neck;	% FluoroObject defining the femoral neck.
        Shaft;	% FluoroObject defining the femoral shaft.
        TipApex;   % (x,y) approximate location of the tip-apex.
    end
    
    methods
        function obj = Femur( varargin )    % Constructor.
            %FEMUR Construct an instance of a FEMUR object.
            %   See the class help.
            %
            %   See also FEMUR, FEMUR/DELETE.
            %==============================================================
            
            % Construct instance, depending on input.
            if nargin > 0
                vatt	= @(x) isa( x, 'FluoroObject' );
                p = inputParser;
                p.addRequired( 'Parent', @(x) isvalid( x ) );
                p.addParameter( 'Boundary', obj.defaultBoundary(), @(x) isnumeric( x ) );
                p.addParameter( 'Mask', obj.defaultMask(), @(x) islogical( x ) );
                p.addParameter( 'Tag', 'Femur: 1', @(x) ischar( x ) );
                p.addParameter( 'Head', obj.defaultHead(), vatt );
                p.addParameter( 'Neck', obj.defaultNeck(), vatt );
                p.addParameter( 'Shaft', obj.defaultShaft(), vatt );
                p.addParameter( 'TipApex', obj.defaultTipApex(), @(x) isnumeric( x ) && numel( x ) == 2 );
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
                obj.resetDisplay();
            end
        end
        
        function h = defaultHead( obj );	h   = FluoroObject( obj, 'Tag', 'Femoral Head' );	end
        function n = defaultNeck( obj );	n   = FluoroObject( obj, 'Tag', 'Femoral Neck' );	end
        function s = defaultShaft( obj );	s   = FluoroObject( obj, 'Tag', 'Femoral Shaft' );	end
        function t = defaultTipApex( obj );	t   = NaN( 1, 2 );	end %#ok<MANU>
        
        function obj = defineHead( obj, data, predict )
            %DEFINEHEAD Define the femoral head via AI or manually.
            %   obj = DEFINEHEAD( obj, data, predict ) returns the updated
            %   Femur object, where 'predict' is a logical.
            %
            %   See also FEMUR, PREDICTHEAD, DEFINENECK, DEFINESHAFT.
            %==============================================================
            
            % First, try to predict the femoral head given the image.
            obj.resetBoundary();
            obj.resetMask();
            if predict
                [mask, headXY]	= obj.predictFemoralHead( data );
            else
                % Manual femoral head (ellipse) drawing.
                ax  = data.get( 'Parent' );
                e	= imellipse( ax );
                e.setColor( 'c' );
                headXY = wait( e );
                while ~isvalid(e)
                    e	= imellipse( ax );
                    headXY = wait(e);
                end
                e.delete();
                mask    = obj.boundary2Mask( data.get( 'Image' ), headXY );
            end
            obj.set( 'Head', FluoroObject( obj, 'Boundary', headXY,...
                'Mask', mask, 'Tag', 'Femoral Head' ) );
        end
        function obj = defineNeck( obj, data, predict )
            %DEFINENECK Define the femoral head via AI or manually.
            %   obj = DEFINENECK( obj, data, predict ) returns the updated
            %   Femur object, where 'predict' is a logical.
            %
            %   See also FEMUR, PREDICTNECK, DEFINEHEAD, DEFINESHAFT.
            %==============================================================
            
            % First, try to predict the femoral neck given the image.
            mainAxis    = data.get( 'Parent' );
            obj.resetBoundary();
            obj.resetMask();
            if predict
                [mask, neckXY]	= obj.predictFemoralNeck( data );
            else
                % Manually draw femoral neck constrained by the points of the femoral head ellipse.
                headXY	= obj.get( 'Head' ).get( 'Boundary' );
                neckXY	= [];
                direction  = data.get( 'Side' );
                while isempty( neckXY ) || numel( neckXY ) ~= 4
                    % Select two points along the head-ellipse adequetly
                    % spaced apart and lie with respect to the side of hip.
                    if strcmpi( direction, 'Right' )
                        [~, iy]	= max( headXY( :, 2 ) );
                        [~, ix]	= min( headXY( :, 1 ) );
                    else
                        [~, iy]	= max( headXY( :, 1 ) );
                        [~, ix]	= max( headXY( :, 2 ) );
                    end
                    iPoints	= headXY( [iy, ix], : );
                    
                    % Draw a green line constrained by points given from the head-ellipse.
                    [minXY, maxXY]	= bounds( headXY, 1 );
                    L	= imline( mainAxis, iPoints );
                    L.setColor( 'm' );
                    L.setPositionConstraintFcn( makeConstrainToRectFcn('imline',...
                        [minXY( 1 ) maxXY( 1 )], [minXY( 2 ) maxXY( 2 ) ] ) );
                    posL	= L.wait;               % [x1 y1; x2 y2]
                    while ~isvalid( L )
                        L	= imline( mainAxis );
                        L.setColor( 'm' );
                        L.setPositionConstraintFcn( makeConstrainToRectFcn('imline',...
                            [minXY( 1 ) maxXY( 1 ) ],[minXY( 2 ) maxXY( 2 ) ] ) );
                        posL	= L.wait;
                    end
                    delete( L );
                    
                    % Find the intersection points of the neck with the ellipse.
                    neckSlope	= diff( posL( :, 2 ) ) / diff( posL( :, 1 ) );
                    neckY_int	= posL( 1, 2 ) - neckSlope * posL( 1, 1 );
                    newX	= mainAxis.get( 'XLim' );
                    newY	= newX.*neckSlope + neckY_int;
                    extendedNeck_XY	= vertcat( newX, newY );
                    neckXY	= InterX( extendedNeck_XY, headXY' ); % Needs to be [x1...xn; y1...yn]
                    if size( neckXY, 2 ) > 2	% Happens when points of neck are outside of ellipse.
                        [~, ixyPX]	= unique( floor( neckXY )', 'rows' );
                        neckXY    = neckXY( :, ixyPX );
                    end
                end
                mask    = false( 2, 1 );
            end
            obj.set( 'Neck', FluoroObject( obj, 'Boundary', neckXY',...
                'Mask', mask, 'Tag', 'Femoral Neck' ) );
            bisectorXY  = obj.neckPerpendicularBisector( direction );
            obj.set( 'TipApex', bisectorXY( 2, : ) );
        end
        function obj = defineShaft( obj, data, predict )
            %DEFINESHAFT Define the femoral shaft via AI or manually.
            %   obj = DEFINESHAFT( obj, data, predict ) returns the updated
            %   Femur object, where 'predict' is a logical.
            %
            %   See also FEMUR, PREDICTSHAFT, DEFINEHEAD, DEFINENECK.
            %==============================================================
        end
        
        function delete( obj )  % Destructor.
            %DELETE Destructor for femur object.
            %   DELETE( obj ) will destruct the femur object.
            %
            %   See also FEMUR, DELETEHEAD, DELETENECK, DELETESHAFT.
            %==============================================================
            if ~isempty( obj )
                obj.deleteHead();
                obj.deleteNeck();
                obj.deleteShaft();
            end
            delete( obj );
        end
        function deleteHead( obj )
            %DELETEHEAD Destructor for head object.
            %   DELETEHEAD( obj ) will destruct the head object.
            %
            %   See also FEMUR/DELETE, DELETENECK, DELETESHAFT.
            %==============================================================
            
            head    = obj.get( 'Head' );
            if ~isempty( head ) && isvalid( head )
                if ~strcmpi( 'off', head.get( 'Display' ) )
                    delete( head.get( 'Display' ) );
                end
                delete( head );
            end
        end
        function deleteNeck( obj )
            %DELETENECK Destructor for neck object.
            %   DELETENECK( obj ) will destruct the neck object.
            %
            %   See also FEMUR/DELETE, DELETEHEAD, DELETESHAFT.
            %==============================================================
            
            neck    = obj.get( 'Neck' );
            if ~isempty( neck ) && isvalid( neck )
                if ~strcmpi( 'off', neck.get( 'Display' ) )
                    delete( neck.get( 'Display' ) );
                end
                neck.delete();
            end
        end
        function deleteShaft( obj )
            %DELETESHAFT Destructor for shaft object.
            %   DELETESHAFT( obj ) will destruct the shaft object.
            %
            %   See also FEMUR/DELETE, DELETEHEAD, DELETENECK.
            %==============================================================
        end
        
        function bisectorXY = neckPerpendicularBisector( obj, direction )
            %NECKPERPENDICULARBISECTOR Perpendicular bisector XY.
            %   bisectorXY = NECKPERPENDICULARBISECTOR(obj, direction)
            %   returns the x- and y-coordinates of the femoral neck's
            %   perpendicular bisector, where the end points of the
            %   bisector lie on the object's femoral head.
            %   
            %   See also FLIPNECKPERPENDICULARBISECTOR, DEFINENECK.
            %==============================================================
            
            % Get Femoral Head and Femoral Neck data, compute slope.
            headXY	= obj.get( 'Head' ).get( 'Boundary' );
            neckXY	= obj.get( 'Neck' ).get( 'Boundary' );
            if isempty( headXY ) || isempty( neckXY )
                return
            end
            neckSlope	= diff( neckXY( :, 2 ) ) / diff( neckXY( :, 1 ) );
            
            % Find a linear EQ for the perpendicular bisector.
            xLim    = vertcat( floor( min( headXY( :, 1 ) ) ),...
                ceil( max( headXY( :, 1 ) ) ) );
            bisectorSlope	= -1/neckSlope;
            bisectorY_int	= mean( neckXY( :, 2 ) ) - bisectorSlope*mean( neckXY( :, 1 ) );
            bisectorXY  = horzcat( xLim, bisectorSlope .* xLim + bisectorY_int );
            
            % Return the points interecting the neck and the ellipse.
            headIntXY	= InterX( bisectorXY', headXY' )';
            neckIntXY	= InterX( bisectorXY', neckXY' )';
            if strcmpi( direction, 'Right' )
                bisectorXY  = vertcat( neckIntXY, headIntXY( 2, : ) );
            else
                bisectorXY  = vertcat( neckIntXY, headIntXY( 1, : ) );
            end
        end
        function obj = flipNeckPerpendicularBisector( obj, direction )
            %FLIPNECKPERPENDICULARBISECTOR Flip bisector direction
            %	obj	= FLIPFEMORALNECKBISECTOR( obj, direction ) returns the
            %	updated Femur object with the Femoral Neck Bisector flipped
            %   to the direction.
            %
            %   See also NECKPERPENDICULARBISECTOR, WIRE/FLIPWIRE.
            %==============================================================
            
            if isempty( obj.get( 'Neck' ).get( 'Boundary' ) )
                return
            end
            bisectorXY  = obj.neckPerpendicularBisector( direction );
            obj.set( 'TipApex', bisectorXY( 2, : ) );
        end
        
        function obj = plot( obj, varargin )
            %PLOT Plot femur object.
            %   obj = PLOT( obj ) returns the femur object with approximate
            %   plots of the femoral head, neck, and shaft.
            %
            %   See also FEMUR, PLOTHEAD, PLOTNECK, PLOTSHAFT,
            %   WIRE/PLOT, HUMERUS/PLOT.
            %==============================================================
            
            if nargin == 1
                % No inputs -- plot all.
                plotAll    = true;
            else
                plotAll    = false;
            end
            p = inputParser;
            p.FunctionName = 'Femur/Plot';
            p.addRequired( 'Direction', @(x) isa( x, 'char' ) )
            p.addParameter( 'Head', false, @(x) islogical( x ) );
            p.addParameter( 'Neck', false, @(x) islogical( x ) );
            p.addParameter( 'Shaft', false, @(x) islogical( x ) );
            p.parse( varargin{:} );
            narginchk( 0 , numel( p.Parameters )*2 - 1 );
            
            % Plot all femur parts separately.
            d   = p.Results.Direction;
            if p.Results.Head || plotAll;	obj.plotHead();     end
            if p.Results.Neck || plotAll;   obj.plotNeck( d );	end
            if p.Results.Shaft || plotAll;  obj.plotShaft();	end
        end
        function hp = plotHead( obj )
            %PLOTHEAD Plot the femoral head object of Femur.
            %   hp = PLOTHEAD( obj ) returns the plot object of the Femur.
            %
            %   See also PLOTNECK, PLOTSHAFT, PLOT.
            %==============================================================
            
            head    = obj.get( 'Head' );
            if isempty( head )
                hp  = [];
                return
            elseif isempty( head.get( 'Boundary' ) )
                hp  = [];
                return
            end
            hp	= head.get( 'Display' );
            headColor 	= 'c';
            hxy	= head.get( 'Boundary' );
            if strcmpi( 'off', hp )
                ax  = gca;
                ax.set( 'NextPlot', 'add' );
                hp	= plot( hxy( : , 1 ), hxy( :, 2 ), 'Parent', ax,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Head' ),...
                    'Color', headColor, 'LineStyle', '-.', 'LineWidth', 1 );
                ax.set( 'NextPlot', 'replace' );
            else
                hp.set( 'XData', hxy( : , 1 ), 'YData', hxy( :, 2 ) );
            end
            head.set( 'Display', hp );
        end
        function np = plotNeck( obj, direction )
            %PLOTNECK Plot the femoral neck object of Femur.
            %   hp = PLOTNECK( obj, direction ) returns the plot object of
            %   the Femur.
            %   
            %   See also PLOTSHAFT, PLOTHEAD, PLOT.
            %==============================================================
            
            neck    = obj.get( 'Neck' );
            if isempty( neck )
                np  = [];
                return
            elseif isempty( neck.get( 'Boundary' ) )
                np  = [];
                return
            end
            np	= neck.get( 'Display' );
            neckColor 	= 'm';
            nxy	= neck.get( 'Boundary' );
            nbxy= obj.neckPerpendicularBisector( direction );
            if strcmpi( 'off', np )
                ax  = gca;
                ax.set( 'NextPlot', 'add' );
                np  = vertcat( plot( nxy( : , 1 ), nxy( :, 2 ), 'Parent', ax,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Neck' ),...
                    'Color', neckColor, 'MarkerFaceColor', neckColor,...
                    'LineStyle', '-', 'Marker', 'o',...
                    'LineWidth', 1, 'MarkerSize', 2.5 ),...
                    plot( nbxy( : , 1 ), nbxy( :, 2 ), 'Parent', gca,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Bisector' ),...
                    'Color', neckColor, 'MarkerFaceColor', neckColor,...
                    'LineStyle', '-', 'Marker', 'o',...
                    'LineWidth', 1, 'MarkerSize', 2.5 ) );
                ax.set( 'NextPlot', 'replace' );
            else
                np( 1 ).set( 'XData', nxy( : , 1 ), 'YData', nxy( :, 2 ) );
                np( 2 ).set( 'XData', nbxy( : , 1 ), 'YData', nbxy( :, 2 ) );
            end
            neck.set( 'Display', np );
        end
        function sp = plotShaft( obj )
        end
        
        function [mask, femurXY] = predictFemur( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTHEAD, PREDICTNECK, PREDICTSHAFT.
            %==============================================================
        end
        function [mask, headXY] = predictHead( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTFEMUR, PREDICTNECK, PREDICTSHAFT.
            %==============================================================
        end
        function [mask, neckXY] = predictNeck( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTFEMUR, PREDICTHEAD, PREDICTSHAFT.
            %==============================================================
        end
        function [mask, shaftXY] = predictShaft( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTFEMUR, PREDICTHEAD, PREDICTNECK.
            %==============================================================
        end
        
        function resetFemur( obj )
            obj.resetHead();
            obj.resetNeck();
            obj.resetShaft();
            obj.resetBoundary();
            obj.resetChildren();
            obj.resetDisplay();
            obj.resetMask();
            obj.resetParent();
            obj.resetTag();
        end
        function resetHead( obj );	obj.deleteHead();	obj.set( 'Head', obj.defaultHead() );	end
        function resetNeck( obj );  obj.deleteNeck();	obj.set( 'Neck', obj.defaultNeck() );	end
        function resetShaft( obj );	obj.deleteShaft();	obj.set( 'Shaft', obj.defaultShaft() );	end
        function resetTipApex( obj );	obj.set( 'TipApex', obj.defaultTipApex() );             end
        
        function setTipApex( obj, val );    obj.set( 'TipApex', val );                          end;
    end
end

