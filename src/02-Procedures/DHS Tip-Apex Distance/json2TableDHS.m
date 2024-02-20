function [success, T] = json2TableDHS( fileNames, saveAsXLSX )
%JSON2TABLEDHS Convert saved Fluoro Analysis DHS data from .json to Table.
%   JSON2TABLEDHS( fileNames ) converts all fileNames from
%   FluoroAnalysisTool-formatted .json files to a table data structure,
%   formatted specifically to DHS.
%   
%   success = JSON2TABLEDHS( fileNames ) returns true if all files listed
%   in the fileNames input are successfully convertable to tables, i.e. the
%   data is not corrupt.
%   
%   [success, T] = JSON2TABLEDHS( fileNames ) returns the new table of
%   data, with each row corresponding to the inputted fileNames.
%   
%   [success, T] = JSON2TABLEDHS( fileNames, 'saveAsXLSX' ) will save the
%   table as an Excel file, where 'saveAsXLSX' must be true or false. T
%   will be saved to a prompted directory and titled 'DHS_data_table.xlsx'.
%   
%   See also FLUORO, SAVEDHS, JSON2TABLEPSHF.
%==========================================================================

% Input checks
narginchk( 1, 2 );
success	= false;
T   = [];
if ~iscell( fileNames )
    errordlg( 'FileNames must be stored as a cell array of char', 'Invalid Input' );
    return
end
if nargin == 2
   if saveAsXLSX
       saveDir	= uigetdir( fullfile( sourceCodeDirectory(), 'data' ), 'Select a directory to save your table to' );
       saveName = 'DHS_data_table.xlsx';
       if saveDir == 0
           noSave     = questdlg( 'Proceed without saving?', 'Invalid Directory', 'Yes', 'No', 'No' );
           if strcmpi( noSave, 'No' )
               saveDir	= uigetdir( fullfile( sourceCodeDirectory(), 'data' ), 'Select a directory to save your table to' );
           else
               saveName     = [];
               saveAsXLSX   = false;
           end
       end
   end
   
else
    saveAsXLSX  = false;
end
nargoutchk( 0, 2 );

% Initiate table output first as a cell.
cellT = { 'CaseID', 'FileName', 'Side', 'View',...
    'WEX', 'WEY', 'WTX', 'WTY', 'WWpx', 'WWmm', 'TAX', 'TAY', 'Analyst' };

% Iterate through each results file.
nFiles  = numel( fileNames );
try
    for idx = 1:nFiles
        cellOfJsons = Fluoro.read( fileNames{ idx } );
        jsonArrayAsFluoros = Fluoro.parseText( cellOfJsons );
        cellOfJsons( cellfun( @isempty, cellOfJsons ) ) = [];

        % Iterate through each image of this idx-result file.
        for jdx = 1:numel( jsonArrayAsFluoros )
            converted2Fluoro	= jsonArrayAsFluoros( jdx );
            [~, CaseID]  = fileparts( converted2Fluoro.get( 'CaseID' ) );
            FileName    = converted2Fluoro.get( 'FileName' );
            Side    = converted2Fluoro.get( 'Side' );
            View    = converted2Fluoro.get( 'View' );
            resultsDHS  = converted2Fluoro.get( 'Procedure' );
            wireObj    = resultsDHS.Wire;
            % Wire class doesn't currently retrieve the tip and base properly -
            % need to apply ad hoc approach.
            if ~isempty( wireObj.Boundary )
                foundWire = false;
                try
                    txt = jsondecode( cellOfJsons{ jdx } );
                    wireXY = txt.Result.Wire.XY;
                    foundWire = true;
                catch
                    try
                        wireXY  = wireObj.generateXY();
                        foundWire = true;
                    catch
                    end
                end
                if ~foundWire || isempty( wireXY )
                    wireXY  = NaN( 2, 2 );
                end
                if strcmpi( Side( 1 ), 'L' )
                    wireXY  = flipud( wireXY );
                end
                
                WWpx    = wireObj.get( 'WidthPX' );
                WWmm    = wireObj.get( 'WidthMM' );
            else
                wireXY  = NaN( 2, 2 );
                WWpx    = NaN;
                WWmm    = NaN;
            end
            femurObj   = resultsDHS.Femur;
            try
                TAXY	= femurObj.get( 'TipApex' );
            catch
                TAXY    = NaN( 2, 1 );  % No tip-apex found/annotated.
            end
            % [TAD, Theta]	= resultsDHS.evaluate();
            Analyst	= converted2Fluoro.get( 'User' );
            rowFilledOut    = { CaseID, FileName, Side, View,...
                wireXY( 1, 1 ), wireXY( 1, 2 ), wireXY( end, 1 ), wireXY( end, 2 ),... % Not confident that these are the base/tip
                WWpx, WWmm, TAXY( 1 ), TAXY( 2 ), Analyst };
            cellT   = vertcat( cellT, rowFilledOut );
            
            % Clear for next iteration.
            clear FileName Side View resultsDHS wireObj wireXY WWpx WWmm FemurObj TAXY Analyst;
        end
    end

    % Convert to table.
    T   = cell2table( cellT( 2:end, : ), 'VariableNames', cellT( 1, : ) );
    
    % Write to excel.
    if saveAsXLSX
        writetable( T, fullfile( saveDir, saveName ) );
    end
    success	= true;
    
catch
    success	= false;
    T   = [];
end

