function printToLog(fh, logString, messageType, endMark)
%PRINTTOLOG Displays progress messages and Notes to the use in the log panel.
%   
%   See also CREATEGUI, DISPLAYLOG.
%==========================================================================

% Check input.
narginchk(2, 4)
if nargin < 3
    messageType = '';
end
if nargin < 4
    switch lower(messageType)
        case 'note'
            endMark     = '.';
        case 'progress'
            endMark     = '...';
        case 'success'
            endMark     = '.';
        case 'error'
            endMark     = '.';
        otherwise
            error(struct('message', 'Did not input an appropriate messageType.',...
                'identifier', 'fluoroDICOM_GUI:printToLog:invalidInput'));
    end
    
else
    if ~ischar(endMark)
        error(struct('message','endMark input to printToLog must be a char.',...
            'identifier', 'fluoroDICOM_GUI:printToLog:invalidInput'));
    end
end

if iscell(logString)
    if length(logString) > 1
        logString = strjoin(logString);
        
    else
        logString = logString{1};
    end
end

% Get figure handles and fluoro data.
[~, ~, fhHandles]	= getFluoroData(fh);

% Identify 1st "open" text line (box).
logForeground   = fhHandles.Log_Foreground;
logTexts	= allchild( logForeground.get( 'Children' ) );
logTextsClasses = cell( numel( logTexts ), 1 );
for idx = 1:numel( logTexts )
    logTextsClasses{ idx } = class( logTexts( idx ) );
end
logTexts( ~contains( logTextsClasses, 'matlab.ui.control.UIControl' ) ) = [];
nLines	= length(logTexts);
currentStrings	= logTexts.get('String');
isOpen	= cellfun(@length, currentStrings) == 0;

% Insert text in open line.
if any(isOpen)
    iLine   = find(isOpen,1, 'first');
    
else
    % No lines are open; insert text at last line, Shift other lines up.
    iLine   = nLines;
    for idx = 1:nLines-1
        logTexts(idx).set('string', logTexts(idx+1).get('string'),...
            'foregroundcolor', logTexts(idx+1).get('foregroundcolor'));
    end
end

% Accomodate for messageType.
set(logTexts(iLine), 'Visible', 'off');
switch lower(messageType)
    case 'note'                                     % Note of detail...
        displayStr	= horzcat(logString, endMark);
        logTexts(iLine).set('String', displayStr, 'foregroundcolor',' k');
        
    case 'progress'                                 % Hint for completing process.
        displayStr	= horzcat('>> ', logString, endMark);
        logTexts(iLine).set('String', displayStr, 'foregroundcolor', 'k');
        
    case 'success'                                  % Process complete.
        displayStr	= horzcat('>> ', logString, endMark);
        logTexts(iLine).set('String', displayStr, 'foregroundcolor', [0.0 0.5 0.0]);
        
    case 'error'
        displayStr	= horzcat('Error: ', logString, endMark);
        logTexts(iLine).set('String', displayStr, 'foregroundcolor', 'r');
end

% Prep string for wrapping to log panel's text boxes.
wrappedString   = textwrap(logTexts(iLine), {displayStr});
logTexts(iLine).set('String', wrappedString);
textExtent	= logTexts(iLine).get('Extent');
textPos	= logTexts(iLine).get('Position');

% Perform custom text wrapping.
if length(wrappedString) > 2
    % Too many lines.
    maxNChar    = min(cellfun(@length, wrappedString(1:2)));% Be conservative.
    finalString	= {strcat(displayStr(1:maxNChar-3),'...');...
        strcat('...', displayStr(length(displayStr)-maxNChar+3:end))};
    
elseif length(wrappedString) == 2 && textExtent(3) < textPos(3)
    % Lines aren't wrapped correctly.
    nChar	= cellfun(@length, wrappedString);
    [~, iExtent]	= max(nChar);
    maxNChar	= floor(nChar(iExtent)/(textExtent(3)/(textPos(3)*(0.98))));
    finalString	= {strcat(displayStr(1:maxNChar-3), '-');...
        displayStr(maxNChar-2:end)};
    
else
    % Only one line.
    finalString = wrappedString;
end
logTexts(iLine).set('String', finalString, 'HorizontalAlignment', 'left',...
    'Visible', 'On');


