function out = analyzePSHFCases( varargin )
%ANALYZEPSHFCASES Perform PSHF post-process analysis.
%   out = ANALYZEPSHFCASES( fileNames ) returns an nx6 matrix containing
%   the evaluated 6 metrics on all inputted n pediatric elbow cases.
%   
%   out = ANALYZEPSHFCASES( fileNames, 'Plot', false ) plots all AP and
%   Lateral images in the cases. Plots are paused for 1 second before
%   resuming. Alternative, a valid input is a pause duration (double).
%   Default value is false.
%   
%   out = ANALYZEPSHFCASES( fileNames, 'Save', 'myfolder' ) saves the
%   images to the specified directory. Default is the current working
%   directory. If 'Save' is specified but 'Plot' is not, Plot is turned on
%   with a zero pause.
%
%   See also ANALYZEDHSCASES.
%==========================================================================

p	= inputParser;
p.addRequired( 'FileNames', @(x) iscell( x ) || ischar( x ) );
p.addParameter( 'Plot', false, @(x) isnumeric( x ) || islogical );
p.addParameter( 'Save', pwd, @(x) ischar( x ) );
p.parse( varargin{:} );
narginchk( 1, numel( p.Parameters )*2 - 1 );
fileNames	= p.Results.FileNames;
plotter	= p.Results.Plot;
saver	= p.Results.Save;

% Iterate through each result file.
nFiles  = numel( fileNames );
empties = cell( nFiles, 2 );
caseID  = NaN( nFiles, 1 );
out	= NaN( nFiles, 6 );
for idx = 1:nFiles
    fluoros = Fluoro.parseText( Fluoro.read( fileNames{ idx } ) );
    for jdx = 1:numel( fluoros )
        % Reevaulate the data.
        pshf	= fluoros( jdx ).get( 'Procedure');
        [Breadth, Width, Theta, ithTip]	= pshf.evaluate();
        if numel( Theta ) < 3
            Theta( 3 ) = NaN;
        elseif numel( Theta ) > 3
            errordlg( 'This PSHF Case has more than 3 computed theta values.' );
        end
        if strcmpi( 'L', fluoros( jdx ).get( 'View' ) )
            out( idx, 2 )	= Breadth.Ratio;
        elseif strcmpi( 'AP', fluoros( jdx ).get( 'View' ) )
            out( idx, 1 )	= Breadth.Ratio;
            out( idx, 3 )	= Breadth.Spacing;
            out( idx, 4:6 ) = transpose( Theta );
            [~, surgeryCaseID]	= fileparts( fluoros( jdx ).get( 'CaseID' ) );
            caseID( idx )	= str2double( surgeryCaseID( 1:3 ) );
        else
            [~, folder] = fileparts( fluoros( jdx ).CaseID );
            empties{ idx, 1 }	= fullfile( folder, fluoros( jdx ).FileName );
        end
        
        % (Optional) Plot in figure, save as image.
        if ( all( saver ~= 0 ) || plotter ~= 0 ) && strcmpi( 'AP', fluoros( jdx).get( 'View' ) )
            f = figure;
            if plotter == 0
                f.WindowState = 'Minimized';
                plotter	= 0;
            end
            imshow( fluoros( jdx ).get( 'Image' ), [] );
            hold on;
            frac = pshf.get( 'Humerus' ).get( 'Fracture' );
            fxy = frac.get( 'Boundary' );
            plot( fxy( :, 1 ), fxy( :, 2 ), 'g.-' );
            wires = pshf.get( 'Wire' );
            iemptywires = cellfun( @length, wires( : ).get( 'Boundary' ) ) == 0;
            wires( iemptywires ) = [];
            colors ={ 'm', 'c', 'b' };
            for kdx = 1:length( wires )
                w = wires( ithTip( kdx ) );
                eq = w.get( 'Equation' );
                wxy = eq( 0:0.01:1 );
                plot( wxy( :, 1 ), wxy( :, 2 ), 'color', colors{ kdx }, 'LineStyle', '-' );
            end
            leg = legend( 'Fracture', 'Wire 1', 'Wire 2', 'Wire 3', 'Location', 'NorthWest' );
            leg.set( 'Interpreter', 'Latex' );
            if all( saver ~= 0 )
                frame = getframe( gca );
                [~, casename] = fileparts( fluoros( jdx ).get( 'CaseID' ) );
                imwrite( frame.cdata, strcat( fullfile( saver, casename ),...
                    '_', fluoros( jdx ).get( 'View' ), '.tif' ) );
            end
            close( f );
            if plotter ~= 0
                pause( plotter );
            end
        end
    end
end
out   = horzcat( out, ones( nFiles, 1 ) );

