# Dependencies

MATLAB is required

# Usage

* Put image stacks (in TIFF format) to be analysed in test data set folder,
  each image stack needs to contain the same root name, plus an index (e.g.
  `c1.tif`, `c2.tif`, `c3.tif` etc...), rename image stacks if necessary.

* Double Click on main_tracking.m. Matlab should open now and display the file
  in the Matlab Editor. 

* In interactive mode: Check spot detection by inspecting the images popping up
  
  * red crosses mark identified spots on filtered image data (first figure)
  * values for SNR of filtered and unfiltered data are plotted on raw data
    (second figure)

* change paramters if necessary

  * Set `parameters.interactive` to 0

## Output

* Various spot detection result/control plots are created and saved in the
  respective folder

* An .avi-file showing the tracking results is created and saved

  It is recommended to check the tracking quality by looking at the .avi-file,
  and change tracking parameters if necessary

* Various tracking and trajectory analysis result plots are created and saved
  in the respective folder. Detailed explanation of the Results can be found in
  the accompanying PDF-file.

* It is recommended to check the start values for the JD analysis

Type in setup and results, in Matlab commmand window, detailed explanation of
the content of these Matlab structures can be found in the accompanying
PDF-file.
