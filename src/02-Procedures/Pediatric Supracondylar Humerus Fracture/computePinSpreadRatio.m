function ratio = computePinSpreadRatio(xyEF, xyInt)
%COMPUTEWIREBREADTH Compute breadth between outermost wires.
%	breadth = COMPUTEWIREBREADTH(xyInt) returns the euclidean distance
%	between the first and third wires (two outermost) of the set in pixels.
%   
%   See also PRODUCERESULTSPSHF.
%==========================================================================

% Assume first and third wires correspond to xyInt (TEMPORARY!).
breadthWire	= sqrt((xyInt(1,1)-xyInt(3,1))^2 + (xyInt(1,2)-xyInt(3,2))^2);

% Compute fracture breadth.
breadthFrac = sqrt((xyEF(1,1)-xyEF(2,1))^2 + (xyEF(2,1)-xyEF(2,2))^2);

% Compute ratio of wire breadth over fracture breadth.
ratio = breadthWire/breadthFrac;

