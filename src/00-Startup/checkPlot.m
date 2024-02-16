function success = checkPlot( data, resetLimits )
%CHECKPLOT Make sure plotted DICOM is same as selected DICOM.
%   success = checkPlot(data) returns 'false' if the currently-selected
%   DICOM in the File List is not the same as the one plotted in the GUI's
%   main axis.
%   
%   success = checkPLOT(data, resetLimits) will reset the axis limits if
%   the second input is true and if the prior condition holds. The default
%   value (nargin == 1) assumes that a reset is desired.
%   
%   See also 
%==========================================================================

% Check input.
if nargin == 1
    resetLimits	= true;
end

% Ensure DICOM plot exists.
if strcmp( data.get( 'Display' ), 'off' )
    printToLog( gcf, ['Cannot define ''', data.get( 'Procedure' ).get( 'Name' ),...
        ''' until currently-selected DICOM is Plotted'], 'Error' );
    success	= false;
else
    success	= true;
    if resetLimits
        % Reset axis limits to default.
        data.resetAxisLimits();
    end
end

