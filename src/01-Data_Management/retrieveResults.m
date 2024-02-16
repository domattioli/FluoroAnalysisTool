function data	= retrieveResults(fullFileName)

% Add folder of fileName to path.
[pathName, ~, ~]	= fileparts(fullFileName);
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

