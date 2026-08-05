function   [gabortex, propertiesMat] = stim_gabor(win,gabor)

%--------------------
% Gabor information
%--------------------

% Sigma of Gaussian
sigma = gabor.DimPix / 6;%1000%  1000 p mostrar sem gaussiana e contar cycles

% Build a procedural gabor texture (Note: to get a "standard" Gabor patch
% we set a grey background offset, disable normalisation, and set a
% pre-contrast multiplier of 0.5).
backgroundOffset = [0.5 0.5 0.5 0.0];
disableNorm = 1;
preContrastMultiplier = 0.5;
gabortex = CreateProceduralGabor(win, gabor.DimPix, gabor.DimPix, [],...
    backgroundOffset, disableNorm, preContrastMultiplier);


% Randomise the phase of the Gabors and make a properties matrix.
propertiesMat = [gabor.phase, gabor.freq, sigma, gabor.contrast, gabor.aspectRatio, 0, 0, 0];


end

