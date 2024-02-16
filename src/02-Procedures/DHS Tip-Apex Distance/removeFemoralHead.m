function data    = removeFemoralHead(data, fieldNames, iFH)
%REMOVEFEMORALHEAD Deletes previous femoral head object from fluoro plot.
%   data = REMOVEFEMORALHEAD(data, fieldNames, iFH) returns the updated
%   results struct field of the data fluoroProcess object.
%   
%   Note: Since the femoral neck is dependent on the femoral head,
%   REMOVEFEMORALHEAD also removes the previous femoral neck object too.
%   
%   See also REMOVEFEMORALNECK, REMOVEWIRESLOPE, DEFINEFEMORALHEAD,
%   BUILDINTERFACEDHS.
%==========================================================================

% Get all objects associated with femoral head and femoral neck.
results	= data.get('Result');
femoralHead	= results.(fieldNames{iFH});
iFN	= contains(fieldNames, 'Neck');

% Remove all femoral head objects from axis and results struct.
if ~isempty(femoralHead)
    delete(femoralHead.Plot);
    results.(fieldNames{iFH})	= [];
end
data.set('Result', results);

% Remove femoral neck object, if it exists.
femoralNeck	= results.(fieldNames{iFN});
if ~isempty(femoralNeck) % Then there may be a femoral neck object.
    data    = removeFemoralNeck(data, fieldNames, iFN);
end

