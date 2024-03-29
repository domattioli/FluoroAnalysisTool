function fh  = buildLogForegroundPanel(fh)
%BUILDLOGFOREGROUNDPANEL Import log panel and its contents.
%   fh = BUILDLOGFOREGROUNDPANEL(fh) returns an updated figure handle
%   fh containing a panel for log display. This panel has no callbacks.
%   
%   Note: Font sizes were derived empirically - set to a speci=fic fraction
%	the ui object's height.
%   
%   See also MAIN>OPENINGFCN, BUILDAXISFOREGROUNDPANEL,
%   BUILDLOADFOREGROUNDPANEL, BUILDPROCEDUREFOREGROUNDPANEL.
%==========================================================================

% Get color scheme.
global bgColor fgUIowa

% Build GUI Parts.
logUICNames	= {'Log Foreground',...
    'Log',...
    'Panel Log Text'};
logForegroundParent	= uipanel(...
    'Tag', logUICNames{1}, 'Title', 'Log',...
    'Parent', fh,...
    'BackgroundColor', [1 1 0.8], 'ForegroundColor', 'k', 'ShadowColor', 'k',...
    'Position', [.70 .025 .285 .3],...
    'FontWeight', 'Bold', 'FontSize', 17);

% Initialze panel.
nLines	= 6;
ySpace  = .01;
logTextPos	= [ySpace ySpace .98 (.98/nLines)-ySpace];
logTextBoxesPanel	= uipanel(...
    'Tag', logUICNames{2}, 'Title', [],...
    'Parent', logForegroundParent, 'Children', [],...
    'BackgroundColor', bgColor, 'ForegroundColor', 'k', 'ShadowColor', 'k',...
    'Position', [.01 .01 .98 .985],...
    'Units', 'Normalized', 'FontUnits', 'Normalized',...
    'FontWeight', 'Bold', 'FontSize', 0.0740,...
    'BorderType', 'None');

% Build UI (lines in) of (text box) panel.
for idx = nLines:-1:1
    [~] = uicontrol('Style', 'text',...
        'Tag', strcat(logUICNames{3}, num2str(idx)), 'String', '',...
        'max', 2, 'min', 1,...
        'Parent', logTextBoxesPanel,...
        'BackgroundColor', bgColor, 'ForegroundColor', 'k',...
        'Units', 'Normalized', 'FontUnits', 'Normalized',...
        'FontSize', 0.40, 'FontName', 'Times New Roman',...
        'HorizontalAlignment', 'left',...
        'visible', 'on', 'enable', 'inactive',...
        'Position', logTextPos);
    logTextPos(2)	= logTextPos(2) + logTextPos(4) + ySpace;
end

% Update fh UserData.
fh.set('UserData', fh.get('UserData').createNew(logForegroundParent));


