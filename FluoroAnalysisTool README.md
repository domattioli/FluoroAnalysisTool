# FluoroAnalysisTool README
## Description of code directory:
- 'data' is intended to be example analysis. TBD.
- 'doc' is intended to be instructions/manual. TBD.
- 'lib' contains source-code downloaded from the internet to serve abstract purposes within the FluoroAnalysisTool.
- 'Projects' is intended to be space for the user to save their project state. TBD.
- 'src'
    - 00-Startup
        - Custom Data object classes for fluoros, types of bones,
        - GUI building routines, i.e. the "View" in Model-View-Controller paradigms.
        - main file ('main.m')
    - 01-Data_Management
        - Geometry and conversion routines for fluoro/image data.
        - Scripts for various tasks, which should eventually be included into a larger interface TBD.
    - 02-Procedures
        - Custom data object classes for the types of annotations that we do (e.g. DHS, PSHF).
    - 03-Neural_Net_Models (TBD)
        - Code for socketing MATALB to python and applying computer vision models.
    - 04-Non_GUI_Dependent_Scripts (TBD)
        - Niche scripts that perform tasks relevant to the interface, which should eventually be included into a larger interface TBD.
        - Image Processing algorithm for computing a precise wire width. Not sure if I ever implemented this TBD.
    - 05-Decision_Error_Processing (TBD)
        - Trevor's code for PSHF decision errors.
    - Helpers
        - Misc. code that should probably be moved to one of the previously-listed folders TBD.

## Steps for using this tool:
0. Make sure that you have properly imported the dicom exam.
- R:\Anderson_Colaborations\AHRQ - 11287500\Fluoroscopy
- Open and run 'OpenMe.m'. Read the instructions for importing a case.

1. Open main.m
- R:\Anderson_Colaborations\AHRQ - 11287500\FluoroAnalysisTool\src\00-Startup\main.m
2. Click 'Run' (or hit F5 when the main.m script is open and selected in the MATLAB interface.
- This will likely prompt MATLAB to ask you whether you want to change the directory.
  - Say/click 'Change Folder'.
- The FluoroAnalysisTool may take a second to start the first time.
- Pay attention for a prompt that asks whether you want to use AI tools.
  - Say/click 'no'.
3. Loading imported Data.
- Click 'Load Directory', select your DICOM folder.
- Click on one of the files in the folder.
- Then click 'Plot'.
4. Annotating data.
- In the 'Procedure' Panel, flick the drop-down and select your procedure.
  - Buttons for the annotation procedure should appear
  - I don't know if the DHS procedure still works, as of Nov 1, 2020.
- For PSHF:
  - Click 'Fracture Plane'
    - Left click two points to approximate the 3D plane in the 2D image.
    - Right click to confirm. Note that clicking more than 2 points may cause an error. If that happens, just try again. Worst case, restart the tool.
  - Click 'Wire N'
    - Beginning with the tip of the wire (pointy end), left click down the *centerline* of the wire.
    - Sometimes you only need 2 points.
    - When the wire is bent by the surgeon (so they can put the cast on), do not include this part of the wire.
    - Once you've traversed the length of the wire, (left) click one additional point *at the edge of the wire, perpendicular to your final centerpoint line*.
    - Right click to confirm.
      - Your "wire" should have at minimum 3 points, including the width point.
      - If you've done it correctly, the plot will show a rough outline of the width of the wire.
        - This won't be perfect, but that's ok. All we care about is the centerline for this procedure.
    - If you don't like where the algorithm roughly places the centerline, just click the same button again and redo it.
    - Repeat this until all 3 wires are defined.
      - Order *might* not be important (I think I have some code that deduces the left-to-right order of the wires along the fracture line), but just to be safe, make Wire 2 the middle wire.
  - When you have successfully defined all 3 wires and the fracture line, the 'Log' Panel will print off the relevant metrics.
    - Breadth of wires at fracture, mid-ratio
    - Make note of these in your excel sheet.
  - For lateral images, since we are only concerned with the breadth between the lateral and medial wires, feel free to skip annotating 'Wire 2' on these images.
    - If you annotate all 3 wires, the data will be saved, but the corresponding Mid-Ratio is not something that we are currently interested in using for our analysis.
 




--------------------------------------------------Ignore below this, as of Nov 1, 2020----------------------------
##### Created Using:
```sh
https://dillinger.io/
```

### Description
**FluoroAnalysisTool** is a MATLAB-built UI application for annotating DICOM image data.
- It currently supports *DHS* and *PSHF* surgeries.

### New Features
- None haha. Hopefully some AI CV stuff for automatic feature detection.
###### Last updated: 09 Sept. 2020

### Installation
- Matlab 2018a
    - Originally written.
    - **May not work on earlier versions!**
    - Toolboxes:
    - ...
- Python 3.7.3
    - Installed via command line
        - Default PATH variable.
    - Libraries: 
        - TensorFlow 1.14
        - Keras 2.24
        - h5py 2.80 (forced)
        - Numpy 1.16

### Startup Routine
    1. Navigate to the 'main.m' file [here](..\src\00-Startup\main.m)
    2. Run script (F5) to use GUI.

### Getting Started
    1. Click the 'Project Directory' folder.
        - This is where your 'Results.json' text files will be saved.
        - If you do not specify a folder, the results will be saved somewhere else...I forget where. ***edit this***
    2. Click the 'Login' Button on the toolbar toward the top-left
        - Enter your info
        - This is optional, but helpful because it is printed in the Results.json files that you produce.
    3. Load a directory of DICOMs
        - .dcm
    4. Plot File
    5. Select a procedure
    6. Follow the instructions in the log
        - Bottom right.
        
### Helpful Hints
- In the event of an error:
    - Screenshot both the UI and the MATLAB command window
    - Email Dominik with a description of what you clicked and what you were trying to do prior to the error.
    - Try restarting MATLAB and the application and try again. I ain't a perfect programmer, dawg.
- As of **September 2020** I (Dominik) disabled the AI stuff because of complications with socketing to the Python script that runs the neural network models.
    - If you know how to socket between MATLAB and Python and you know how to hide command prompts from the user, contact Dominik. 
- If you are doing the procedure correctly, there will not be any red text.
    - Red text in the Log is not fatal to the program.
- The application should autosave your data in your Project Directory as '###_Results.json'
