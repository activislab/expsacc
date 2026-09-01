# PSA\_FBE



Simplified codes depicting the experimental procedures in the main and additional experiments.

Software needed:

MATLAB (MathWorks);
Psychtoolbox;
VIEWPixx/3D (VPixx Technologies);
Eyelink (SR Research). Eyelink codes were removed from the scripts below.



\-------------------------------

Main experiment codes(PSA\_FBE):

\-------------------------------

"Infos\_FBE" creates all variables needed to run the experiment for each subject and session.
"On\_Screen" function runs the trials on screen.
"Runner" loads the created dataset and calls the On\_Screen function.
"gabor\_masknoise" folder contains scripts to create the gabor and noise patches used in the experiment.
"Extra" folder contains the dva2pix function, which is used in the Infos\_FBE file to convert all degrees
of visual angle (dva) values to pixels.


\-------------------------------------------------

Additional experiment codes(PSA\_FBE\_control\_exp):

\-------------------------------------------------
"Infos\_FBE\_control" creates all variables needed to run the experiment for each subject and session.
"On\_Screen\_control" function runs the trials on screen.
"Runner\_control" loads the created dataset and calls the On\_Screen function.
The dva2pix, gabor and mask files used here are the same as those used in the main experiment.

========================================================================================================

Perceptual main analysis(Figure 2 in the paper):

\-----------------------------------------------
Compute and plot visual sensitivity (d') results using "script\_dprime\_analysis".
d' was computed using the m-alternative detection choice model developed by:

*Sridharan, D., Steinmetz, N. A., Moore, T., \& Knudsen, E. I. (2014).*
*Distinguishing bias from sensitivity effects in multialternative detection tasks.*
*Journal of Vision, 14(9), 16–16.*

*We have added the m-ADC folder to this git repository, with all the scripts needed to compute d'.*
*To plot d' results, you'll need the bagplot function. We implemented a custom version of the original code 
(https://github.com/mwgeurts/libra/tree/master), which can be found in the "libra-master" folder.*

\----------------------------------------------------

Oculomotor main analysis(Figure 4A-C in the paper):

\----------------------------------------------------
Compute and plot saccade latency results using "script\_saccade\_latency\_plots"
To plot saccade latency results, you'll also need the bagplot function mentioned above.

========================================================================================================
\-----------------

Preprocessed data

\-----------------
To run the main perceptual and oculomotor analysis above, you'll need to download participants' preprocessed data available at https://osf.io/rj8z7. 

Each participant's preprocessed file contains two variables: 
"Data\_Table" contains all variables needed to run the analyses above. To check each variable's description in matlab, enter the following command in the command window "Data\_Table.Properties.VariableDescriptions".
"data" contains the raw eye-position data.











