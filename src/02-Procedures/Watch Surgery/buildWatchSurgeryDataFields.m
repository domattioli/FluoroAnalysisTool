function data	= buildWatchSurgeryDataFields(data,procedureName)
%BUILDWATCHSURGERYDATAFIELDS Builds/resets data for .
%
% See also: BUILDPSHFDATAFIELDS, DISPLAYINTERFACEWATCHSURGERY, FLUOROPROCESS.
%==========================================================================

% Assign procedure information.
data.set('Operations',[]);
if nargin == 2
    %%%%%%%%%%%%%%%%%%% Callback function does not currently exist 2-18-19.
    data.set('Orocedure',struct('Name',procedureName,'Callback',[]));
end

