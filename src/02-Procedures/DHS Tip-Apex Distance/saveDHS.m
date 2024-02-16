function saveDHS(hObject, ~, fh)
%SAVEDHS Create/updates .json for DHS results for this CaseID.
%   New file name 'Results.json'; if a file already exists, SAVEDHS
%   overwrites existing rows corresponding to DICOM files of a
%   folder/surgery. The columns contain all relevant processing information
%   (in JSON format).
%   
%   See also PSHF.
%==========================================================================

% Get fluoro data -- saved as the userdata in saveData object.
[data, ~, fhHandles]	= getFluoroData(fh);
%%%%%%%%%%%%%%%%%% Need to fix the output for the Procedure field -- it's got no spaces.
panelDHS	= findobj(fhHandles.Procedure_Foreground.get('Children'),...
    'Tag', data.get('Procedure'));
siblings    = panelDHS.get('Children');

% Build output structure.
out = data.outputFluoro();

% Initialize result field output.
result	= data.get('Result');
fieldNames	= fieldnames(result);
nFields	= length(fieldNames);
dataStruct	= cell2struct(cell(nFields, 1), fieldNames);

% Get wire width [mm] analysis results.
if isempty( result.Wire_Width )
    % Retrieve wire width selection, if not already done by user.
    wireWidth   = findobj( siblings, 'Tag', 'Wire Width' );
    data.Result.Wire_Width	= wireWidth.String{ wireWidth.Value };
    hObject.set( 'UserData', data );
end
dataStruct.Wire_Width	= result.Wire_Width;

% Get left | right analysis results.
if isempty(result.Left_Or_Right)
    % Retrieve wire width selection, if not already done by user.
    leftOrRight   = findobj(siblings, 'Tag', 'Left Or Right');
    left    = findobj(leftOrRight, 'Tag', 'Left');
    if left.get('Value')
        data.Result.Left_Or_Right = 'Left';
    else
        data.Result.Left_Or_Right = 'Right';
    end
    hObject.set('UserData', data);
end
dataStruct.Left_Or_Right	= result.Left_Or_Right;

% Get wire slope [px] analysis results.
try
    wireSlope   = result.Wire_Slope.Plot;
    wirexy	= vertcat( wireSlope.get( 'XData' ), wireSlope.get( 'YData' ) );
    dataStruct.Wire_Slope	= wirexy( :, 1 : 2 );
catch
    dataStruct.Wire_Slope	= NaN;
end

% Get femoral neck position [px] analysis results.
try
    neck  = result.Femoral_Neck.Plot;
    bisector	= result.Femoral_Neck.Bisector;
    dataStruct.Femoral_Neck	= struct(...
        'Neck_XY', vertcat(neck.get('XData'), neck.get('YData'))',...
        'Bisector_XY', vertcat(bisector.get('XData'), bisector.get('YData'))');
catch
    dataStruct.Femoral_Neck	= NaN;
end

% Get femoral head position [px] analysis results.
try
    dataStruct.Femoral_Head	= result.Femoral_Head.MinInfo;
catch
    dataStruct.Femoral_Head	= NaN;
end

% Run save routine.
[~]	= saveRoutine( fh, fhHandles, data, out, dataStruct );

