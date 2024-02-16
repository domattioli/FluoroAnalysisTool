function data    = removeFemoralNeck(data, fieldNames, iFN)
%REMOVEFEMORALNECK Deletes previous femoral head object from fluoro plot.
%   data = REMOVEFEMORALNECK(data, fieldNames, iFH) returns the updated
%   results struct field of the data fluoroProcess object.
%   
%   See also REMOVEFEMORALHEAD, REMOVEWIRESLOPE, DEFINEFEMORALNECK,
%   BUILDINTERFACEDHS.
%==========================================================================

% Get all objects associated with femoral neck.
results	= data.get('Result');
femoralNeck     = results.(fieldNames{iFN});

% Remove all femoral head objects from axis and results struct.
if ~isempty(femoralNeck)
    delete(femoralNeck.Plot);
    delete(femoralNeck.Bisector);
    results.(fieldNames{iFN})	= [];
end
data.set('Result', results);

