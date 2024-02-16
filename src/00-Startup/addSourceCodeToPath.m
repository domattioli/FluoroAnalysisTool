function success = addSourceCodeToPath()
%ADDSOURCECODETOPATH Import procedure panel and its contents.
%   success = addSourceCodeToPath() returns true if source code is
%   successfully added to the MATLAB path.
%   
%   See also ADDNNCODETOPYPATH, MAIN>OPENINGFCN.
%==========================================================================

try
    % Add only folders with code to the path.
    srcPath     = sourceCodeDirectory();
    cd(srcPath);
    srcDir = dir(srcPath);
    srcDir_subDir   = {srcDir.name}';
    ilibCode    = contains(srcDir_subDir, 'lib');
    idataCode	= contains(srcDir_subDir, 'data');
    isrcCode	= contains(srcDir_subDir, 'src');
    pathAdds    = strcat(srcDir(end).folder, ';',...
        genpath(fullfile(srcDir(end).folder, srcDir_subDir{ilibCode})),...
        genpath(fullfile(srcDir(end).folder, srcDir_subDir{idataCode})),...
        genpath(fullfile(srcDir(end).folder, srcDir_subDir{isrcCode})));
    addpath(pathAdds);
    success	= true;
    
catch
    success	= false;
end

