classdef PSHF < Procedure
    %PSHF Class for the Pediatric Supracondylar Humerus Fracture annotation
    %   PSHF Class for more modularized code.
    %   
    %   See also PROCEDURE, DHS, FLUORO.
    %======================================================================
    
    properties ( GetAccess = public, SetAccess = public, Hidden = false )
        Humerus;
        Wire;
    end
    
    methods
        function obj = PSHF( varargin )
            %PSHF Construct an instance of this class
            %   Detailed explanation goes here
            %   
            %   See also PSHF/DELETE, PROCEDURE, DHS.
            %==============================================================
            
            if nargin > 0
                wires   = vertcat( Wire( obj, 'Tag', 'PSHF Wire 1' ),...
                    Wire( obj, 'Tag', 'PSHF Wire 2' ),...
                    Wire( obj, 'Tag', 'PSHF Wire 3' ) );
                p	= inputParser;
                st  = dbstack;
                constructorName = st(1).name;
                p.FunctionName	=  constructorName( 1:strfind( constructorName, '.' ) - 1 );
                p.addRequired( 'Parent', @(x) isa( x, 'Fluoro' ) );
                p.addParameter( 'Humerus', Humerus( obj, 'Tag', 'PSHF Humerus' ), @(x) isa( x, 'Humerus' ) );
                p.addParameter( 'Wire', wires, @(x) isa( x, 'Wire' ) && length( x ) == 3 );
                p.addParameter( 'Tag', 'PSHF', @(x) ischar( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 - 1 );
                props = fieldnames( p.Results );
                for n = 1:numel( props )
                    try
                        obj.( props{ n } ) = p.Results.( props{ n } );
                    catch
                        obj.set( props{ n }, p.Results.( props{ n } ) );
                    end
                end
            end
            obj.set( 'Name', 'Pediatric Supracondylar Humerus Fracture' );
        end
        
        function result = compileResult( obj )
            %COMPILERESULT Compile results from stored data in object.
            %   result = COMPILERESULT( obj ) returns a struct containing
            %   the minimum information for the humerus fracture and wires.
            %   
            %   See also PSHF, SAVEDATA.
            %==============================================================
            
            humerus	= obj.get( 'Humerus' );
            wires	= obj.get( 'Wire' );
            result  = struct( 'Fracture', [], 'Wire', [] );
            if ~isempty( humerus )
                if ~isempty( humerus.get( 'Fracture' ).get( 'Boundary' ) )
                    result.Fracture = round( humerus.get( 'Fracture' ).get( 'Boundary' ), 1 );
                end
            end
            if ~isempty( wires )
                wire_struct = struct( 'XY', [], 'PX_Width', [], 'MM_Width', [] );
                if ~isempty( wires.get( 'Boundary' ) )
                    wiresEQ	= wires.get( 'Equation' );
                    for idx = 1:numel( wires )
                        if isempty( wiresEQ{ idx } )
                            continue
                        end
                        wire_struct( idx ).XY = round( wiresEQ{ idx }( 0:.1:1 ), 2 );
                        wire_struct( idx ).PX_Width	= round( wires( idx ).get( 'WidthPX' ), 2);
                        wire_struct( idx ).MM_Width = wires( idx ).get( 'WidthMM' );
                    end
                end
                result.Wire	= wire_struct;
            end
        end
        
        function delete( obj )
            %DELETE Destructor for PSHF object.
            %   DELETE( obj ) deletes PSHF plots and data.
            %
            %   See also PSHF.
            %==============================================================
            
            humerus	= obj.get( 'Humerus' );
            wire    = obj.get( 'Wire' );
            plts    = [];
            if ~isempty( humerus )
                if ~strcmpi( humerus.get( 'Display' ), 'off' )
                    plts	= humerus.get( 'Display' );
                end
            end
            if ~isempty( wire )
                if ~strcmpi( wire.get( 'Display' ), 'off' )
                    plts	= vertcat( plts, wire.get( 'Display' ) );
                end
            end
            for idx = 1:length( plts )
                delete( plts( idx ) );
            end
            delete( obj );
        end
        
        function [Breadth, Width, Theta, ithTip] = evaluate( obj )
            %EVALUATE Computes breadth of wires at the fracture site.
            %   Breadth = EVALUATE( obj ) returns the breadth of the wires
            %   at the fracture plane - there must be at least 2 wires and
            %   1 approximated fracture plane. If there exists M > 2 wires,
            %   the respective breadth between each is returned as an Mx1
            %   array of doubles [px].
            %   
            %   [Breadth, Width] = EVALUATE( obj ) also returns the width
            %   of the fracture line in pixels.
            %   
            %   [Breadth, Width, Theta] = evaluate( obj ) also returns the
            %   angle of each wire with respect to the fracture plane.
            %   
            %   See also PSHF, HUMERUS/DEFINEFRACTURE, WIRE/DEFINEWIRE.
            %==============================================================
            
            % Do not proceed without the fracture and wire coordinates.
            narginchk( 1, 2 );
            Breadth	= struct( 'Ratio', NaN, 'Spacing', NaN, 'MM', NaN );
            Width  = NaN;
            Theta   = NaN;
            humerus	= obj.get( 'Humerus' );
            wires	= obj.get( 'Wire' );
            iemptywires = cellfun( @length, wires( : ).get( 'Boundary' ) ) == 0;
            if isempty( humerus.get( 'Fracture' ).get( 'Boundary' ) ) ||...
                    sum( iemptywires ) > 1
                return
            end
            wires( iemptywires ) = [];
            nWires  = length( wires );
            intersectionXY	= NaN( nWires, 2 );
            fractureXY	= humerus.get( 'Fracture' ).get( 'Boundary' );
            Width	= pdist( ( fractureXY ), 'Euclidean' );
            wireEQ = cell( nWires, 1 );
            wireXY  = cell( nWires, 1 );
            breadth	= NaN( nWires, nWires );
            wireVectors = NaN(nWires, 3 );
            Theta   = NaN( nWires, 1 );
            
            % Deduce the general direction of the wires.
            directionx = cell( nWires, 1 );
            for idx = 1:nWires
                wires( idx ).computeGeometry();
                wireEQ{ idx }	= wires( idx ).get( 'Equation' );
                wireXY{ idx }   = wireEQ{ idx }( 0:.01:1 );
                if wireXY{ idx }( 1, 2 ) > wireXY{ idx }( end, 2 )
                    wireXY{ idx }   = flipud( wireXY{ idx } );
                end
                wx	= wireXY{ idx }( [1 end], 1 ); % tip to base
                dx	= diff( wx );
                if dx > 0
                    directionx{ idx }	= 'L';
                elseif dx < 0
                    directionx{ idx }	= 'R';
                else
                    directionx{ idx }	= NaN;
                end
            end
            if all( contains( directionx, 'R' ) )
                direction = 'R';
            elseif all( contains( directionx, 'L' ) )
                direction = 'L';
            else
                direction = NaN;
            end
            
            % Gotta sort out the base/tip issue - for now, assume larger y is always the tip.
            wireTips	= cell2mat( vertcat( wires(:).get( 'Tip' ) ) );
            wireBases   = cell2mat( vertcat( wires(:).get( 'Base' ) ) );
            for idx = 1:nWires 
                if wireTips( idx, 2 ) > wireBases( idx, 2 )
                    wireTips( idx, : ) = wireBases( idx, : );
                end
            end
            
            % Sort wires lateral to center to medial.
            [sy, sx] = size( obj.get( 'Parent' ).get( 'Image' ) );
            if direction == 'R'
                % Smallest angle => medial wire.
                [thTip, rhTip] = cart2pol( wireTips( :, 1 ), -1 * ( wireTips( :, 2 ) - sy ) );
                [~, ithTip]	= sort( thTip, 'Ascend' );
                
            else %direction == 'L'
                % Largest angle: medial wire.
                [thTip, rhTip] = cart2pol( wireTips( :, 1 ) + sx, ( wireTips( :, 2 ) + sy ) );
                [~, ithTip]	= sort( thTip, 'Descend' );
%             else
%                 errordlg( 'Need to debug -- figuring out which wire is medial and which is lateral but need a direction is deduced');
            end
            
            % Compute the location of each wire's fracture plane intersection... 
            % *****TO-DO: if the wires go beyond the fracture line, the breadth should be negative or something.
            for idx = 1:nWires
                if isempty( wireEQ{ ithTip( idx ) } )
                    continue
                end
                interSectionPointXY	= InterX( wireXY{ ithTip( idx ) }', fractureXY' );
                if isempty( interSectionPointXY )
                    continue
                end
                try
                    intersectionXY( ithTip( idx ), : )	= interSectionPointXY;
                catch
                    return
                end
            end
                        
            % Compute the linear breadth (in [px]) between wires at the fracture plane.
            for idx = 1:nWires
                for jdx = 1:nWires
                    intXY = vertcat( intersectionXY( ithTip( idx ), : ), intersectionXY( ithTip( jdx ), : ) );
                    if idx == jdx || idx < jdx || any( isnan( intXY( : ) ) )
                        continue
                    end
                    breadth( ithTip( idx ), ithTip( jdx ) ) = pdist( intXY, 'Euclidean' );
                end
            end
            if all( breadth( 1, :) == 0 )
                breadth   = tril( breadth, -1 );
            elseif all( breadth( end, :) == 0 )
                breadth   = triu( breadth, -1 );
            end
            breadth( isnan( breadth ) )	= 0;
            usb = vertcat( flipud( unique( breadth( : ) ) ), zeros( 3, 1 ) ); % Pad with zeroes in case not all wires intersect fracture.
            Breadth.Ratio	= round( usb( 1 ) / sum( Width ), 2 );
            if nWires == 3
                Breadth.Spacing	= round( usb( 3 ) / usb( 1 ), 2 ); % FYI: 1 - s( 2 ) == s( 3 )
            end
            if nWires == 3
                Breadth.MM  = vertcat( breadth( 2, 1 ), breadth( 3, 2 ), breadth( 3, 1 ) );
            else
                Breadth.MM  = sort( breadth, 'descend' );
            end
            % Compute the angle between each wire's intersection and the fracture plane.
            for idx = 1:nWires
                if isempty( wireEQ{ idx } )
                    continue
                end
                wireVectors( idx, : )	= horzcat( wireTips( ithTip( idx ), : ) -...
                    intersectionXY( ithTip( idx ), : ), 0 );
            end
            count = 1;
            for idx = 1:nWires-1
                for jdx = ( idx+1 ):nWires
                    Theta( count ) = atan2( norm( cross( wireVectors( idx, : ), wireVectors( jdx, : ) ) ),...
                        dot( wireVectors( idx, : ), wireVectors( jdx, : ) ) ) * 180/pi;
                    count = count + 1;
                end
            end
%             Theta( 2 ) = atan2( norm( cross( wireVectors( 1, : ), wireVectors( 3, : ) ) ),...
%                 dot( wireVectors( 1, : ), wireVectors( 3, : ) ) ) * 180/pi;
%             Theta( 3 ) = atan2( norm( cross( wireVectors( 2, : ), wireVectors( 3, : ) ) ),...
%                 dot( wireVectors( 2, : ), wireVectors( 3, : ) ) ) * 180/pi;
        end
        
        function resetProcedure( obj )
            %RESETPROCEDURE Reset state of PSHF object to default.
            %	RESETPROCEDURE( obj ) returns the updated object with its
            %	Femur and Wire objects returned to their default value.
            %   
            %   See also PSHF, RESETHUMERUS, RESETWIRE.
            %==============================================================
            
            obj.resetHumerus();
            obj.resetWire( 1:numel( obj.get( 'Wire' ) ) );
            obj.resetChildren();
            obj.resetParent();
        end
        function resetHumerus( obj )
            %RESETHUMERUS Reset Humerus field of PSHF object.
            %   RESETHUMERUS( obj ) returns the updated object with its
            %	'Humerus' field returned to its default value.
            %   
            %   See also RESETPROCEDURE, RESETWIRE, RESETTAG.
            %==============================================================
            
            if ~isempty( obj.get( 'Humerus' ) )
                obj.get( 'Humerus' ).delete()
            end
            obj.set( 'Humerus', Humerus( obj ) ); %#ok<CPROP>
        end
        function resetWire( obj, iw )
            %RESETWIRE Reset Wire field of PSHF object.
            %   RESETWIRE( obj ) returns the updated object with its
            %	'Femur' field returned to its default value.
            %   
            %   See also PSHF, RESETPROCEDURE, RESETFEMUR, RESETTAG.
            %==============================================================
            
            wires   = obj.get( 'Wire' );
            if isempty( wires )
                return
            end
            for idx = 1:numel( iw )
                newWire = Wire( obj, 'Tag', wires( iw( idx ) ).get( 'Tag' ) ); %#ok<CPROPLC>
                wires( iw( idx ) ).delete()
                wires( iw( idx ) )	= newWire;
            end
            obj.set( 'Wire', wires );
        end
        function resetTag( obj )
            %RESETTAG Reset Tag field of PSHF object.
            %   RESETTAG( obj ) returns the updated object with its
            %	'Tag' field returned to its default value.
            %   
            %   See also PSHF, RESETPROCEDURE, RESETHUMERUS, RESETWIRE.
            %==============================================================
            
            obj.set( 'Tag', 'PSHF' );
        end
        
        function situateWires( obj )
            %SITUATEWIRES Reorder wireXY's such that tips are all "near" each other.
            %   SITUATEWIRES( obj ) returns the updated object with its
            %	'Wire' field updated such that all the wires' tips are
            %	nearer to each other than they are to the wires' bases.
            %   
            %   See also PSHF, RESETPROCEDURE, RESETFEMUR, RESETTAG.
            %==============================================================
            
            % Create clusters according to one wire's base and tip.
            wires	= obj.get( 'Wire' );
            if sum( cellfun( @isempty, wires.get( 'Equation' ) ) ) > 1
                return
            end
            wireXY  = wires.generateXY();
            X   = reshape( permute( wireXY, [2 1 3] ), size( wireXY, 2 ), [] )';
            nWires  = numel( wires );
            baseTip	= NaN( size( X, 1 ), 1 );
            [baseTip( 1:2 ), cXY, ~, ~]	= kmeans( wireXY( :, :, 1 ), 2 );
            ibaseTip    = 3;
            for idx = 2:nWires
                cXY_distance	= NaN( 2, 2 );
                for jdx = 1:2
                    for kdx = 1:2
                    cXY_distance( jdx, kdx )	= pdist( vertcat( cXY( jdx, : ),...
                         wireXY( kdx, :, idx ) ), 'Euclidean' );
                    end
                end
                [~, clusters]	= min( cXY_distance, [], 2 );
                if diff( clusters ) == 0
                    if cXY_distance( 1, 1 ) < cXY_distance( 2, 1 )
                        clusters	= vertcat( 1, 2 );
                    else
                        clusters	= vertcat( 2, 1 );
                    end
                end
                baseTip( ibaseTip:ibaseTip+1 )	= clusters;
                ibaseTip	= ibaseTip + 2;
                cXY	= vertcat( mean( X( baseTip == 1, : ) ),...
                    mean( X( baseTip == 2, : ) ) );
            end
            
            % Reorient wires based on the clustering.
            iBase	= find( baseTip == 1 );
            iTip	= find( baseTip == 2 );
            if numel( iBase ) ~= numel( iTip )  % Temp debug
                return
            end
            for idx = 1:nWires
                wires( idx ).setBase( X( iBase( idx ), : ) );
                wires( idx ).setTip( X( iTip( idx ), : ) );
            end
        end
    end
end
