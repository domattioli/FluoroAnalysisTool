function out = getForegroundNames(fh,varargin)
%GETFOREGROUNDNAMES Names of fluoroDICOM_GUI's foreground panels.
%   
%   See also ASSIGNFOREGROUNDNAMES, GETPROCEDURENAMES, FLUORODICOM-GUI.
%==========================================================================

% Initialize input parser.
p = inputParser;
p.addRequired('figureHandle', @(x) isa(x,'matlab.ui.Figure'));
defaultReturn	= 'All';
validRequest	= {'Axis', 'Load', 'Procedure', 'Log', 'All'};
checkRequest	= @(x) any(strcmpi(x,validRequest));
p.addOptional('Foregrounds', defaultReturn, checkRequest);
p.parse(fh,varargin{:});

% Fetch foreground names from figure userdata.
userdata	= fh.get('UserData');
foregroundNames	= userdata{1};
switch find(strcmpi(validRequest, p.Results.Foregrounds))
    case 1
        out	= foregroundNames{1};
        
    case 2
        out	= foregroundNames{2};
        
    case 3
        out	= foregroundNames{3};
        
    case 4
        out	= foregroundNames{4};
        
    otherwise
        out	= foregroundNames;
end


