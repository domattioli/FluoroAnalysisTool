function [index, fieldNames, chosenProcedureObj] = indexToResultsField(fhHandles, data, hObject)
%INDEXTORESULTSFIELD Index to field of results struct.
%   index = indexToResultsField(fhHandles, data, hObject) returns a logical
%   array indexing the input button's object by it's tag to the
%   chosenProcedureObj's (panel) children.
%   
%   See also UPDATERESULTS.
%==========================================================================

% Get fieldnames of results corresponding to chosen procedure.
chosenprocedureStr	= data.get('Procedure');
chosenProcedureObj	= findobj(fhHandles.Procedure_Foreground, 'Tag', chosenprocedureStr);
fieldNames  = fieldnames(data.Result);

% Index to field corresponding to procedure part, remembering that the tags
% do not have underscores but the field names do.
buttonStr   = strrep(hObject.get('Tag'), ' ', '_');
index    = contains(fieldNames, buttonStr);

