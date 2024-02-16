classdef Humerus < FluoroObject
    %HUMERUS The Humerus in fluoroscopic images.
    %   obj = HUMERUS(  ) returns an...
    %
    %   See also FLUOROOBJECT, WIRE, FEMUR.
    %======================================================================
    %{
    properties
    %BOUNDARY (x,y) coordinates of the WIRE outline.
    %   BOUNDARY is computed given mask input.
    %
    %   See also WIRE, WIRE/EQUATION, WIRE/MASK.
    BOUNDARY;
    %
    %FRACTURE (x,y) defining an approximate 2D fracture line.
    %   FRACTURE may be...
    %
    %   See also .
    FRACTURE;
    %
    %MASK Binary (black and white) image of the FEMUR.
    %   MASK is computed given mask/boundary input.*****TO-DO*****
    %
    %   See also WIRE, WIRE/BOUNDARY, WIRE/EQUATION.
    MASK;
    %
    %PARENT Parent (FLUORO) object of the WIRE.
    %   PARENT is defined by either the user, or the parent FLUORO.
    %
    %   See also WIRE, FEMUR/CHILDREN.
    PARENT;
    %
    end
    %}
    
    % User-Definable properties (editable, derivable).
    properties ( GetAccess = public, SetAccess = protected, Hidden = false )
        Axis;       % FluoroObject defining the Longitudinal Humeral Axis.
        Fracture;	% FluoroObject defining the Supracondylar Fracture.
    end
    
    methods
        function obj = Humerus( varargin )    % Constructor.
            %HUMERUS Construct an instance of a HUMERUS object.
            %   See the class help.
            %
            %   See also HUMERUS, HUMERUS/DELETE.
            %==============================================================
            
            % Construct instance, depending on input.
            if nargin > 0
                vatt	= @(x) isa( x, 'FluoroObject' );
                p = inputParser;
                p.addRequired( 'Parent', @(x) isvalid( x ) );
                p.addParameter( 'Boundary', obj.defaultBoundary(), @(x) isnumeric( x ) );
                p.addParameter( 'Mask', obj.defaultMask(), @(x) islogical( x ) );
                p.addParameter( 'Tag', 'Humerus: 1', @(x) ischar( x ) );
                p.addParameter( 'Fracture', obj.defaultFracture(), vatt );
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
        
        function h = defaultFracture( obj );	h   = FluoroObject( obj, 'Tag', 'Humerus Fracture' );	end
        
        function obj = defineFracture( obj, data, predict )
            %DEFINEFRACTURE Define the humerus fracture via AI or manually.
            %   obj = DEFINEFRACTURE( obj, data, predict ) returns the
            %   updated Humerus object, where 'predict' is a logical.
            %
            %   See also HUMERUS, PREDICTHUMERUS.
            %==============================================================
            
            % First, try to predict the femoral head given the image.
            obj.resetBoundary();
            obj.resetMask();
            if predict
                [mask, fxy]	= obj.predictFracture( data );
            else
                % Manual humeral fracture drawing.
                ax  = data.get( 'Parent' );
                f   = impoly( ax );
                f.setColor( 'g' );
                f.setClosed( false );
                fxy = wait( f );
                while ~isvalid(f)
                    f	= imellipse( ax );
                    fxy = wait(f);
                end
                f.delete();
                pt	= interparc( size( fxy, 1 ), fxy( :, 1 ), fxy( :, 2 ), 'spline' );
                mask    = obj.boundary2Mask( data.get( 'Image' ), pt );
            end
            obj.set( 'Fracture', FluoroObject( obj, 'Boundary',...
                fxy, 'Mask', mask, 'Tag', 'Humeral Fracture' ) );
        end
        
        function delete( obj )  % Destructor.
            %DELETE Destructor for femur object.
            %   DELETE( obj ) will destruct the Humerus object.
            %
            %   See also HUMERUS, DELETEFRACTURE.
            %==============================================================
            if ~isempty( obj )
                obj.deleteFracture();
            end
            delete( obj );
        end
        function deleteFracture( obj )
            %DELETEFRACTURE Destructor for fracture object.
            %   DELETEFRACTURE( obj ) will destruct the fracture object.
            %
            %   See also HUMERUS/DELETE.
            %==============================================================
            
            fracture	= obj.get( 'Fracture' );
            if ~isempty( fracture ) && isvalid( fracture )
                if ~strcmpi( 'off', fracture.get( 'Display' ) )
                    delete( fracture.get( 'Display' ) );
                end
                delete( fracture );
            end
        end
        
        function obj = plot( obj, varargin )
            %PLOT Plot Humerus object.
            %   obj = PLOT( obj ) returns the Humerus object embedded with
            %   approximate plots of the Fracture object.
            %
            %   See also HUMERUS, PLOTFRACTURE, FEMUR/PLOT, WIRE/PLOT.
            %==============================================================
            
            % For now, this just plots the fracture. Eventually have a
            % parser for plotting the entire humerus or fracture or both.
            % Prep plot for Humerus.
            ax  = gca;
            ax.set( 'NextPlot', 'add' );
            fracture    = obj.get( 'Fracture' );
            if strcmpi( 'off', fracture.get( 'Display' ) )
                fractureColor 	= 'g';
                fractureDisplay	= plot( NaN, NaN, 'Parent', ax,...
                    'Tag', horzcat( obj.get( 'Tag' ), ', Fracture' ),...
                    'Color', fractureColor, 'MarkerFaceColor', fractureColor,...
                    'LineStyle', '-.', 'LineWidth', 1.25 );
                fracture.set( 'Display', fractureDisplay );
            end
%             if p.Results.Boundary || plotBoth;	obj.plotBoundary();     end
            obj.plotFracture();
            ax.set( 'NextPlot', 'replace' );
        end
        
        function fp = plotFracture( obj )
            %PLOTFRACTURE Plot the Fracture object of Humerus.
            %   fp = PLOTHEAD( obj ) returns the plot object of the Fracture.
            %
            %   See also HUMERUS, PLOT.
            %==============================================================
            
            fracture = obj.get( 'Fracture' );
            if isempty( fracture.get( 'Boundary' ) )
                fp  = [];
                return
            end
            fp	= fracture.get( 'Display' );
            fxy	= fracture.get( 'Boundary' );
            fp.set( 'XData', fxy( : , 1 ), 'YData', fxy( :, 2 ), 'Visible', 'on' );
            fracture.set( 'Display', fp );
            obj.set( 'Fracture', fracture );
        end
        
        function [mask, humerusXY] = predictHumerus( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTFRACTURE.
            %==============================================================
        end
        function [mask, fractureXY] = predictFracture( obj, data )
            % This function would return a connected components mask (a
            % numbered label for the head, neck, and shaft, respectively.
            % Also the 'b' output would be a cell structure corresponding
            % to the connected components.
            %   
            %   See also PREDICTHUMERUS,.
            %==============================================================
        end
        
        function resetHumerus( obj )
            obj.resetFracture();
            obj.resetBoundary();
            obj.resetChildren();
            obj.resetDisplay();
            obj.resetMask();
            obj.resetParent();
            obj.resetTag();
        end
        function resetFracture( obj );	obj.deleteFracture();	obj.set( 'Head', obj.defaultFracture() );	end
    end
end

