function fh = buildInterfaceWatchSurgery(hObject, fh, panelHandle)
%BUILDINTERFACEWATCHSURGERY Builds displays for 'Watch Surgery' Procedure.
%   fh = buildInterfaceWatchSurgery(hObject, fh, panelHandle) returns
%   updated fh w Watch Surgery buttons.
%   
%   See also DISPLAYWATCHSURGERY, BUILDPROCEDUREFOREGROUNDPANEL,
%   BUILDINTERFACEWATCHSURGERY>startWatch_Callback,
%   BUILDINTERFACEWATCHSURGERY>stopWatch_Callback,
%   BUILDINTERFACEWATCHSURGERY>continueWatch_Callback,
%   BUILDINTERFACEWATCHSURGERY>adjustimageContrast_Callback,
%   BUILDINTERFACEWATCHSURGERY>pauseDuration_Callback,
%   BUILDINTERFACEWATCHSURGERY>loopSurgery_Callback,
%   BUILDINTERFACEWATCHSURGERY>WIREWIDTHS_CALLBACK.
%==========================================================================

% Create buttons for pause duration, image contrast.
uicontrolNames	= getUIControlNames(fh,'Procedure');
saveData    = findobj(hObject.get('Parent'),'Tag',uicontrolNames{2});
data    = saveData.get('UserData');
fontSize    = 0.45;
defaultPauseDuration	= 0.50;
[~]	= uicontrol('Style','Edit',...
    'Tag','textAdjustImageContrast','String','Adjust Image Contrast',...
    'Parent',panelHandle,...
    'enable','inactive',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Position',[.05 .75 .35 .15]);
[~]	= uicontrol('Style','Text',...
    'Tag','emptyAdjustImageContrast','String','',...
    'Parent',panelHandle,...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Position',[.40 .75 .35 .15]);
[~]	= uicontrol('Style','popupmenu',...
    'Tag','adjustImageContrast','String',{'No'; 'Yes'},...
    'parent',panelHandle,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],...
    'Value',1,...
    'Position',[.40 .75 .35 .15],...
    'UserData',data.get('image'),...
    'Callback',{@adjustimageContrast_Callback,fh});
[~]	= uicontrol('Style','Edit',...
    'Tag','textPauseDuration','String','Pause Duration [sec]',...
    'Parent',panelHandle,...
    'enable','inactive',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Position',[.05 .60 .35 0.15]);
[~]	= uicontrol('Style','Edit',...
    'Tag','pauseDuration','String',num2str(defaultPauseDuration),...
    'parent',panelHandle,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],...
    'Value',defaultPauseDuration,...
    'Position',[.40 .60 .35 .15],...
    'Callback',{@pauseDuration_Callback,fh});
[~]	= uicontrol('Style','Edit',...
    'Tag','textLoopSurgery','String','Loop',...
    'Parent',panelHandle,...
    'Enable','inactive',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Position',[.05 .45 .35 .15]);
[~]	= uicontrol('Style','Text',...
    'Tag','emptyLoopSurgery','String','',...
    'Parent',panelHandle,...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Position',[.40 .45 .35 .15]);
[~]	= uicontrol('Style','popupmenu',...
    'Tag','loopSurgery','String',{'No'; 'Yes'},...
    'parent',panelHandle,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize,...
    'BackgroundColor',[1 1 1],'ForegroundColor',[0 0 0],...
    'Value',1,...
    'Position',[.40 .45 .35 .15],...
    'UserData',data.get('image'),...
    'Callback',{@loopSurgery_Callback,fh});
[~]	= uicontrol('Style','Push Button',...
    'Tag','startWatch','String','Start',...
    'Parent',panelHandle,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize*.4,...
    'BackgroundColor',[1 205/255 0],'ForegroundColor',[0 0 0],...
    'Position',[.05 .05 .285 .225],...
    'Tooltip','Interruptible = on',...
    'Interruptible','on',...
    'Callback',{@startWatch_Callback,fh});
[~]	= uicontrol('Style','Push Button',...
    'Tag','stopWatch','String','Stop',...
    'Parent',panelHandle,...
    'Value',false,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize*.4,...
    'BackgroundColor',[.8275 .8275 .8275],'ForegroundColor',[0 0 0],...
    'Position',[.35 .05 .285 .225],...
    'Callback',{@stopWatch_Callback,fh});
[~]	= uicontrol('Style','Push Button',...
    'Tag','continueWatch','String','Continue',...
    'Parent',panelHandle,...
    'Value',true,...
    'enable','on',...
    'FontUnits','normalized','Units','normalized',...
    'FontName','Default','FontSize',fontSize*.4,...
    'BackgroundColor',[.8275 .8275 .8275],'ForegroundColor',[0 0 0],...
    'Position',[.65 .05 .285 .225],...
    'Callback',{@continueWatch_Callback,fh});
end


%% Callback Functions.
function startWatch_Callback(hObject,~,fh,continuingWatch)

% Get initial condition described by other buttons.
siblings = allchild(hObject.get('Parent'));
stopWatch	= findobj(siblings,'Tag','stopWatch');
continueWatch	= findobj(siblings,'Tag','continueWatch');
adjustImageContrast	= findobj(siblings,'Tag','adjustImageContrast');
pauseDuration	= findobj(siblings,'Tag','pauseDuration');
loopSurgery	= findobj(siblings,'Tag','loopSurgery');
saveData	= findobj(allchild(fh),'Tag','saveData');
data	= saveData.get('UserData');
mainAxis    = gca;
imObj   = mainAxis.get('Children');
orgI	= data.get('image');

% Set looping condition.
count   = 1;

% Watch surgery, beginning with current image + 1.
fileList = findobj('Tag','fileList');
fileNames = fileList.get('String');
firstFile = fileList.get('Value');
iterateList = [fileNames(firstFile+1:end,:); fileNames(2:firstFile,:)];
imdir = get(findobj('Tag','loadDirectory'),'UserData');
while loopSurgery.get('Value') == 2 || count == 1
    %     [imObj,hObject] = watchSurgery(iterateList,adjustImageContrast,pauseDuration,mainAxis,data,hObject,imObj)
    for jdx = 1:length(iterateList)
%         % Allow for interuption.
%         clc,stopWatch.Value
%         waitfor(stopWatch,'Value',false);
        
        % Get image data.
        nextFileName	= fullfile(imdir,strtrim(iterateList(jdx,:)));
        nextI   = dicomread(nextFileName);
        
        % Plot adjusted image, if requested.
        options	= adjustImageContrast.get('String');
        if strcmp(options{adjustImageContrast.get('Value')},'Yes')
            % Equalize image.
            jdx
            plotI	= data.histeq(nextI,mainAxis);
            hObject.set('UserData','Adjusted');
            
        else
            plotI   = nextI;
            hObject.set('UserData','Original');
        end
        imObj.set('CData',plotI);
        
        % Respect pause.
        inputPause = pauseDuration.get('Value');
        if inputPause > 0
            pause(inputPause);
            
        elseif isnan(inputPause) || isinf(inputPause)
            pause
            
        else
            pause(0.0)
        end
    end
    count = 2;
    loopSurgery.set('Value',loopSurgery.get('Value'));
end

% Reset to original image.
imObj.set('CData',orgI);
end


% Stop Watching.
function stopWatch_Callback(hObject,~,fh)

% % Set continueWatch value to false.
% siblings = allchild(hObject.get('Parent'));
% continueWatch	= findobj(siblings,'Tag','continueWatch');
% continueWatch.set('Value',false);
% exitCriterion   = false;
% while ~exitCriterion
%     if continueWatch.get('Value')
%         exitCriterion   = true;
%     end
% end
end


% Continue Watching.
function continueWatch_Callback(hObject,~,fh)

% % Set stopWatch value to false.
% siblings = allchild(hObject.get('Parent'));
% stopWatch	= findobj(siblings,'Tag','stopWatch');
% stopWatch.set('Value',false);
% ['continueWatch value is: ',hObject.Value]
end


% Adjust Image Contrast.
function adjustimageContrast_Callback(hObject,~,fh)

% Retrieve image data.
saveData	= findobj(allchild(fh),'Tag','saveData');
mainAxis    = gca;
imObj   = mainAxis.get('Children');
data	= saveData.get('UserData');
hObject.set('UserData',imObj.get('CData'));         % Store original.

% Adjust main axis according to event.
options	= hObject.get('String');
if strcmp(options{hObject.get('Value')},'Yes')
    % Compute, plot contrasted image.
    newI	= data.histeq(imObj.get('CData'),mainAxis);
    imObj.set('CData',newI);
    
else
    % Unaltered image.
    imObj.set('CData',imObj.get('CData'));
end

end


% Pause Duration.
function pauseDuration_Callback(hObject,~,fh)

% Parse potential inputs.
inputStr    = hObject.get('String');
if str2double(inputStr) > 0
    pauseVal	= str2double(inputStr);
    printToLog(fh,['Next image will plot after ',inputStr,' seconds'],'Progress');
    
elseif strcmpi(hObject.get('String'),'pause')
    pauseVal	= inf;
    printToLog(fh,'Next image will display after hitting ''enter''','Progress');
    
elseif isempty(hObject.get('String')) || isnan(hObject.get('String'))
    pauseVal	= NaN;
    printToLog(fh,'Input not accepted; next image will display after hitting ''enter''','Error');
    
else
    pauseVal	= 0;
    printToLog(fh,'Next image will plot consecutively','Progress');
end

% Set pausing iteration value.
hObject.set('Value',pauseVal);
end


% Loop Surgery.
function loopSurgery_Callback(hObject,~,fh)

end


function [imObj,hObject] = watchSurgery(iterateList,adjustImageContrast,pauseDuration,mainAxis,data,hObject,imObj)
for jdx = 1:length(iterateList)
    % Get image data.
    nextFileName	= fullfile(imdir,strtrim(iterateList(jdx,:)));
    nextI   = dicomread(nextFileName);
    
    % Plot adjusted image, if requested.
    options	= adjustImageContrast.get('String');
    if strcmp(options{adjustImageContrast.get('Value')},'Yes')
        % Equalize image.
        plotI	= data.histeq(nextI,mainAxis);
        hObject.set('UserData','Adjusted');
        
    else
        plotI   = nextI;
        hObject.set('UserData','Original');
    end
    imObj.set('CData',plotI);
    
    % Respect pause.
    inputPause = pauseDuration.get('Value');
    if inputPause > 0
        pause(pauseDuration.get('Value'));
        
    elseif isnan(inputPause) || isinf(inputPause)
        pause
        
    else
        pause(0.0)
    end
end
end