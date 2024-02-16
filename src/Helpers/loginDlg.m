function Answer = loginDlg(prompt, title, position)
% Custom dialog box for prompting user login. LOGINDLG is intended to
% combine the other custom function, MVDLG, with the built-in inputdlg.
%   
%   See also: MVDLG, inputdlg.
%==========================================================================

%set up main window figure
dialogWind = figure('Units','normalized','Position', ...
    position,'MenuBar','none','NumberTitle','off','Name',title);


%set up GUI controls and text
% uicontrol('style','text','String',prompt,'Units','normalized', ...
%     'Position',[.05,.9,.9,.1],'HorizontalAlignment','left');

defaultVals = {'Doe', 'J'};

lny = 0.6;
lastName = uicontrol('style','edit','Units','normalized','Position', ...
    [0.4, lny, 0.45, 0.2],'HorizontalAlignment','left', 'String', defaultVals{ 1 }, 'Parent', dialogWind );
uicontrol('style','text','String', 'Last Name:', 'Units', 'Normalized',...
    'Position',[0.19, lny-0.05, 0.2, 0.2],'HorizontalAlignment','left', 'Parent', dialogWind );

lny = 0.4;
firstInit = uicontrol( 'style', 'edit', 'Units', 'normalized', 'Position',...
    [0.4, lny, 0.45, 0.2],'HorizontalAlignment','left', 'String', defaultVals{ 2 }, 'Parent', dialogWind );
uicontrol('style', 'text', 'String', 'First Initial:', 'Units', 'Normalized',...
    'Position',[0.19, lny+0.05, 0.2, 0.1],'HorizontalAlignment','left', 'Parent', dialogWind );

okayButton = uicontrol('style','pushbutton','Units','normalized',...
    'position', [.05,.1,.4,.25],'string','Enter','callback',@okCallback);
cancelButton = uicontrol('style','pushbutton','Units','normalized',...
    'position', [.55,.1,.4,.25],'string','Cancel','callback',@cancCallback);

%initialize ANSWER to empty cell array
Answer = {};

%wait for user input, and close once a button is pressed 
uiwait(dialogWind);

%callbacks for 'OK' and 'Cancel' buttons
    function okCallback(hObject,eventdata)
        Answer = { lastName.get( 'String' ), firstInit.get( 'String' ) };
        if sum( strcmp( Answer, defaultVals ), 2 ) == 2
            Answer = '';
        end
        uiresume(dialogWind);
        close(dialogWind);
    end

    function cancCallback(hObject,eventdata)
        Answer = '';
        uiresume(dialogWind);
        close(dialogWind);
    end
end
