function data = updateResults(data, fieldNames, index, newVal)
%UPDATERESULTS Update results struct with new data.
%   data = UPDATERESULTS(data, fieldNames, index, newVal) returns the
%   fluoroProcess object with the results struct containing an updated
%   field (indexed by index) as newVal.
%   
%   See also INDEXTORESULTSFIELD, FLUOROPROCESS.
%==========================================================================

% Get results.
results = data.get('Result');

% Update results of data.
results.(fieldNames{index})  = newVal;
data.set('Result', results);

