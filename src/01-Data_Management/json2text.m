function fid = json2text( JSON, fileName )
%JSON2TEXT Converts .json-format text into text file.
%
%   See also
%==========================================================================

% Open file, set-up for build.
fid	= fopen( fileName, 'wt' );
iChar	= 0;
nTabs	= 0;
addTabAfter	= false;
removeTabAfter   = false;
continueWritingLines	= true;

% Build lines.
while continueWritingLines
    % Initialize line.
    lineSTR	= "";
    if addTabAfter
        nTabs   = nTabs + 1;
        
    elseif removeTabAfter
        nTabs   = nTabs - 1;
    end
    formatSpec  = repmat('\t',1,nTabs);
    
    continueBuildingLine	= true;
    while continueBuildingLine
        % Get next character and append to line in-progress.
        iChar = iChar + 1;
        currentChar	= JSON(iChar);
        lineSTR	= strcat(lineSTR,currentChar);
        lenlineSTR  = strlength(lineSTR);
        
        % Check for syntax.
        if iChar == 1 || and(lenlineSTR == 1,strcmp(currentChar,"{"))
            % First bracket-right in text.
            addTabAfter	= true;
            removeTabAfter   = false;
            continueBuildingLine	= false;
            
        elseif and(strcmp(JSON(iChar-1),":"), strcmp(currentChar,"{"))
            % Begin next sub-data after bracket-right
            addTabAfter = true;
            removeTabAfter   = false;
            continueBuildingLine	= false;
            
        elseif (~strcmp(JSON(iChar-1),"}") && strcmp(currentChar,",")...
                && strcmp(JSON(iChar+1),""""))
            % Next line of sub-data.
            addTabAfter = false;
            removeTabAfter   = false;
            continueBuildingLine	= false;
            
        elseif and(strcmp(currentChar,":"), strcmp(JSON(iChar-1),""""))
            % Insert a space, continue previous sub-data.
            addTabAfter = false;
            removeTabAfter   = false;
            lineSTR	= strcat(extractBefore(lineSTR,":"),...
                ": ",extractAfter(lineSTR,":"));
            
        elseif and(strcmp(currentChar,"}"), lenlineSTR > 1)
            % Ready to end sub-data, pushing left-bracket to next line.
            iChar	= iChar - 1;
            lineSTR	= extractBefore(lineSTR,"}");
            
            addTabAfter = false;
            removeTabAfter   = true;
            continueBuildingLine	= false;
            
        elseif and(strcmp(JSON(iChar-1),"}"), strcmp(JSON(iChar),","))
            % End sub-data.
            addTabAfter = false;
            removeTabAfter   = false;
            continueBuildingLine	= false;
            
        elseif and(strcmp(lineSTR,"}"), iChar == strlength(JSON))
            % End text.
            addTabAfter = false;
            removeTabAfter   = false;
            formatSpec  = formatSpec(3:end);
            nTabs   = nTabs - 1;
            continueBuildingLine	= false;
            continueWritingLines    = false;
        end
    end
    
    
    % Print line.
    formatSpec  = strcat(formatSpec,'%s\n');
    fprintf(fid,formatSpec,lineSTR);
%         pause
end
fclose(fid);

