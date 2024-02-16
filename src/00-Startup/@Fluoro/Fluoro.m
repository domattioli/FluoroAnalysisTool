classdef Fluoro < FluoroObject
    %FLUORO Object for fluoro images.
    %   Once we interpet the DICOM, we need to store our data.
    %   
    %   See also FLUORO, FLUOROOBJECT, WIRE, FEMUR, HUMERUS.
    %======================================================================
    %{
    properties
    %
    %CASEID ....
    %   CASEID is a
    %
    %   See also FILENAME, FILENAME, FEMUR/NECK, FEMUR/SHAFT.
    HEAD;
    end
    %}
    
    properties ( GetAccess = public, SetAccess = protected, Hidden = false )
        % Necessary for instantiation.
        CaseID;     % Folder holding all DICOM files of surgery.
        FileName;	% DICOM file name plus extension.
    end
    properties ( GetAccess = public, SetAccess = protected, Hidden = true )
        % Derived, never assigned by uer.
        FullFileName;	% DICOM full file name.
        Image;       	% DICOM FLUORO image data.
    end
    properties ( GetAccess = public, SetAccess = public, Hidden = false )
        % Not necessary to instantiation, but are assignable.
        Procedure;	% FLUORO analysis procedure.
        Project; 	% Project directory.
        Side;    	% Anatomical side of body in FLUORO.
        Surgeon;	% Surgeon performing in FLUORO.
        User;    	% FLUORO analyist.
        View;    	% AP or Lateral.
    end
    
    methods
        function obj = Fluoro( varargin )   % Constructor
            %FLUORO Construct an instance of a FLUORO object.
            %   Detailed explanation goes here
            %
            %   See also FLUORO.
            %==============================================================
            
            if nargin > 0
                p	= inputParser;
                st  = dbstack;
                constructorName = st(1).name;
                p.FunctionName	=  constructorName( 1:strfind( constructorName, '. ' ) - 1 );
                p.addRequired( 'FileName', @(x) ischar( x ) );
                p.addParameter( 'CaseID', obj.defaultCaseID(), @(x) ischar( x ) );
                p.addParameter( 'Display', obj.defaultDisplay(), @(x) isa( x, 'matlab.graphics.primitive.Image' ) );
                p.addParameter( 'Parent', obj.defaultParent(), @(x) isa( x, 'matlab.graphics.axis.Axes' ) );
                p.addParameter( 'Procedure', obj.defaultProcedure() );
                p.addParameter( 'Project', obj.defaultProject(), @(x) ischar( x ) );
                p.addParameter( 'Side', obj.defaultSide(), @(x) ischar( x ) || isempty( x ) );
                p.addParameter( 'Surgeon', obj.defaultSurgeon(), @(x) ischar( x ) );
                p.addParameter( 'Tag', obj.defaultTag(), @(x) ischar( x ) );
                p.addParameter( 'User', obj.defaultUser(), @(x) ischar( x ) || iscell( x ) || isempty( x ) );
                p.addParameter( 'View', obj.defaultView(), @(x) ischar( x ) );
                p.parse( varargin{:} );
                narginchk( 0 , numel( p.Parameters )*2 - 1 );
                props = fieldnames( p.Results );
                for n = 1:numel( props )
                    obj.( props{ n } ) = p.Results.( props{ n } );
                end
                if ~isempty( obj.FileName )
                    if size( obj.Image, 3 ) == 3
                        obj.Image   = rgb2gray( obj.Image );
                    end
                end
                
                % Exit constructor if the basic properties aren't init.
                if sum( cellfun( @isempty, {obj.get( 'CaseID' ), obj.get( 'FileName' ) } ) ) > 0
                    return
                end
                obj.get( 'Surgeon' );   % Can derive if it exists in the dicom metadata.
                obj.set( 'Tag', horzcat( 'Fluoro: ', num2str( length( findall( get( ...
                    obj.get( 'Parent' ), 'Children' ), 'Type', 'Fluoro' ) ) + 1 ) ) );
            end
        end
        
        function out = buildOutput( obj )
            %BUILDOUTPUT Construct output struct for saving data.
            %   out = BUILDOUTPUT( obj ) returns a struct comprised of a
            %   relevant fluoro data to be saved.
            %   
            %   See also FLUORO.
            %==============================================================
            
            % Initialize output so that you can always save something.
            out	= struct( 'CaseID', obj.get( 'CaseID' ),...
                'FileName', [], 'Surgeon', [], 'DateTimeStamp', [],...
                'View', obj.get( 'View' ), 'Procedure', [], 'Result', [],...
                'Side', obj.get( 'Side' ), 'Tag', obj.get( 'Tag' ),...
                'User', [], 'Modified', datestr( datetime( 'now' ) ) );
            
            % Assemble output structure as variant of data object.
            if ~isempty( obj.get( 'FileName' ) )
                out.FileName    = obj.get( 'FileName' );
                dicom   = dicominfo( obj.get( 'FullFileName' ) );
                out.Surgeon	= obj.get( 'Surgeon' );
                try
                    out.DateTimeStamp   = datestr( datetime( [dicom.ContentDate,...
                        ', ', dicom.ContentTime], 'InputFormat', 'yyyyMMdd, HHmmss' ) );
                    if ~isempty( dicom.PerformingPhysicianName.FamilyName )
                        out.Surgeon	= horzcat(...
                        dicom.PerformingPhysicianName.FamilyName, ', ',...
                        dicom.PerformingPhysicianName.GivenName( 1 ) );
                    end
                catch
                end
            end
            if ~isempty( obj.get( 'Procedure' ) )
                out.Procedure   = obj.get('Procedure').get( 'Name' );
            end
            if ~isempty( obj.get( 'User' ) ) && isa( obj.get( 'User' ), 'cell' )
                userStr	= obj.get('User');
                out.User	= [userStr{1}, ', ', userStr{ 2 }];
            end
        end
        
        function [success, initialE] = checkPlot( obj, fh, resetLimits )
            %CHECKPLOT Make sure plotted DICOM is same as selected DICOM.
            %   success = checkPlot( data fh ) returns 'false' if the
            %   currently-selected DICOM in the File List is not the same
            %   as the one plotted in the GUI's (fh) main axis.
            %
            %   success = checkPLOT(data, fh, resetLimits) will reset the
            %   axis limits if the second input is true and if the prior
            %   condition holds. The default value (nargin == 1) assumes
            %   that a reset is desired.
            %
            %   [success, initialE] = checkPLOT(data, fh, resetLimits) also
            %   returns the initial state of all relevant procedure buttons
            %   in the GUI and disables them.
            %
            %   See also FLUORO, RESETAXISLIMITS.
            %==============================================================
            
            % Check input.
            if nargin == 2
                resetLimits	= true;
            end
            
            % Ensure DICOM plot exists.
            success	= false;
            if strcmp( 'off' , obj.get( 'Display' ) )
                printToLog( fh, ['Cannot define ''', obj.get( 'Procedure' ).get( 'Name' ),...
                    ''' until currently-selected DICOM is Plotted'], 'Error' );
            else
                success	= true;
                if resetLimits
                    obj.resetAxisLimits();
                end
            end
            initialE    = [];
            if success
                % Temporarily disable all ui buttons.
%                 initialE    = toggleUIControls( fh, 'Inactive' );
            end
        end
        
        function c = defaultCaseID( obj );      c   = '';   end	%#ok<MANU>
        function f = defaultFileName( obj );	f   = '';   end %#ok<MANU>
        function p = defaultProcedure( obj );	p   = '';   end %#ok<MANU>
        function p = defaultProject( obj );     p   = '';   end %#ok<MANU>
        function s = defaultSide( obj );        s   = '';   end %#ok<MANU>
        function u = defaultUser( obj );        u   = {};   end %#ok<MANU>
        function v = defaultView( obj );        v   = '';   end %#ok<MANU>
        
        function value = get.FullFileName( obj )
            % Assumes that the file is a (.dcm) dicom.
            value   = strcat( fullfile( obj.get( 'CaseID' ), obj.get( 'FileName' ) ), '.dcm' );
        end
        function value = get.Image( obj )
            % Don't store image - probably wasteful. Just load it.
            value   = dicomread( obj.get( 'FullFileName' ) );
        end
        function value = get.Surgeon( obj )
            value = obj.Surgeon;
            if isempty( value ) % Check and derive fromDICOM metadata.
                dicom   = dicominfo( obj.get( 'FullFileName' ) );
                surgeonData	= dicom.PerformingPhysicianName;
                if isempty( surgeonData.FamilyName )
                    value	= char('');
                    
                else
                    value   = strcat( surgeonData.FamilyName, ', ');
                    try
                        value   = strcat( value, surgeonData.GivenName( 1 ) );
                    catch
                        value( end-1:end ) = [];
                    end
                end
                obj.set( 'Surgeon', value );
            end
        end
        
        function plt = plot( obj )
            %PLOT Plot fluoro object.
            %   plt = PLOT( obj ) returns the image object plotted into the
            %   current axis. PLOT also adjusts the 'Display' and 'Parent'
            %   properties of obj.
            %
            %   See also PLOT, FLUORO/DELETE.
            %==============================================================
            
            % Prep for plotting.
            narginchk( 0, 1 );
            ax  = obj.get( 'Parent' );
            if isempty( ax )
                ax  = gca;
                obj.set( 'Parent', ax );
            end
            ax.set( 'NextPlot', 'Replace' );
            
            % Image processing.
               % Decent IP. Should filter in the frequency domain to remove high frequencies (low-pass filter).
               % Could also use imdiffusefilt for anisotropic diffusion.
            img	= obj.get( 'Image' );
%             img = imsharpen( medfilt2( img ), 'Radius', 2, 'Amount', 2 );
            
            % Plot fluoro image.cla( ax );
            plt	= imshow( img, 'parent', ax, 'InitialMagnification', 'Fit', 'DisplayRange', [] );
            obj.resetAxisLimits();
            
            % Set display.
            obj.set( 'display', plt );
        end
        
        function resetAxisLimits( obj )
            %RESETAXISLIMITS Reset axis limits.
            %   RESETAXISLIMITS( obj ) adjusts axis limits of the main axis
            %   in which the Fluoro is plotted in, such that the x and y
            %   limits correspond to the image's size.
            %
            %   See also FLUORO/PLOT.
            %===============================================================
            
            % Update/reset axis.
            ax  = obj.get( 'Parent' );
            img     = obj.get( 'Image' );
            imgSize	= size( img );
            ax.set( 'xlim', [0 imgSize( 1 )], 'ylim', [0 imgSize( 2 )] );
            zoom( 'direction', 'in' );
            zoom off;
        end
        function resetCaseID( obj );    obj.CaseID	= obj.defaultCaseID();          end
        function resetFileName( obj );  obj.FileName	= obj.defaultFileName();	end
        function resetProcedure( obj ); obj.Procedure	= obj.defaultProcedure();	end
        function resetProject( obj );   obj.Project	= obj.defaultProject();         end
        function resetSide( obj );      obj.Side	= obj.defaultSide();            end
        function resetSurgeon( obj );   obj.Surgeon	= obj.defaultSurgeon();         end
        function resetUser( obj );      obj.User	= obj.defaultUser();            end
        function resetView( obj );      obj.View	= obj.defaultView();            end
        
        function [obj, success] = save( obj )
            %SAVE Save current state of Fluoro.
            %   success = SAVE( obj ) returns a logical regarding the
            %   success of the read - a successful operation returns true.
            %   This function will write an empty JSON formatted line of
            %   text to a .json text file named similarly to the FileName
            %   field of the object's parent.
            %   
            %   SAVE operates under the assumption that the passed object
            %   contains populated CaseID and FileName fields.
            %   
            %   See also READ, BUILDOUTPUT.
            %==============================================================
            
            % Build a struct for writing to a text file, then save it.
            success = true;
            try
                writableData	= obj.buildOutput();
                if ~isempty( obj.get( 'Procedure' ).get( 'Name' ) )
                    writableData.Result	= obj.get( 'Procedure' ).compileResult();
                end
                
                % Identify saving directory and name, view.
                if isempty( obj.get( 'Project' ) )
                    saveDir	= obj.get( 'CaseID' );
                    obj.set( 'Project', saveDir );
                else
                    saveDir	= obj.get( 'Project' );
                end
                [~, folderName] = fileparts( obj.get( 'CaseID' ) );
                saveFileName	= fullfile( saveDir, strcat( folderName, '_', 'Results.json' ) );
                
                % Write results file in an encoded JSON format.
                TEXT	= jsonencode( writableData );
                fid	= obj.writeResult( saveFileName, TEXT );
                if fid == -1
                    success = false;
                end
            catch
                success = false;
                return
            end
        end
        
        function fid = writeResult( obj, saveFullFileName, TEXT )
            %WRITERESULT Write .json text to results.json text file.
            %   fid = writeResult( fh, saveFullFileName, TEXT ) returns the
            %   file identifier fid, the values of which correspond to
            %   classic file MATLAB. interaction.
            %
            %   See also FOPEN, FWRITE, SAVE.
            %==============================================================
            
            % Given the object, determine how many fluoros are in case.
            d   = dir( obj.get( 'CaseID' ) );
            fileList    = { d.name }';
            fileList( cell2mat( { d.isdir }' ) |...
                contains( fileList, 'DS_Store' ) |...
                contains( fileList, '_Results.json' )|...
                contains( fileList, 'Thumbs.db' ) )	= [];
            numFiles    = length( fileList );
            
            % Write new data to Results.json file; create one if doesn't already exist.
            [filePath, fileName, ext]	= fileparts( saveFullFileName );
            saveDir	= dir( filePath );
            currentFile	= find( contains( fileList, strcat( obj.get( 'FileName' ), '.dcm' ) ) );
            fileExists  = any( ismember( { saveDir.name }', strcat( fileName, ext ) ) );
            if fileExists
                % Read in all existing data, then overwrite current file's line.
                [existingData, ~]	= obj.read( saveFullFileName, numFiles );
                fid	= fopen( saveFullFileName, 'wt' );
                for idx = 1:numFiles
                    if idx == currentFile
                        fprintf( fid, '%s\n', TEXT );
                    else
                        fprintf( fid, '%s\n', existingData{ idx } );
                    end
                end
            else
                % File does not exist; initialize one wrt all DICOMS in folder.
                fid	= fopen( saveFullFileName, 'wt' );
                for idx = 1:numFiles
                    if idx == currentFile
                        fprintf( fid, '%s\n', TEXT );
                    else
                        fprintf( fid, '\n' );
                    end
                end
            end
            fclose( fid );
        end
    end
    methods ( Static = true )
        function fluoro = parseJSON( filename, numFiles )
            %PARSEJSON Read saved state of Fluoro from .json file.
            %   fluoro = PARSEJSON( filename ) returns an array of Fluoro
            %   objects parsed from the char array of json-formatted data.
            %   
            %   PARSEJSON( filename ) is the same functionality as
            %   parseText( read( filename ) ).
            %   
            %   PARSEJSON operates under the assumption that the passed
            %   object contains populated CaseID and FileName fields.
            %   
            %   See also READ, PARSETEXT, FLUORO.
            %==============================================================
            
            narginchk( 1, 2 )
            if nargin == 1
                fluoro = Fluoro.parseText( Fluoro.read( filename ) );
            elseif nargin == 2
                fluoro = Fluoro.parseText( Fluoro.read( filename, numFiles ) );
            end
        end
        
        function fluoro = parseText( txt )
            %PARSETEXT Read saved state of Fluoro.
            %   fluoro = PARSETEXT( txt ) returns an array of Fluoro
            %   objects parsed from the char array of json-formatted data.
            %   
            %   PARSETEXT operates under the assumption that the passed
            %   object contains populated CaseID and FileName fields.
            %   
            %   See also PARSEJSON, READ, FLUORO.
            %==============================================================
            
            fluoro  = [];
            for idx = 1:numel( txt )
                if isempty( txt{ idx } )
                    continue
                end
                f	= jsondecode( txt{ idx } );
                data	= Fluoro( f.FileName, 'CaseID', f.CaseID, 'Side', f.Side,...
                    'Surgeon', f.Surgeon, 'Tag', f.Tag, 'User', f.User, 'View', f.View );
                
                % Deal with primary fractured-bone.
                switch f.Procedure
                    case 'Pediatric Supracondylar Humerus Fracture'
                        data.Procedure	= PSHF( data );
                        data.Procedure.Humerus.Fracture.Boundary = f.Result.Fracture;
                        
                    case 'DHS Tip-Apex Distance'
                        data.Procedure	= DHS( data );
                        [x, y] = generateEllipsePoints( f.Result.Femoral_Head );
                        data.Procedure.Femur.Head.Boundary	= vertcat( x, y )';
                        data.Procedure.Femur.Neck.Boundary	= f.Result.Femoral_Neck;
                        bxy	= data.Procedure.Femur.neckPerpendicularBisector( data.get( 'Side' ) );
                        data.Procedure.Femur.setTipApex( bxy( 2, : ) );
                    otherwise
                end
                
                % Deal with wire(s)
                for jdx = 1:numel( data.Procedure.Wire )
                    xStartEnd = f.Result.Wire( jdx ).XY;
                    if isempty( xStartEnd )
                        continue
                    end
                    offset  = f.Result.Wire( jdx ).PX_Width / 2;
                    B   = FluoroObject.centerline2Boundary( xStartEnd, offset );
                    BW  = FluoroObject.boundary2Mask( data.get( 'Image' ), B );
                    data.Procedure.Wire( jdx )	= Wire( data.Procedure,...
                        'Boundary', B, 'Mask', BW,...
                        'Tag', data.Procedure.Wire( jdx ).get( 'Tag' ),...
                        'WidthMM', f.Result.Wire( jdx ).MM_Width,...
                        'WidthPX', f.Result.Wire( jdx ).PX_Width );
                    
                    %%% Temporary.
                    if contains( 'DHS', data.Procedure.Name)
                        dists = NaN( 2, 1 );
                        for kdx = 1:2
                            dists( kdx ) = pdist( vertcat( xStartEnd( kdx, : ),...
                                 data.Procedure.Femur.get( 'TipApex' ) ), 'Euclidean' );
                        end
                        [~, isdists]	= sort( dists, 'ascend' );
                        data.Procedure.Wire( jdx ).setBase( xStartEnd( setdiff( 1:2, isdists( 1 )  ), : ) );
                        data.Procedure.Wire( jdx ).setTip( xStartEnd( isdists( 1 ), : ) );
                    end
                end
                fluoro  = vertcat( fluoro, data ); %#ok<AGROW>
            end
        end
        
        function [txt, nFiles] = read( filename, nFiles )
            %READ Read saved state of Fluoro.
            %   txt = READ( filename ) returns an Nx1 char array of text
            %   data following the successful reading from filename.json,
            %   where N is the number of Fluoros in the file.
            %   
            %   See also SAVE, PARSETEXT, BUILDOUTPUT.
            %==============================================================
            
            if nargin == 1
                nFiles = 1000;
            end
            fid	= fopen( filename, 'r' );
            if fid == -1
                errordlg( 'Invalid file name, cannot parse Fluoro file.' , 'Invalid Input' );
                return
            end
            txt	= cell( nFiles, 1 );
            idx = 1;
            while idx < nFiles
                txt{ idx } = fgetl( fid ); %% TO-DO: figure out how to prevent writing results files with one additional line at the end - this throws everything involving file reading off buy one.
                if feof( fid )
                    txt( idx+1:end )	= [];
                    nFiles  = idx;
                    break
                end
                idx = idx + 1;
            end
            fclose( fid );
        end
        
        function [fluoro, json] = mturk2Fluoro( filename )
            %MTURK2FLUORO Read saved state of Fluoro.
            %   txt = READ( filename ) returns an Nx1 char array of text
            %   data following the successful reading from filename.json,
            %   where N is the number of Fluoros in the file.
            %   
            %   See also SAVE, PARSETEXT, BUILDOUTPUT.
            %==============================================================
            
            if nargin == 1
                nFiles = 1000;
            end
            fid	= fopen( filename, 'r' );
            if fid == -1
                errordlg( 'Invalid file name, cannot parse Fluoro file.' , 'Invalid Input' );
                return
            end
            txt	= cell( nFiles, 1 );
            idx = 1;
            while idx < nFiles
                txt{ idx } = fgetl( fid ); %% TO-DO: figure out how to prevent writing results files with one additional line at the end - this throws everything involving file reading off buy one.
                if feof( fid )
                    txt( idx+1:end )	= [];
                    nFiles  = idx;
                    break
                end
                idx = idx + 1;
            end
            fclose( fid );
        end
        
    end
end

