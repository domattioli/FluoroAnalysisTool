function [data, saveData, fhHandles] = getFluoroData( fh )
%GETFLUORODATA Retrieve fluoro data from saved location in fh GUI.
%   
%   See also SETFLUORODATA.
%==========================================================================

% Get figure handles.
fhHandles   = fh.get( 'UserData' ).get( 'Current' );
saveData	= findobj( fhHandles.FigureToolBar.Children, 'Tag', 'Save Data' );
data    = saveData.get( 'UserData' );
end

