function fh = assembleProcedurePanels(fh)
%ASSEMBLEPROCEDUREPANELS Installs uicontrol panels for fluoro procedures.
%   
%   See also FLUORODICOM_GUI/MAIN_OPENINGFCN.
%==========================================================================

% Get procedure names and their parent-handle's name.
procedureNames	= getProcedureNames();
nProcedures	= length(procedureNames)-1;             % Ignore default.

% Assign each procedure name it's own panel.
panelPos    = [00.00 00.00 01.00 00.745];
panelRGB	= [01.00 01.00 00.80];
fhHandles	= fh.get('UserData').get('Current');
procedureForegroundPanel = fhHandles.Procedure_Foreground;
for idx = 1:nProcedures
    [~]	= uipanel('Tag', strcat(procedureNames{idx}), 'Title', [],...
        'Parent', procedureForegroundPanel,...
        'BackgroundColor', panelRGB, 'ForegroundColor', panelRGB,...
        'ShadowColor', panelRGB,...
        'Position', panelPos,...
        'visible',' off');
end

