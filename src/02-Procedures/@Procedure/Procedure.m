classdef Procedure < handle & matlab.mixin.SetGet
    %PROCEDURE Class for defining procedures to operate on Fluoro objects.
    %   Parent class, where each subclass is a specific type of procedure
    %   that operates on data provided by a Fluoro class instance.
    %   
    %   Methods for PROCEDURE (so far) are:
    %       - PREDICTWIRE, for predicting the wire (these are all wire nav.
    %       procedures).
    %       - SAVE, for initiating a generic save of the data.
    %   
    %   See also FLUORO, DHS, PSHF,
    %======================================================================
    
    properties ( GetAccess = public, SetAccess = public, Hidden = false )
        Name = [];
        Tag = 'Procedure';
    end
    properties ( GetAccess = public, SetAccess = protected, Hidden = true )
        Children = []
        Parent = [];
    end
    
    methods
        function obj = Procedure( varargin )	% Constructor
            %PROCEDURE Construct an instance of this PROCEDURE class.
            %   Detailed explanation goes here
            %   
            %   See also PROCEDURE/DELETE, PROCEDUREREADY.
            %==============================================================
            
            if nargin > 0
                p	= inputParser;
                st  = dbstack;
                constructorName = st(1).name;
                p.FunctionName	=  constructorName( 1:strfind( constructorName, '.' ) - 1 );
                p.addRequired( 'Parent', @(x) isa( x, 'Fluoro' ) );
                p.addParameter( 'Name', obj.Name, @(x) validateattributes( x, { 'char' }, { 'nonempty' } ) );
                p.addParameter( 'Tag', obj.Tag, @(x) ischar( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 + 1 );
                props = fieldnames( p.Results );
                for n = 1:numel( props )
                    obj.( props{ n } ) = p.Results.( props{ n } );
                end
            end
        end
        
        function addChild( obj, child )
            %ADDCHILD Append FluoroObject child to FluoroObject's children.
            %   ADDCHILD( obj, child ) updates the list of children.
            %   
            %   See also REMOVECHILD, FLUOROOBJECT.
            %==============================================================
            
            obj.set( 'Children', vertcat( child, obj.get( 'Children' ) ) );
        end
        
        function delete( obj )	% Destructor
            %DELETE Destructor for Procedure object.
            %   DELETE( obj ) deletes Procedure data.
            %
            %   See also PROCEDURE.
            %==============================================================
            delete( obj.get( 'Children' ) );
            delete( obj );
        end
        
        function ready = procedureReady( obj )
            %PROCEDUREREADY Test procedure for result computations.
            %	ready = PROCEDUREREADY( obj ) returns true if the
            %	procedure's properties are all filled sufficiently for
            %	computation. This is simply testing if the fields of the
            %	object are not empty. Returns false otherwise.
            %   
            %   See also PROCEDURE.
            %==============================================================
            
            fn  = fieldnames( obj );
            for idx = 1:numel( fn )
                if isempty( obj.( fn{ idx } ) )
                    ready  = false;
                    return
                end
            end
            ready  = true;
        end
        
        function replaceChild( obj, ichild, newChild )
            obj.Children( ichild )	= newChild;
        end
        function obj = resetProcedure( obj  )
            %RESETPROCEDURE Resets state of Procedure Object to default.
            %	RESETPROCEDURE( obj ) returns the updated object with its
            % fields returned to their default value.
            %   
            %   See also PROCEDURE, RESETCHILDREN, RESETPARENT, RESETTAG.
            %==============================================================
            
            obj.resetChildren();
            obj.resetParent();
            obj.resetTag();
        end
        function resetChildren( obj )
            %RESETCHILDREN Resets Children field of Procedure Object.
            %	RESETCHILDREN( obj ) returns the updated object with its
            %	'Children' field returned to its default value.
            %   
            %   See also RESETPROCEDURE, RESETPARENT, RESETTAG.
            %==============================================================
            
            obj.Children	= [];
        end
        function resetParent( obj )
            %RESETPARENT Resets Parent field of Procedure Object.
            %	RESETPARENT( obj ) returns the updated object with its
            %	'Parent' field returned to its default value.
            %   
            %   See also RESETPROCEDURE, RESETCHILDREN, RESETTAG.
            %==============================================================
            
            obj.Parent	= [];
        end
        function resetTag( obj )
            %RESETTAG Resets Tag field of Procedure Object.
            %	RESETTAG( obj ) returns the updated object with its 'Tag'
            %	field returned to its default value.
            %   
            %   See also RESETPROCEDURE, RESETCHILDREN, RESETPARENT.
            %==============================================================
            
            obj.Tag	= 'Procedure';
        end
    end
end

