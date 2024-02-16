function [tcp, success] = destroySocketListener( tcp )
%DESTROYSOCKETLISTENER Destroy python server matlab client socket.
%   tcp = DESTROYSOCKETLISTENER(tcp) returns the TCP/IP object following
%   its closing.
%   
%   [tcp, success] = DESTROYSOCKETLISTENER(tcp) returns a logical stating
%   whether the socket successfully disconnected.
%   
%   See also INITIALIZESOCKETLISTENER, INITIALIZEM2MY.
%==========================================================================

try
    % Close socket.
    fwrite( tcp, 'Terminate' );
    bytes	= fread( tcp, [1, tcp.BytesAvailable], 'char' );
    inMessage	= char( bytes( 2:end ) );
    
    % Close successful on python end - complete on matlab end.
    fclose( tcp );
    
    % Close command/terminal window.
    pids = tcp.UserData;
    [status, result] = closeUsedTerminal( pids.Start, pids.End );
    
    % Look at Open Instrument Objects and then close them all.
    insObj	= instrfindall( 'Tag', 'NNModels' );
    for idx = 1:length( insObj )
        fclose( insObj( idx ) );
    end
    success = true;
    
catch
    success	= false;
end

