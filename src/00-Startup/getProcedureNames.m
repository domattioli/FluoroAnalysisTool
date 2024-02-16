function procedureNames	= getProcedureNames()
%GETPROCEDURENAMES Names of fluoroDICOM_GUI's procedures.
%   
%   See also BUILDPROCEDUREPANELS, FLUORODICOM_GUI.
%==========================================================================

% Get folder containing procedure .m code.
srcDir	= fullfile(sourceCodeDirectory(), 'src', '02-Procedures');
if ismac
    newPath     = strrep(genpath(srcDir), ':', ';');
    
elseif ispc
    newPath	= genpath(srcDir);
end

% Initialize procedure name list based on number of procedure libraries we have.
folderNames	= regexp(newPath, ';', 'split')'; % Ignore last ';'.
iProcedureNames	= cellfun(@(x) x(end), {regexp(folderNames{2}, filesep, 'end')});
nProcedures     = length(folderNames)-1;
procedureNames	= [cell(nProcedures-1, 1); 'No Procedure Selected'];

% Identify procedure names.
for idx = 1:nProcedures-1
    procedureNames{idx}	= folderNames{1+idx}(iProcedureNames+1:end);
end


