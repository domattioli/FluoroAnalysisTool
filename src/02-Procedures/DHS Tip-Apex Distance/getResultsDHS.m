function [data, success] = getResultsDHS(fhHandles, data, fieldNames)
%GETRESULTSDHS Computes DHS result.
%   [data, success] = GETRESULTSDHS(fhHandles, data, fieldNames) displays a
%   log message of computed TAD along with the estimated wire width in both
%   px and mm. GETRESULTSDHS also returns the updated fluoroProcess object
%   data containing the wire width defined by the user in the UI.
%   
% See also BUILDINTERFACEDHS.
%==========================================================================

% Check existence of femoral head, femoral neck, wire slope objects.
fh  = gcf;
result = data.get('Result');
FH  = result.( fieldNames{ contains( fieldNames, 'Head' ) } );
FN  = result.( fieldNames{ contains( fieldNames, 'Neck' ) } );
WS  = result.( fieldNames{ contains( fieldNames, 'Slope' ) } );
WW  = result.( fieldNames{ contains( fieldNames, 'Width' ) } );

% Retrieve wire width selection, if not already done by user.
success	= false;
try
    panelDHS    = findobj( fhHandles.Procedure_Foreground.get( 'Children' ),...
        'Tag', data.get( 'Procedure' ) );
    siblings    = panelDHS.get( 'Children' );
    ww_obj  = findobj( siblings, 'Tag',...
        strrep( fieldNames{ contains( fieldNames, 'Width' ) }, '_', ' ' ) );
    ww_mm   = ww_obj.String{ ww_obj.get( 'Value' ) };
    wireWidth   = struct('MM', str2double( ww_mm ), 'PX', WS.Width );
    pxPerMM	= wireWidth.PX / wireWidth.MM ;
    result.Wire_Width	= wireWidth;
    data.set( 'Result', result );
catch
    return
end

if or(isempty(FN), isempty(WS))
    printToLog(fh, 'Cannot compute TAD', 'Note');
    return

else 
    % Try to compute the Tip-Apex Distance in the current plane [px and mm].
    try
        % Get location of wire tip.
        xyWS	= vertcat(WS.Plot.get('XData'), WS.Plot.get('YData'));
        xyWireTip	= xyWS(:,2);
        
        % Get intersection location of Neck Bisector with Femoral Head Ellipse.
        xyBisector  = vertcat(FN.Bisector.get('XData'), FN.Bisector.get('YData'));
        xyTipApex	= xyBisector(:,1);
        
        % Compute euclidean distance (in [pixels]) between wireTipXY and tipApexXY.
        TADpx	= pdist(horzcat(xyWireTip, xyTipApex)', 'euclidean');
        TADmm	= TADpx/pxPerMM;                        % Scale to screen size.
        if TADmm < TADpx                                % TEMPORARY GUESS!
            WW.PX   = 20;
            pxPerMM	= WW.PX/WW.MM;
            TADmm	= TADpx/pxPerMM;  
        end
        %     mm2in   = 1/25.4;
        
        % Compute angle between xyWireTip and xyTipApex.
        % mWire   = abs(diff(xyWire(2,1:2))/diff(xyWire(1,1:2)));
        % mNeckBisector	= abs(diff(xyNeckBisector(2,1:2))/diff(xyNeckBisector(1,1:2)));
        % Angle	= abs(atand(mWire) - atand(mNeckBisector));
        
        % Display TAD progress to user.
        printToLog(fh, 'DHS Tip-Apex Distance successfully completed', 'Success');
        strWireWidthpx	= sprintf('%g', WW.PX);
        strWireWidthmm	= sprintf('%g', WW.MM);
        strmmTAD    = sprintf('%1.1f', TADmm);
        strpxTAD    = sprintf('%1.0f', TADpx);
        printToLog(fh, ['Wire Width: ~', strWireWidthmm, ' mm (~', strWireWidthpx, ' px)'], 'Note');
        printToLog(fh, ['Computed TAD: ~', strmmTAD,' mm (~',strpxTAD,' px)'], 'Note');
        
        % Output.
        success	= true;
        
    catch
        printToLog(fh, 'Cannot compute TAD', 'Note');
    end
end

