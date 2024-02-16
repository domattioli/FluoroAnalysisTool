function data    = removeIntersections(data, fieldNames, iFI)
%REMOVEINTERSECTIONS Deletes previous intersections from fluoro plot.
%   data = REMOVEINTERSECTIONS(data, fieldNames, iFI) returns the updated
%   results struct field of the data fluoroProcess object.
%   
%   See also BUILDINTERFACEPSHF.
%==========================================================================

% Get all objects associated with femoral head and femoral neck.
results	= data.get('Result');
intersections	= results.(fieldNames{iFI});

% Remove all femoral head objects from axis and results struct.
if ~isempty(intersections)
    for idx = 1:length(intersections.Plot)
        delete(intersections.Plot(idx))
    end
    axisChildren = get(gca, 'Children');
    idelete = contains(axisChildren.get('Tag'), 'Int.');
    delete(axisChildren(idelete));
    results.(fieldNames{iFI})	= [];
end
data.set('Result', results);

