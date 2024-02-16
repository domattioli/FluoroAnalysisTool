function [fh]  = setFluoroData(fh, saveData)
%SETFLUORODATA Save fluoro data to GUI.
%   
%   See also GETFLUORODATA.
%==========================================================================

% Get figure handles.
fhHandles   = fh.get('UserData').get('Current');
tb  = fhHandles.FigureToolBar.Children;
if nargin == 1
    saveData	= findobj(tb, 'Tag', 'Save Data');
end
saveData.set('UserData', data);
end