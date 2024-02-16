function selection = appendToListBox( fh, hObject, dialogs )
%APPEND2LISTBOX Append user-inputted selection to listbox UI.
%   selection = APPEND2LISTBOX( fh, hObject, dialogs ) returns the appended
%   selection as a string to the user, where dialogs are the message
%   prompts for guiding the user's input.
%   
%   See also
%==========================================================================

options	= hObject.get( 'String' );
nOptions    = size( options, 1 );
ioptions	= hObject.get( 'Value' );
if ioptions == 1
    selection	= NaN;
    printToLog( fh, dialogs{ 1 }, 'Note' )
else
    if ioptions == nOptions
        continueLoop	= true;
        while continueLoop
            selection	= inputdlg( dialogs{ 2 }, 'Manual Entry' );
            strDouble	= str2double( selection );
            if isnan( strDouble )
                waitfor( errordlg( dialogs{ 3 }, 'Incorrect Input.' ) );
            else
                % Rewrite list of options.
                currentOptions  = [cellfun( @str2double,...
                    options( setdiff( 1:nOptions, [1 nOptions] ) ) ); strDouble];
                scurrentOptions	= sort( currentOptions );
                newOptions  = [options{ 1 }; cell( length( currentOptions ), 1 ); options{ end }];
                newOptions( 2:end-1 )	= strtrim( cellstr( num2str( scurrentOptions ) ) );
                inewOptions = find( ismember( scurrentOptions, strDouble ) ) + 1;
                hObject.set( 'String', newOptions, 'Value', inewOptions );
                continueLoop	= false;
            end
        end
    else
        selection	= options{ ioptions };
    end
end

