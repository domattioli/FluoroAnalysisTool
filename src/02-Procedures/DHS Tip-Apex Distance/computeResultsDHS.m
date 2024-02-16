function [data, success] = computeResultsDHS(fhHandles, data, fieldNames)
%COMPUTERESULTSDHS Computes DHS result.
%   [data, success] = computeResultsDHS(fhHandles, data, fieldNames)
%   returns
%   
% See also BUILDINTERFACEDHS.
%==========================================================================

% Get handles to femoral head, femoral neck, and wire slope.
fh  = gcf;
results = data.get('Result');
iWW	= contains(fieldNames, 'Width');
iWS	= contains(fieldNames, 'Slope');
iFN	= contains(fieldNames, 'Neck');
WW  = results.(fieldNames{iWW});
WS  = results.(fieldNames{iWS});
FN  = results.(fieldNames{iFN});

% Retrieve relevant DHS Operation information; if any are absent - return.
if isempty(WW)
    % Pull currently-selected wire width.
    wireWidthUIC	= findobj(fhHandles.Procedure_Foreground,...
        'Tag', strrep(fieldNames{iWW}, '_', ' '));
    wireWidthOptions	= wireWidthUIC.get('String');
    wireWidthStr    = wireWidthOptions{wireWidthUIC.get('Value')};
    WW  = struct('MM', str2double(wireWidthStr), 'PX', []);
    try
        WW.PX   = estimateWireWidth(fh, hObject, saveData.UserData, userData{2, 2});
    end
end

% Compute Tip-Apex Distance in pixels and mm.
try
    % Get location of wire tip.
    xyWS	= vertcat(WS.Plot.get('XData'), WS.Plot.get('YData'));
    xyWireTip	= xyWS(:,2);
    
    % Get intersection location of Neck Bisector with Femoral Head Ellipse.
    xyBisector  = vertcat(FN.Bisector.get('XData'), FN.Bisector.get('YData'));
    xyTipApex	= xyBisector(:,1);
    
    % Compute euclidean distance (in [pixels]) between wireTipXY and tipApexXY.
    TADpx	= pdist(horzcat(xyWireTip, xyTipApex)','euclidean');
    pxPerMM	= WW.PX/WW.MM;
    TADmm	= TADpx/pxPerMM;                        % Scale to screen size.
%     mm2in   = 1/25.4;
    
    % Compute angle between xyWireTip and xyTipApex.
    % mWire   = abs(diff(xyWire(2,1:2))/diff(xyWire(1,1:2)));
    % mNeckBisector	= abs(diff(xyNeckBisector(2,1:2))/diff(xyNeckBisector(1,1:2)));
    % Angle	= abs(atand(mWire) - atand(mNeckBisector));
    
    % Display TAD progress to user.
    printToLog(fh, 'DHS Tip-Apex Distance successfully completed', 'Success');
    strWireWidthpx	= sprintf('%g', WW.PX);
    strWireWidthmm	= sprintf('%g', WW.MM);
    strmmTAD    = sprintf('%g', TADmm);
    strpxTAD    = sprintf('%g', TADpx);
%     strinTAD    = sprintf('%g', TADmm*mm2in);
    printToLog(fh, ['Estimated Wire Width: ~', strWireWidthmm,...
        ' mm (~', strWireWidthpx, ' px)'], 'Note');
    printToLog(fh, ['Computed TAD: ~', strmmTAD,' mm (~',strpxTAD,' px)'], 'Note');
    
    % Output.
    data	= updateResults(data, fieldNames, iWW, WW);
    success	= true;
    
catch
    success	= false;
    printToLog(fh, 'Cannot compute TAD', 'Note');
end

