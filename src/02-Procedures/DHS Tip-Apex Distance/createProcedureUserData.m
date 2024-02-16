function createProcedureUserData(hObject)

% Initilize UserData corresponding to the outputs of each child.
procedurePanelChildren   = hObject.get('Children');
N   = length(procedurePanelChildren);
userData    = cell(N,2);
for idx = 1:N
    userData{idx,1}	= procedurePanelChildren(idx).get('Tag');
end
hObject.set('UserData', userData)
