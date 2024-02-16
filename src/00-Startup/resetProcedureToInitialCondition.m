function resetProcedureToInitialCondition(fh, procedurePanel)
%RESETPROCEDURETOINITIALCONDITION Sets all buttons, text in procedure panel to defaults.
%
%==========================================================================

% Get procedure type.
procedureName   = procedurePanel.get('Tag');
siblings	= get(procedurePanel.get('Parent'),'Children');
procedureChildren   = procedurePanel.get('Children');
buttonGroupAPOrLateral	= findobj(siblings, 'Tag', 'AP Or Lateral');
set(findobj(buttonGroupAPOrLateral, 'Tag', 'Initial View'), 'Value', true);

% Reset selected procedure back to it's default settings.
switch procedureName
    case {'DHS Tip-Apex Distance'}
        set(findobj(procedureChildren, 'Tag', 'Initial Condition'), 'Value', true);
        
    case 2  % PSHF.
%         set(findobj(procedureChildren,'Tag','WiresAdded'),'String',{'Wires Added'},...
%             'Value',1,'UserData',{line(NaN,NaN); line(NaN,NaN); line(NaN,NaN)});
%         set(findobj(procedureChildren,'Tag','DefineFracture'),'UserData',[]);
%         set(findobj(procedureChildren,'Tag','AddWire'),'UserData',[]);
%         set(findobj(procedureChildren,'Tag','DeleteWire'),'UserData',[]);
        
    case 3
        
    otherwise
        
end

% Reset procedure name.
proceduresUIControl  = findobj(siblings, 'Tag', 'procedures');
proceduresUIControl.set('Value', length(proceduresUIControl.get('String')));
