# mADC-model

## About
The mADC model is a multi-dimensional extension of signal detection theory. It can be used to quantify the effects of perceptual sensitivity and choice bias in detection / change detection tasks with any number of alternatives.

![mADC Schematic](https://github.com/CogLab-IISc/mADC-Model/blob/master/mADC_schematic.PNG)

## Fitting the model

### Preparing data:

1. The model can be fit to behavioral data from detection / change detection tasks with any number of alternatives. 
2. The stimulus-response contingencies must be organized into a contingency table (ctable), which is a (M+1)*(M+1)*K array, where M is the number of alternatives + 1 NoGo/Catch trial, and K is the number of stimulus strengths tested (i.e. change angles, contrasts etc.)
3. Data are expected to be arranged in increasing order of stimulus strength
4. The last row of the table for each stimulus strength must be identical and contain the false alarm counts across all locations.


Scripts for two versions of the mADC model are provided:

### 1. mADC_model_fit: 
Fits sensitivities (d') for each location and stimulus strength, and criterions (c) at each location. For each location, it determines k sensitivities (d') and 1 criterion (c).

To run the model, pass ctable and limits for d' (optional) as arguments. The code fits the mADC model by maximum likelihood estimation, and returns the estimated parameter values (theta_est), Log Likelihood Function (LLF) value, and the fit contingency table (ctable_fit). 

theta_est will be a 1D array of length M*(K+1), where the first M*K values correspond to d' at each location and stimulus strength, followed by M criterion values.

Example: For a 2 alternative detection task with 2 stimulus strenghts (i.e. M = 2, K = 2) : 
* ctable will be a 3x3x2 array 
* theta_est(1:2) : d' at location 1 and 2 for stimulus strength 1
* theta_est(3:4) : d' at location 1 and 2 for stimulus strength 2
* theta_est(5:6) : c at location 1 and 2

### 2. mADC_model_fit_psyc: 
Instead of estimating d' at each stimulus strengths, it fits the psychophysical function, which describes d' as a function of stimulus strengths, at one shot. For each location, it estimates 3 d'-related parameters and 1 criterion. 

The three-parameter hyperbolic ratio (Naka-Rushton) function is taken as the psychophysical function:  
d'(s) = d'<sub>max</sub> (s<sup>n</sup>/s<sup>n</sup>+s50<sup>n</sup>)

where: 
 * d'<sub>max</sub> : The asymptotic d' value 
 * s50 : contrast at 50% of asymptotic value
 * n : slope of the psychophysical function
  

Prepare ctable as specified above. Additionally, the stimulus strength values must be stored as a 1D array of stimulus strength of size 1xk (cvals); must be normalized from 0-1, where 1 is the expected stimulus strength for d'<sub>max</sub>

To run the model, pass ctable, cvals, and limits for d' (optional) as arguments. The code fits the mADC model by maximum likelihood estimation, and returns the estimated parameter values (theta_est), Log Likelihood Function (LLF) value, and the fit contingency table (ctable_fit). 

theta_est will be a 1D array of length M*(4), where the first M values correspond to 'd'<sub>max</sub>' at each location, followed by M values of 'n' at each location and M values of 's50' at each location, followed by M values of criterion at each location.

Example: For a 2 alternative detection task with 2 stimulus strenghts (i.e. M = 2, K = 2) : 
* ctable will be a 3x3x2 array
* cvals will be a 1x2 array
* theta_est(1:2) : d'<sub>max</sub> at location 1 and 2
* theta_est(3:4) : n at location 1 and 2
* theta_est(5:6) : s50 at location 1 and 2
* theta_est(7:8) : c at location 1 and 2


## Dependencies

[MATLAB](https://in.mathworks.com/products/matlab.html?requestedDomain=)

## References

[1] [Sridharan D., Steinmetz N., Moore T., and Knudsen E., (2014, August) Distinguishing bias from sensitivity effects in multialternative detection tasks. Journal of Vision](https://jov.arvojournals.org/article.aspx?articleid=2194077)

Code : http://purl.stanford.edu/mc140xy0456

[2] [Sridharan D., Steinmetz N., Moore T., and Knudsen E. (2017, January) Does the superior colliculus control perceptual sensitivity or choice bias during attention? Evidence from a multialternative decision framework. Journal of Neuroscience](https://www.jneurosci.org/content/37/3/480)

[3] [Sagar V., Sengupta R., and Sridharan D. (2019, September) Dissociable sensitivity and bias mechanisms mediate behavioral effects of exogenous attention. Scientific Reports](https://www.nature.com/articles/s41598-019-42759-w) 

Data and code available at: https://datadryad.org/stash/dataset/doi:10.5061/dryad.s1725t6

[4] [Banarjee S., Grover S., Ganesh S., and Sridharan D. (2019, September) Sensory and decisional components of endogenous attention are dissociable. Journal of Neurophysiology](https://journals.physiology.org/doi/full/10.1152/jn.00257.2019)

Data and code available at: https://figshare.com/s/b4b1f34ae4087420bd85

## Contact : coglabcns.iisc@gmail.com



