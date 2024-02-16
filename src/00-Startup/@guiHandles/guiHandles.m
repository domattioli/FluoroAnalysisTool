classdef guiHandles < handle & matlab.mixin.SetGet
    %GUIHANDLES Stores handles of a figure object.
    %   For keeping track of handles, e.g. easier searching.
    %   
    %   See also
    %======================================================================
    
    properties ( SetAccess = private, GetAccess = public, Hidden = false )
        Current	= struct();	% Current state of GUI.
    end
    properties ( SetAccess = public, GetAccess = public, Hidden = false )
        Project  = [];      % User-selected project directory.
        TCP  = [];          % Current TCP\IP connection object.
    end
    
    methods
        function obj = guiHandles( varargin )
            %GUIHANDLES Constructs an instance of this class.
            %   Creates an empty structure.
            %
            % See also GUIHANDLES.
            %==============================================================
            if nargin > 0
                p	= inputParser;
                st  = dbstack;
                constructorName = st(1).name;
                p.FunctionName	=  constructorName( 1:strfind( constructorName, '. ' ) - 1 );
                p.addParameter( 'Current', obj.Current, @(x) isstruct( x ) ); % Don't know the correct type.
                p.addParameter( 'Project', obj.Project, @(x) ischar( x ) );
                p.addParameter( 'TCP', obj.Project, @(x) ischar( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 - 1 );
                
                props = fieldnames( p.Results );
                for n = 1:numel( props )
                    obj.( props{ n } ) = p.Results.( props{ n } );
                end
            end
        end
        
        function gh = createNew( gh, newHandle )
            %CREATENEW Create new field in gh.Current struct.
            %   Creates an empty field within the object's structure.
            %
            % See also GUIHANDLES.
            %==============================================================
            
            % Get new handle's name, append to current gh handle struct.
            name    = newHandle.get( 'Tag' );
            name( isspace( name ) )	= '_';
            gh.Current(:).( name )	= newHandle;
        end
    end
end

