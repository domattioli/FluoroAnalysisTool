function xyPB	= femoralNeckPerpendicularBisectorXY( xyFN, mFN, xyFH, chosenSide )
%FEMORALNECKPERPENDICULARBISECTORXY Computes the perpendicular bisector.
%   xyPB = FEMORALNECKPERPENDICULARBISECTORXY(xyFN, mFN, xyFH, chosenSide)
%   returns the x- and y-coordinates of the femoral neck's perpendicular
%   bisector, where the end points of the bisector lie on the femoral
%   head's ellipse points defined by xyFH.
%   
%   FEMORALNECKPERPENDICULARBISECTORXY assumed that xyFN and xyFH are
%   oriented such that x-coordinates are in the first column and
%   y-coordinates are in the second column. The outputs are the same.
%   
%   See also FLIPBISECTOR, DEFINEFEMORALNECK.
%==========================================================================

% Find a linear EQ for the perpendicular bisector of the labeled fem. neck.
xLim	= get( gca, 'XLim' );
mPB	= -1/mFN;
bPB = mean( xyFN( 2, : ) ) - mPB*mean( xyFN( 1, : ) );
if strcmpi( chosenSide( 1 ), 'L' )
    ixLim   = 1;
else
    ixLim   = 2;
end

% Extend perp. bisector to axis limits, given EQ of line.
full_xyPB	= horzcat( mean( xyFN, 2 ),...        % [x1 x2; y1 y12]
    vertcat( xLim( ixLim ), mPB*xLim( ixLim )+bPB ) );
xyPB	= InterX( full_xyPB, xyFH );

% Forgot what I'm doing here.
if isempty( xyPB )
    xyPB	= InterX(...
        vertcat( mean( xyFN, 1 ), horzcat( xLim( 1 ), mPB*xLim(  1 )+bPB ) )',...
        xyFH );
end
if numel( xyPB ) == 2
    xyPB	= horzcat( xyPB, full_xyPB( :, 1 ) );
end

