classdef fluoroProcess < handle & matlab.mixin.SetGet
    %FLUOROPROCESS Object defining analysis info of Fluoro derived.
    % Note: Changed properties' characteristics. all are public-settable as
    % of 7/5/19.
    %   The following immutable, public properties are:
    %       - caseID: The name of the surgery case (folder).
    %       - fileName: The name of the fluoro being processed.
    %   The following public properties are:
    %       - operations: The GUI callback outputs w.r.t. the procedure.
    %       - procedure: The surgical procedure for analysis.
    %       - result: Computed data.
    %   The following immutable, public, hidden properties are:
    %       - DICOM: All DICOM info from dicominfo of fluoro.File.
    %       - image: All graphics info from dicomread of fluoro.File.
    %   The following private, public, hiddenproperties are:
    %       - plotted: True/False w.r.t. main GUI axis.
    %======================================================================
    
    properties (SetAccess = public, GetAccess = public, Hidden = false)
        CaseID	= char();       % Folder holding all DICOM files for a surgery.
        DICOM	= struct([]);
        FileName	= char();	% DICOM File name plus extension.
        Image	= [];
        Models  = NaN;
        Plotted {mustBeNumericOrLogical} = false;
        Procedure   = NaN;
        Result  = NaN;
        User    = NaN;
        View    = NaN;
    end
    
    
    methods (Static = false) % Instantiation Constructor + general methods.
        function fluoro = fluoroProcess(varargin)
            %FLUOROPROCESS Constructs an instance of this class.
            %   Takes file location data and instantiates an object for
            %   storing data on the inputted fluoro and it's analysis.
            %
            % See also FLUOROPROCESS.
            %==============================================================
            
            % Set-protected, get-public properties.
            narginchk(0, 3);
            if (nargin == 0)
                return
                
            elseif (nargin == 1)
                [fluoro.CaseID, fluoro.FileName] = fileparts(varargin);
                
            else % (or(nargin == 2), nargin == 3))
                fluoro.CaseID	= varargin{1};
                fluoro.FileName	= varargin{2};
                if (nargin == 3)
                    fluoro.Procedure    = varargin{3};
                end
            end
            
            % Set derivable properties.
            ffn	= fullfile(fluoro.CaseID, fluoro.FileName);
            fluoro.DICOM    = dicominfo(ffn);
            fluoro.Image	= dicomread(ffn);
        end
        
        
        function fluoro = initResult(fluoro, procedureObj)
            %INITRESULT Generate result struct from dynamic fieldnames.
            %   fluoro = INITRESULT(procedureObj) assigns a struct to the
            %   fluoro 'Result' property, which is initialized from the
            %   fieldnames of procedureObj - a dynamic reference to a
            %   fluoro analysis procedure with it's own unique buttons. The
            %   buttons of procedureObj are dynamic and subject to user
            %   input, therefore the 'Result' will change whenever a new
            %   procedure is selected.
            %
            %   See also FLUOROPROCESS.
            %==============================================================
            
            % Assign respective button tags of the procedure to new struct.
            uiTagStrs   = procedureObj.get('Children').get('Tag');
            fieldNames	= strrep(uiTagStrs, ' ', '_');
            structValues	= cell(length(fieldNames), 1);
            fluoro.set('Result', cell2struct(structValues, fieldNames));
        end
        
        
        function out = outputFluoro(fluoro)
            %OUTPUTFLUORO Construct output struct for saving data.
            %   out = OUTPUTFLUORO(fluoro) returns a struct comprised of
            %   a relevant fluoro data to be saved.
            %   
            %   See also FLUOROPROCESS.
            %==============================================================
            
            % Assemble output structure as variant of data object.
            [~, caseID]	= fileparts(fluoro.get('CaseID'));
            dicom   = fluoro.get('DICOM');
            out = struct('CaseID', caseID,...
                'FileName', fluoro.get('FileName'),...
                'Surgeon', NaN,...
                'DateStamp', dicom.ContentDate,...
                'TimeStamp', dicom.ContentTime,...
                'View', fluoro.get('View'),...
                'Procedure', fluoro.get('Procedure'),...
                'Result', NaN,...
                'User', NaN,...%fluoro.User,...
                'Modified', datestr(datetime('now')));
            if isa(fluoro.get('User'), 'cell')
                userStr     = fluoro.get('User');
                out.User = [userStr{1}, ', ', userStr{2}];
            end
            if ~isempty(dicom.PerformingPhysicianName.FamilyName)
                out.Surgeon = horzcat(...
                dicom.PerformingPhysicianName.FamilyName, ', ',...
                dicom.PerformingPhysicianName.GivenName(1));
            end
        end
        
        
        function status = isDICOM(fluoro)
            if isa(fluoro, 'fluoroProcess')
                status	= true;
            else
                status	= false;
            end
        end
        
        
    end
    
    
    methods (Static = true)
        function newI   = histeq(I, Parent)
            %HISTEQ Equalize histogram of focused image in fluoro.
            %   newI = HISTEQ(image,parent) returns the image newI, where
            %   the imhist of newI ignore the fluoro data beyond the
            %   circular focus of the image. Parent is the axis holding I.
            %
            %   See also
            %==============================================================
            
            % Identify bounding box of image (the circle); create mask.
            bw     = fluoroProcess.findPinhole(I, Parent);
            
            % Equalize the sub-image defined by the bounding box.
            idx_bw	= find(bw);
            nPx	= length(idx_bw);
            f	= 2; % factored divisor.
            if rem(nPx,2) == 1
                % Take all but last pixel in image.
                idx_bw	= idx_bw(1:end-1);
                subI	= zeros(f,(nPx-1)/f,'uint16');
                
            else
                % checkout factor function.
                subI    = zeros(f,nPx/f,'uint16');
            end
            subI(:) = I(idx_bw);
            eqsubI	= histeq(subI);
            
            % Create adjusted image.
            newI    = I;
            newI(idx_bw)	= eqsubI;
        end
        
        
        function bw     = findPinhole(I, Parent)
            %FINDPINHOLE Finds pinhole of fluoro image.
            %   bw = FINDPINHOLE returns the binary image defined by the
            %   fluoro pinhole, that is, all false values are outside of
            %   the pinhole.
            %   
            %   See also
            %==============================================================
            
            % Identify bounding box of image (the circle); create mask.
            [~, left]	= find(I > 0,1, 'first');
            [~, right]	= find(I > 0,1, 'last');
            [~, top]	= find(I' > 0,1, 'first');
            [~, bottom]	= find(I' > 0,1, 'last');
            pos     = [left, top, right-left, bottom-top];
            try
                imCircle = imellipse(Parent, pos);
            catch
                try
                    Parent  = gca;
                catch
                    figure;
                    Parent  = gca;
                end
                imCircle = imellipse(Parent, pos);
            end
            bw	= imCircle.createMask();
            delete(imCircle);
        end
    end
      
    
    methods % Getters and Setters
        function value = get.CaseID(self)
            value = self.CaseID;
        end
        
        
        function set.CaseID(self, value)
            self.CaseID	= value;
        end
        
        
        function value = get.DICOM(self)
            value = self.DICOM;
        end
        
        
        function set.DICOM(self, value)
            self.DICOM	= value;
        end
        
        
        function value = get.FileName(self)
            value = self.FileName;
        end
        
        
        function set.FileName(self, value)
            self.FileName	= value;
        end
        
        
        function value = get.Image(self)
            value = self.Image;
        end
        
        
        function set.Image(self, value)
            self.Image	= value;
        end
        
        
        function value = get.Models(self)
            value = self.Models;
        end
        
        
        function set.Models(self, value)
            self.Models	= value;
        end
        
        
        function value = get.Plotted(self)
            value = self.Plotted;
        end
        
        
        function set.Plotted(self, value)
            self.Plotted	= value;
        end
        
        
        function value = get.Procedure(self)
            value = self.Procedure;
        end
        
        
        function set.Procedure(self, value)
            self.Procedure	= value;
        end
        
        
        function value = get.Result(self)
            value = self.Result;
        end
        
        
        function set.Result(self, value)
            self.Result	= value;
        end
        
        
        function value = get.User(self)
            value = self.User;
        end
        
        
        function set.User(self, value)
            self.User	= value;
        end
        
        
        function value = get.View(self)
            value = self.View;
        end
        
        
        function set.View(self, value)
            self.View	= value;
        end
    end
    
    
end
