function data = retrieveResults( fullFileName )
%RETRIEVERESULTS Parse .json file, blinded to procedure type.
%   data = RETRIEVERESULTS( fullFileName ) returns a 1xN struct array
%   containing the derived data about each fluoroshot of the inputted
%   result file. The inputted fullFileName must be a strinng in the format
%   of path-file-ext. Only one file may be processed at a time; if you have
%   multiple result files, call this function within a loop.
%   
%   See also WRITERESULT, JSON2TABLEDHS, JSON2TABLEPSHF.
%==========================================================================

narginchk( 1, 1 );
nargoutchk( 0, 1 );
assert( size( fullFileName, 1 ) == 1, 'Only one full file name can be inputted at a time; your input is being interpretted as several full file names.')

% Add folder of fileName to path.
[pathName, ~, ~]	= fileparts( fullFileName );
addpath(genpath(pathName))

% Count lines in results text to determine output array length.
fid	= fopen(fullFileName, 'r');
numLines = 0;
tline = fgetl(fid);
while ischar(tline)
  tline = fgetl(fid);
  numLines	= numLines+1;
end
fclose(fid);

% Read in Results text, line by line.
fid	= fopen(fullFileName, 'r');
if fid == -1
    errordlg('file not opened')
end
C   = cell(numLines, 1);
for idx = 1:numLines
    textLine	= fgetl(fid);
    if isempty(textLine)
        C{idx}	= [];
    else
        C{idx}	= textLine;
    end
end
success	= fclose('all');
if success ~= 0
    errordlg('failed to read all of results text file');
end

% Initialize an output data struct.
dataFieldNames	= fieldnames(jsondecode(C{find(~cellfun(@isempty, C), 1, 'first')}));
data(numLines)  = struct();         
for idx = 1:length(dataFieldNames)
    [data(:).(dataFieldNames{idx})] = deal([]);
end

% Decode json formatted results, assign to data structure.
for idx = 1:numLines
    if isempty(C{idx})
        continue
    else
        data(idx)	= jsondecode(C{idx});
    end
end

