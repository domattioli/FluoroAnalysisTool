% function resultStruct     = createResultStruct(chosenProcedureObj)
% %CREATERESULTSTRUCT Generate dynamic fieldnames for result struct.
% %   resultStruct = CREATERESULTSTRUCT(chosenProcedureObj) returns a
% %   struct with fieldnames corresponding to the data accumulated when
% %   performing the procedure defined by chosenProcedureObj.
% %   
% %   See also
% %==========================================================================
% 
% % Create Results data -- might be a better way to instantiate UIC
% % tag/str/userdata names so i can be cleaner about this in the future.
% uiTagStrs   = chosenProcedureObj.get('Children').get('Tag');
% fieldNames	= strrep(uiTagStrs, ' ', '_');
% structValues	= cell(length(fieldNames), 1);
% resultStruct    = cell2struct(structValues, fieldNames);
% 
