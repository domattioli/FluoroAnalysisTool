function pids = getTerminalExecutablePIDs()
%GETTERMINALEXECUTABLEPIDS Returns pids of all currently-open windows.
%   pids = GETTERMINALEXECUTABLEPIDS() returns an Mx1 cell array of pids
%   corresponding to all open cmd.exe windows (or _ for max/unix).
%   
%   See also CLOSEUSEDTERMINAL
%==========================================================================

if ispc
    % Get set of all current cmd processes.
    [status, result] = system( 'TASKLIST |find "cmd.exe"' );
    
    if status
        pids = {};
    else
        % Parse result text.
        strCell = strsplit(result);
        items	= reshape(strCell(1:end-1), 6, [])';
        pids    = items(:, 2);
    end
elseif isunix
    % Get set of all current cmd processes.
    [status, result] = system('TASKLIST |find "cmd.exe"');
    
    if status
        pids = {};
    else
        % Parse result text.
        strCell = strsplit(result);
        items	= reshape(strCell(1:end-1), 6, [])';
        pids    = items(:, 2);
    end
else
    % You're shit out of luck dawg.
    
end

% Conver char in cells to numbers
pids	= cellfun(@str2num, pids);

