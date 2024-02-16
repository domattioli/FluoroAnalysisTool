function data = text2json(jsonFileName)
%TEXT2JSON Decodes JSON-Encoded In Results Text File
% Iterate through text, storing each as a cell.
fid	= fopen(jsonFileName);
fileCompletelyRead  = false;        % True met when last line read.
idx	= 1;
data	= cell(500,1);           	% Overestimate initilizing.
while ~fileCompletelyRead
    % Read in current line of text file.
    lineInFile	= fgets(fid);
    
    % Ignore Line Number designation "#."
    icropText    = find( (lineInFile == '{'), 1, 'first');
    
    % Check termination criteria.
    if isempty(icropText)
        % No more lines remaining.
        idx	= idx - 1;
        data    = data(1:idx);      % Remove excess rows of cell.
        fileCompletelyRead  = true;
    else
        data{idx}   = jsondecode(lineInFile(icropText:end));
        idx = idx + 1;
    end
end
fclose(fid);