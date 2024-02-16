function fh = buildProcedurePanels(fh)
%BUILDPROCEDUREPANELS Installs uicontrol panels for fluoro procedures.
%   
%   See also GETPROCEDURENAMES, FLUORODICOM_GUI.
%==========================================================================

% Get procedure names and their parent-handle's name.
foregroundName	= getForegroundNames(fh,'Procedure');
procedureNames	= getProcedureNames(fh);
nProcedures	= length(procedureNames)-1;             % Ignore default.

% Assign each procedure name it's own panel.
panelPos    = [00.00 00.00 01.00 00.745];
panelRGB	= [01.00 01.00 00.80];
procedureForeground	= findobj(allchild(fh),'Tag',foregroundName);
for idx = 1:nProcedures
    [~]	= uipanel('Tag',procedureNames{idx},'Title',[],...
        'Parent',procedureForeground,...
        'BackgroundColor',panelRGB,'ForegroundColor',panelRGB,'ShadowColor',panelRGB,...
        'Position',panelPos,...
        'visible',' off');% This is building duplicate panels!!
end
procedureForeground.set('UserData',procedureNames);

