function initialE = toggleUIControls(fh, varargin)
%TOGGLEUICONTROLS Toggle 'enable' param. of all other UIcontrols.
%   initialE = TOGGLEUICONTROLS(fh, 'ENABLE') toggles the 'enable'
%   parameter(s) of all UIControls in GUI to the opposite of their current
%   setting. TOGGLEUICONTROLS returns an Mx2 cell array initalE containing
%   the tag and enability of all M-number of UIControls in the gui.
%   'ENABLE' must be a char. The opposite of 'on' is inactive, and vice
%   versa.
%   
%   initialE = TOGGLEUICONTROLS(fh, toggleE) toggles enable parameter(s) of
%   all UIControls in GUI to the enability value specified by toggleE,
%   which must be an Mx2 cell array comprised of object tag (:,1) and the
%   corresponding object(s)' desired enability. initialE equals toggleE.
%   
%   See also
%==========================================================================

% Check input.
allUIControls   = findall(allchild(fh), 'Type', 'UIControl');
if nargin == 1
    initialE    = [allUIControls.get('Tag'), allUIControls.get('Enable')];
    
    % Toggle allUIControls.
    for idx = 1:length(allUIControls)
        if strcmp(allUIControls(idx).get('Enable'), 'On')
            ENABLE = 'inactive';
        else
            ENABLE = 'on';
        end
        allUIControls(idx).set('Enable', ENABLE);
    end
    
else
    if numel(varargin) == 1 &&...
            (isa(varargin{1}, 'char') || isa(varargin{1}, 'string'))
        ENABLE  = varargin{1};
        initialE    = [allUIControls.get('Tag'), allUIControls.get('Enable')];
        allUIControls.set('Enable', ENABLE);
        
    elseif isa(varargin, 'cell') % toggleE.
        initialE    = varargin{1};
        toggleE	= initialE;
        for idx = 1:length(toggleE)
            % Find corresponding object of fh.
            obj = findobj(allUIControls, 'Tag', toggleE{idx, 1});
            
            % Set enability.
            ENABLE	= toggleE{idx, 2};
            obj.set('Enable', ENABLE);
        end
    end
end





