function fh = displayWatchSurgery(fh, chosenProcedure)
%DISPLAYWATCHSURGERY Displays Watch Surgery Procedure buttons.
%   fh = DISPLAYWATCHSURGERY(fh) returns the updated gui with visible 
%   'Watch Surgery' procedure.
%
%   See also BUILDATAWATCHSURGERYFIELDS,
%   BUILDPROCEDUREFOREGROUNDPANEL>PROCEDURELIST_CALLBACK.
%==========================================================================

% Create PSHF panel if it has not already been done during life of GUI.
if isempty(chosenProcedureUIControls)
    gui_State  = guidata(fh);
    gui_State.gui_LayoutFcn    = @buildInterfaceWatchSurgery;
    guidata(fh, gui_State);
    fh	= buildInterfaceWatchSurgery(fh, chosenProcedure);
end

% Get list of files in directory.
% imgDir	= get(findobj(fh, 'Tag', 'Selected Directory'), 'UserData');

% % Run model on all images.
% printToLog(fh, 'Predicting locations of object in all fluoros, please wait', 'Progress');
% initialE    = toggleUIControls(fh, 'Inactive');
% [~, status]	= runModelDHS(imgDir, 0.90, '.png');
% if status == 0
%     printToLog(fh, 'Predicted locations of objects are available', 'Success');
% else
%     printToLog(fh, 'Could not predict locations of objects', 'Note', '!');
% end
% [~]    = toggleUIControls(fh, initialE);

