function gtm = ApproxGroundTruth(folderName, results, wireWidthGuess)

% Get image data.
img = dicomread(fullfile(folderName, results.File_Information.DICOM));

% Get wire geometry.
xyWire	= results.Geometry.Wire_XY;
mWire   = diff(xyWire(:,2))/diff(xyWire(:,1));
bWire	= xyWire(1,2) - (xyWire(1,1)*mWire);

% Create box around wire to mask the irrelevant data.
pmb = [ceil(bWire+wireWidthGuess); floor(bWire-wireWidthGuess)];
boxXY	= [xyWire(1,1) mWire*xyWire(1,1)+pmb(1);...
    xyWire(1,1) mWire*xyWire(1,1)+pmb(end);...
    xyWire(2,1) mWire*xyWire(2,1)+pmb(end);...
    xyWire(2,1) mWire*xyWire(2,1)+pmb(1)];
BW	= roipoly(img,boxXY(:,1),boxXY(:,2));

% Grab pixel data within mask.
wireImg     = img;
wireImg(~BW)    = false;
subImg	= zeros(size(find(BW==true)), 'uint16');
subImg(1:end)   = wireImg(BW);
bw	= imbinarize(subImg, 'adaptive');
gtm     = false(size(wireImg));
gtm(BW) = bw;




