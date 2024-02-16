function [tcp, success] = initializeSocketListener()
%INITIALIZESOCKETLISTENER Create python server MATLAB client socket.
%   tcp = INITIALIZESOCKETLISTENER() returns the TCP/IP object following
%   its instantiation and opening.
%   
%   Note: INITIALIZESOCKETLISTENER interfaces with a .py script that is
%   hard-coded to use port number 50,007.
%   
%   [tcp, success] = INITIALIZESOCKETLISTENER() returns a logical stating
%   whether the socket successfully connected.
%   
%   See also DESTROYSOCKETLISTENER, INITIALIZEM2MY.
%==========================================================================

try
    % Navigate cd to neural net code.
    pathCell	= regexp( path, pathsep, 'split' );
    ipyFiles	= contains( pathCell, 'Neural_Net_Models' );
    nnModelsDir = pathCell{ find( ipyFiles, 1, 'first' ) };
    cdOG	= cd;
    pathName    = fullfile( nnModelsDir, 'Socket_Model' );
    cd( pathName );
    
    % Getidentity of CMD.exe that are open to compare with afterwards.
    pidStrs     = struct( 'Start', getTerminalExecutablePIDs(), 'End', [] );
    
    % Start the echo server, minimize the window.
    !python main.py &
%     [status, result] = system('\MIN C:\WINDOWS\SYSTEM32\cmd.exe' )
    pidStrs.End = getTerminalExecutablePIDs();
    
    % Connect to the server
    portNumber  = 50007;
    tcp	= tcpip( 'localhost', portNumber, 'Tag', 'NNModels' );
    keepTrying  = true;
    attempt	= 0;
    while keepTrying
        try
            if attempt == 10
                success = false;
                return
            end
            attempt = attempt + 1;
            fopen( tcp );
            keepTrying  = false;
        catch
            % Try to find the open ports.
%             hdldaemon('socket', 0 );  % This requires HDL Verifier.
        end
    end
    
    % Wait for permission from python to proceed.
    bytes	= fread( tcp, [1, tcp.BytesAvailable], 'char' );
    inMessage	= char( bytes( 2:end ) );
    counter	= 0;
    while isempty( inMessage )
        % Socket is opened when '-1' is returned from the python server.
        bytes	= fread( tcp, [1, tcp.BytesAvailable], 'char' );
        inMessage	= char( bytes( 2:end ) );
        counter = counter + 1;
        if counter >= 50
            error( struct( 'identifier',...
                'FluoroAnalysisTool:initializeSocketListener:FailedToOpenSocket',...
                'message', 'Socket server failed to open in python.',...
                'stack', dbstack ) )
        end
    end

    % Save name of terminal executable in socket object's userdata.
    tcp.UserData	= pidStrs;
    success	= true;
    cd( cdOG );
catch
    success	= false;
end

