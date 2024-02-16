function wb = advanceWaitBar( wb, N, wbMessage, wbPause )
%ADVANCEWAITBAR Advance display in waitbar.
%   wb = ADVANCEWAITBAR(wb, N, wbMessage, wbPause) returns the waitbar
%   currently at N(1) advanced to N(2) (must be <= 1.0). The displayed
%   message is wbMessage, and the pause is wbPause.
%
%   See also
%==========================================================================

% Check input.
if nargin < 4
    wbPause	= .025;
end
if N( 2 ) > 100
    N( 2 )	= 100;
end

% Advance wait bar.
for idx = N( 1 ):1:N( 2 )
    waitbar( idx/100, wb, wbMessage );
    pause( wbPause );
end

