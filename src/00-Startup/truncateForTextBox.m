function outStr = truncateForTextBox(hObject, inStr)
%TRUNCATEFORTEXTBOX Truncate string to fit in object's textbox.
%   outStr = truncateForTextBox(obj, inStr) returns outStr abbreviated by
%   an elipsis ('...') such that the first and last characters of inStr are
%   displayed within the extent of the obj, which is a text (edit) box.
%   
%   See also
%==========================================================================

% Get position and extent of object.
textBoxPos	= hObject.get('Position');
textCurrentExtent	= hObject.get('Extent');

% Compute allotted characters.
nCharUsed	= length(hObject.get('String'));
nCharAllowed	= floor(textBoxPos(3)*(nCharUsed/textCurrentExtent(3))) - 1;

% Truncate string, if necessary.
if length(inStr) > nCharAllowed
    firstHalfStr    = inStr(1:floor(nCharAllowed/2));
    secondHalfStr   = inStr((end-floor(nCharAllowed/2)+1):end);
    outStr    = strcat(firstHalfStr(1:end-2), '...', secondHalfStr(4:end));
    
else
    outStr  = inStr;
end

