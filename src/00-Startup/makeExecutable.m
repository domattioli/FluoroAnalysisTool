%% Export main.m Script of Fluoro DICOM Analysis GUI as A Standalone .exe
% Get path to source code that builds the GUI.
srcDir  = sourceCodeDirectory();
projectMain	= fullfile(srcDir, 'main.m');

% Build application.
cd(srcDir);
applicationCompiler -package main

