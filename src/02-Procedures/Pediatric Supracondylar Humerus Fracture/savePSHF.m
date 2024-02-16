function savePSHF(hObject, ~, fh)
%SAVEPSHF Create/updates .json for PSHF results for this CaseID.
%   New file name 'Results.json'; if a file already exists, SAVEPSHF
%   overwrites existing rows corresponding to DICOM files of a
%   folder/surgery. The columns contain all relevant processing information
%   (in JSON format).
%   
%   See also SAVEDHS.
%==========================================================================

% Get fluoro data -- saved as the userdata in saveData object.
[data, ~, fhHandles]	= getFluoroData(fh);
panelPSHF	= findobj(fhHandles.Procedure_Foreground.get('Children'),...
    'Tag', data.get('Procedure'));
siblings    = panelPSHF.get('Children');

% Build output structure.
out	= data.outputFluoro();

% Initialize result field output.
result	= data.get('Result');
fieldNames	= fieldnames(result);
nFields	= length(fieldNames);
dataStruct  = cell2struct(cell(nFields, 1), fieldNames);

% Get wire width [mm] analysis results.
if isempty(result.Wire_Width)
    % Retrieve wire width selection, if not already done by user.
    wireWidth   = findobj(siblings, 'Tag', 'Wire Width');
    result.Wire_Width	= wireWidth.String{wireWidth.Value};
    data.set('Result', result);
    hObject.set('UserData', data);
end
dataStruct.Wire_Width	= result.Wire_Width;

% Get intersection points analysis results.
try
    intersections   = result.Find_Intersections.Plot(:);
    dataStruct.Find_Intersections	= cell2mat(horzcat(...
        intersections.get('XData'), intersections.get('YData')));
catch
    dataStruct.Find_Intersections	= NaN;
end

% Get wire positions [px] analysis results.
try
    dataStruct.Add_Wire	= struct();
    for idx = 1:length(result.Add_Wire.Plot)
        dataStruct.Add_Wire.(['Wire_', num2str(idx)]) = result.Add_Wire.Plot(idx).getPosition;
    end
catch
    dataStruct.Add_Wire	= NaN;
end

% Get fracture position [px] analysis results.
try
    dataStruct.Elbow_Fracture	= vertcat(result.Elbow_Fracture.Plot.get('XData'),...
        result.Elbow_Fracture.Plot.get('YData'))';
    dataStruct.Elbow_Fracture(end, :)   = [];
catch
    dataStruct.Elbow_Fracture   = NaN;
end

% Run save routine.
[~]	= saveRoutine(fh, fhHandles, data, out, dataStruct);

