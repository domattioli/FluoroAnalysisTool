function fileNames = GrabResultsFiles(directoryName)

% Get list of surgeries.
surgeryDir = dir(directoryName);
surgeryIDs = cellstr({surgeryDir.name}');

% Remove non-surgery and empty entries.
iremove	= contains(surgeryIDs,'.') | contains(surgeryIDs,'DS_Store');
surgeryIDs	= surgeryIDs(~iremove);

% Grab name of each 'Results.json' file in surgeryIDs list.
N = length(surgeryIDs);
fileNames = cell(N,1);
for idx = 1:N
    surgeryIDdir = fullfile(directoryName, surgeryIDs{idx});
    surgeryIDfiles = dir(surgeryIDdir);
    if length(surgeryIDfiles) <= 2
        continue
    end
    surgeryIDfileNames = {surgeryIDfiles.name}';
    
    % Retrieve results file.
    iresults = contains(surgeryIDfileNames, 'Results');
    if all(iresults == false)
        continue
    else
        fileNames{idx} = fullfile(surgeryIDdir, surgeryIDfileNames{iresults});
    end
end
