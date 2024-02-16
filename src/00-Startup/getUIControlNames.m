function out   = getUIControlNames(fh,varargin)
%GETUICONTROLNAMES Names of fluoroDICOM_GUI's uicontrols.
%   
%   See also ASSIGNUICONTROLNAMES, GETFOREGROUNDNAMES, FLUORODICOM-GUI.
%==========================================================================

% Initialize input parser.
p = inputParser;

% Add inputs to the scheme.
p.addRequired('figureHandle',@(x) isa(x,'matlab.ui.Figure'));
defaultReturn	= 'All';
validRequest	= {'Axis','Load','Procedure','Log','All'};
checkRequest	= @(x) any(strcmpi(x,validRequest));
p.addOptional('UIControls',defaultReturn,checkRequest);

% Parse inputs.
parse(p,fh,varargin{:});

% Fetch UIControl names from figure userdata.
userdata	= fh.get('UserData');
uicontrolNames	= userdata{2};
switch find(strcmpi(validRequest,p.Results.UIControls))
    case 1
        out	= [];   % No axis uicontrols, as of 2/15/19.
        
    case 2
        out	= uicontrolNames{2};
        
    case 3
        out	= uicontrolNames{3};
        
    case 4
        out	= [];   % No log uicontrols, as of 2/15/19.
        
    otherwise
        out	= [uicontrolNames{1};
            uicontrolNames{2};...
            uicontrolNames{3};...
            uicontrolNames{4}];
end


