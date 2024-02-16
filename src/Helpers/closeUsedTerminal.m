function [status, result] = closeUsedTerminal( pidStart, pidEnd )
%CLOSEUSEDTERMINAL Kill any terminal/cmd in use by the program.
%   [status, result] = CLOSEUSEDTERMINAL(pidStart, pidEnd) returns the
%   system status and result following a system call to taskkill of any
%   terminal(s)/cmd(s) that differ between pidStart and pidEnd, i.e. any
%   processes that began since the program began.
%   
%   See also GETERMINALEXECUTABLEPIDS.
%==========================================================================

if ispc
    pidClose= char( num2str( setdiff( pidEnd, pidStart ) ) );
    nOut	= size( pidClose, 1 );
    status  = cell( nOut, 1 );
    result  = cell( nOut, 1 );
    for idx = 1:nOut
        [status{idx}, result{idx}] =...
            system( ['TASKKILL /PID ', pidClose( idx,: ), ' /T /F'] );
    end
    
elseif isunix
    disp( 'need a routine for unix' );
    errordlg('need a routine for closing unix terminal');
    
elseif ismac
    disp( 'need a routine for mac' );
    errordlg('need a routine for closing mac terminal');
    
else
    % You're shit out of luck, dawg.
    disp( 'need a routine for whatever this OS is' );
    errordlg('need a routine for closing whatever OS this is'' terminal');
end


