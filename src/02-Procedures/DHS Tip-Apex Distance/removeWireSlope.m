function data    = removeWireSlope(data, fieldNames, iFH)
%REMOVEWIRESLOPE Deletes previous wire slope object from fluoro plot.
%   data = REMOVEWIRESLOPE(data, fieldNames, iFH) returns the updated
%   results struct field of the data fluoroProcess object.
%   
%   See also REMOVEFEMORALHEAD, REMOVEFEMORALNECK, DEFINEWIRESLOPE,
%   BUILDINTERFACEDHS.
%==========================================================================

% Get all objects associated with femoral head and femoral neck.
results	= data.get('Result');
wireSlope	= results.(fieldNames{iFH});

% Remove all femoral head objects from axis and results struct.
if ~isempty(wireSlope)
    delete(wireSlope.Plot);
    results.(fieldNames{iFH})	= [];
end
data.set('Result', results);

