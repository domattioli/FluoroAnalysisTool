function [success, dcm] = img2DICOM( fileNames, startDir, endDir )
%IMG2DICOM Converts img to dicom file.
%   [success, dcm] = IMG2DICOM( filenames, startDir, endDir ) converts the
%   images to DICOMs. Returns true if successfull.
%   
%   Note that IMG2DICOM assumes an image as a 3D array, and it saves the
%   image as an axis in a figure. This saved axis then is converted to a
%   .dcm file.
%
%   See also DICOM_2_TIF.
%==========================================================================

f	= figure();
f.WindowState	= 'Minimized';
wb  = waitbar( 0, 'Converting images to DICOM files...' );
try
    dcm	= cell( numel( fileNames), 1 );
    for idx	= 1:numel( fileNames )
        try
            img = imread( fullfile( startDir, fileNames{ idx } ) );
        catch
            % Image reading failed, may be because the image is corrupt.
            % Should probably still "load" an image that denotes a problem
            img = zeros( size( img ) );
        end
        
        %------------------------------------------------------------------
        % Not sure what the circumstances were that originally required the
        % following code. Commented out for now, because I don't need it if
        % the image is a grayscale 2D input.
%         if size( img, 3 ) == 1
%             imshow( img, [], 'Parent', gca );
%         else
%             imshow( img( :, :, 1:3 ), [], 'Parent', gca );
%         end
%         saveas( f, fullfile( endDir, 'tempfig.bmp' ) );
%         jmg	= imread( fullfile( endDir, 'tempfig.bmp' ) );
%         if size( jmg, 3 ) >= 3
%             jmg	= rgb2gray( jmg( :, :, 1:3 ) );
%         end
        %------------------------------------------------------------------
        jmg = img;
        newfilename	= fullfile( endDir, strrep( fileNames{ idx }, '.tif', '.dcm' ) );
        dicomwrite( jmg, newfilename );
        dcm{ idx }  = dicominfo( newfilename );
        waitbar( idx/numel( fileNames ), wb );
%         waitbar( idx/numel( fileNames ), wb, ['Converting images to',...
%             ' DICOM files (', num2str( idx/numel( fileNames ) ), '%)...'] );
    end
    wb.delete();
    delete( fullfile( endDir, 'tempfig.bmp' ) );
    success	= true;
    
catch
    wb.delete();
    errordlg( 'Convertion failed - this could be because of the image format type or because the image is grayscale', 'Convesion Failure' );
    success	= false;
end
close( f );
