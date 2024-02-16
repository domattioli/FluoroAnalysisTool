function fh	= resetGUIToInitialCondition(fh)
%RESETGUITOINITIALCONDITION Sets all buttons, text in GUI to defaults.
%
%==========================================================================

% Get procedure type.
uicontrolNames	= getUIControlNames(fh,'Procedure');
procedures	= findobj(allchild(fh),'Tag',uicontrolNames{1});
procedureNames  = procedures.get('String');

% Reset selected procedure back to it's default settings.
switch procedures.get('Value')
    case 1                                          % DHS.
        chosenProcedure	= procedureNames{procedures.get('Value')};
        set(findobj('Tag','Initial Condition'),'Value',1);
        set(findobj('Tag','Wire Width'),'Value',3,'Enable','inactive');
        set(findobj('Tag','Define Slope Of Wire'),'Enable','inactive');
        set(findobj('Tag','Define Femoral Neck'),'Enable','inactive');
        set(findobj('Tag','Define Femoral Head'),'Enable','inactive');
        set(findobj('Tag','Save Data'),'Enable','inactive');
        set(findobj(procedureChildren, 'Tag', 'Initial Condition'), 'Value', true);
        set(findobj(procedureChildren, 'Tag', 'Wire Width'), 'Value', 3);
        
    case 2
        
    case 3
        
    otherwise
        
end
