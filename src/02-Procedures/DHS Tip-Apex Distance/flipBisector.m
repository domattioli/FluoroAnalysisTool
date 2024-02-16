function FN	= flipBisector( FN, FH, chosenSide )
%FLIPBISECTOR Flip x- y- coordinate array of femoral neck.
%	FN	= FLIPBISECTOR(FN, FH, chosenSide) returns the femoralNeckObject FN
%   containing the line objects overlayed to the position of a UIControl
%   imline object for the femoral neck and its consequent perpendicular
%   bisector.
%	
%   See also FLIPWIRE, FEMORALNECKPERPENDICULARBISECTORXY,
%   DEFINEFEMORALNECK.
%==========================================================================

% Get Femoral Neck [x,y] line data and compute slope.
pxXY	= vertcat( FN.Plot.get( 'XData' ), FN.Plot.get( 'YData' ) );
pxM	= diff( pxXY( 2, : ) ) / diff( pxXY( 1, : ) );

% Get Femoral Head [x,y] ellipse data.
eXY	= vertcat( FH.Plot.get( 'XData' ), FH.Plot.get( 'YData' ) );

% Create new bisector of Femoral Neck with opposite slope.
pbXY	= femoralNeckPerpendicularBisectorXY( pxXY, pxM, eXY, chosenSide );

% Update femoral neck object.
FN.Bisector.set( 'XData', pbXY( 1, : ), 'YData', pbXY( 2, : ) );

