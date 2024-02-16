function success = addNNCodeToPyPath()
%ADDNNCODETOPYPATH Import neural network code to Python path.
%   success = addSourceCodeToPath() returns true if source code is
%   successfully added to the Python path.
%   
%   See also ADDSOURCECODETOPATH, MAIN>OPENINGFCN.
%==========================================================================

try
    % Add only folders with code to the path.
    pathCell	= regexp( path, pathsep, 'split' );
    ipyFiles	= contains( pathCell, 'Neural_Net_Models' );
    nnModelsDir = pathCell{ find( ipyFiles, 1, 'first' ) };
    insert( py.sys.path, int64( 0 ), nnModelsDir );
    success	= true;
catch
    success	= false;
end

