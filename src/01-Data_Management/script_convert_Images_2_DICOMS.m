folder = 'D:\OG_Fluoros\Pediatric_Elbow\Images\2_wires\086';
d = dir( folder );
filenames = {d.name}';
filenames( 1:2 ) = [];
savedir = 'D:\OG_Fluoros\Pediatric_Elbow\DICOM\2_Wires\086';
success = img2DICOM( filenames, folder, savedir )

folder = 'D:\OG_Fluoros\Pediatric_Elbow\Images\3_Wires\083';
d = dir( folder );
filenames = {d.name}';
filenames( 1:2 ) = [];
savedir = 'D:\OG_Fluoros\Pediatric_Elbow\DICOM\3_Wires\083';
success = img2DICOM( filenames, folder, savedir )


folder = 'D:\OG_Fluoros\Pediatric_Elbow\Images\3_Wires\084';
d = dir( folder );
filenames = {d.name}';
filenames( 1:2 ) = [];
savedir = 'D:\OG_Fluoros\Pediatric_Elbow\DICOM\3_Wires\084';
success = img2DICOM( filenames, folder, savedir )


folder = 'D:\OG_Fluoros\Pediatric_Elbow\Images\3_Wires\085';
d = dir( folder );
filenames = {d.name}';
filenames( 1:2 ) = [];
savedir = 'D:\OG_Fluoros\Pediatric_Elbow\DICOM\3_Wires\085';
success = img2DICOM( filenames, folder, savedir )