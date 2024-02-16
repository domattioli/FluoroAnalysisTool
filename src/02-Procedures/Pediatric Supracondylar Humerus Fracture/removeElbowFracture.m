function data    = removeElbowFracture(data, fieldNames, iEF)
%REMOVEELBOWFRACTURE Deletes previous elbow fracture from fluoro plot.
%   data = REMOVEELBOWFRACTURE(data, fieldNames, iEF) returns the updated
%   results struct field of the data fluoroProcess object.
%   
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Get all objects associated with femoral head and femoral neck.
results	= data.get('Result');
elbowFracture	= results.(fieldNames{iEF});

% Remove all femoral head objects from axis and results struct.
if ~isempty(elbowFracture)
    delete(elbowFracture.Plot);
    results.(fieldNames{iEF})	= [];
end
data.set('Result', results);

