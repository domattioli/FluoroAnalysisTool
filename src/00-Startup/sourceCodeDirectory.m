function toolPathName	= sourceCodeDirectory()
%SOURCECODEDIRECTORY Give directory of source code.
%
%   See also FLUORODICOM_GUI.
%==========================================================================

executingPath	= mfilename( 'fullpath' );
itoolPathName	= strfind( executingPath, fullfile( filesep, 'src' ) ) - 1;
toolPathName	= executingPath( 1:itoolPathName );

