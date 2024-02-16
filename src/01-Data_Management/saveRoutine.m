function returnOut = saveRoutine( fh, fhHandles, data, out, dataStruct )
%SAVEROUTINE Routine for saving the data.
%   returnOut = SAVEROUTINE(fh, fhHandles, data, out, dataStruct) returns 0
%   if save successful. Otherwise, returns 1.
%   
%   See also SAVEDATA, SAVEDHS, SAVEPSHF.
%==========================================================================

try
    % Identify saving directory and name.
    project	= findobj( fhHandles.FigureToolBar, 'Tag', 'Project' );
    caseID_path	= data.get( 'CaseID' );
    [~, caseID]	= fileparts( caseID_path );
    if isempty( project.get( 'UserData' ) )
        saveDir	= caseID_path;
    else
        saveDir	= project.get( 'UserData' );
    end
    saveFileName    = strcat( caseID, '_', 'Results.json' );
    
    % Write results file in an encoded JSON format.
    out.Result	= dataStruct;
    TEXT	= jsonencode( out );
    [~]	= writeResults(fh, saveDir, TEXT, saveFileName);
    printToLog(fh, [out.FileName, '''s procedure data saved to ''',...
        fullfile(saveDir, saveFileName) ''''], 'Success');
    
    returnOut = 0;
catch
    printToLog(fh, 'Saving failed', 'Error');
    returnOut = 1;
end