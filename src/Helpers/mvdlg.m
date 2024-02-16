function Answer = mvdlg( prompt, title, position, button1Str, button2Str, textbar)
%MVDLG moveable input dialog box.
%  ANSWER = MVDLG(PROMPT,TITLE,POSITION) creates a dialog box that returns
%  user input for a prompt in cell array ANSWER. PROMPT is a string. TITLE
%  is a string that species a title for the dialog box. POSITION is a
%  four-element vector that specifies the size and location on the screen
%  of the dialog window. Specify POSITION in normalized coordinates in the
%  form: [left, bottom, width, height] where left and bottom are the
%  distance from the lower-left corner of the screen to the lower-left
%  corner of the dialog box. width and height are the dimensions.  
%
%
%  Examples:
%
%  prompt='Enter a value here:';
%  name='Data Entry Dialog';
%  position = [.5 .5 .2 .1];
%
%  answer=mvdlg(prompt,name,position);
%
%
%  prompt='Enter a value here:';
%  name='Data Entry Dialog';
%  position = [.7 .2 .2 .3]; 
%  answer=mvdlg(prompt,name,position);

% Set up main window figure
dialogWind = figure( 'Units', 'normalized',...
    'Position', position,...
    'MenuBar', 'None',...
    'NumberTitle', 'Off',...
    'CloseRequestFcn', @CloseRequestFcn,...
    'Name', title,...
    'Visible', 'On' );

% Set up GUI controls and text
uicontrol( 'style', 'text',...
    'String', prompt,...
    'Units', 'normalized', ...
    'Position', [.05,.75,.9,.1],...
    'HorizontalAlignment', 'left' )
if nargin == 6
    hedit = uicontrol( 'style', 'edit',...
        'Units', 'normalized',...
        'Position', [.05, .5, .9, .2],...
        'HorizontalAlignment', 'left' );
end
button1 = uicontrol( 'style', 'pushbutton',...
    'Units', 'normalized',...
    'position', [.05,.1,.4,.3],...
    'string', button1Str,...
    'Callback', { @buttonCallback, dialogWind } );
button2 = uicontrol( 'style', 'pushbutton',...
    'Units', 'normalized',...
    'position', [.55,.1,.4,.3],...
    'string', button2Str,...
    'Callback', { @buttonCallback, dialogWind } );

%initialize ANSWER to empty cell array
Answer = {};

%wait for user input, and close once a button is pressed 
uiwait( dialogWind );

%callbacks for 'OK' and 'Cancel' buttons
function buttonCallback( hObject, eventData, dialogWind )
    dialogWind.set( 'UserData', hObject.get( 'String' ) );
    dialogWind.CloseRequestFcn( dialogWind, eventData )
end
function CloseRequestFcn( hObject, eventData )
    if ~contains( eventData.EventName, 'Action' )
        return % Must answer the prompt -- Need to change this to all for more buttons
    end
    Answer = dialogWind.get( 'UserData' );
    uiresume( hObject );
    hObject.delete();
end
end
