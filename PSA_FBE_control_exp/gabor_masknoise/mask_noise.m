function texMask = mask_noise(win,mask, info)

% Appertures for noise
apertureNoise = GenerateGaussian(round(mask.rad*2/mask.noisePixSize), round(mask.rad*2/mask.noisePixSize), mask.sigma/mask.noisePixSize, mask.sigma/mask.noisePixSize, 0, 0, 0);
apertureNoise = apertureNoise.*255;

% Noise mask (one static noise patch for all locations)
noiseImg = round((rand(round(mask.rad*2/mask.noisePixSize), round(mask.rad*2/mask.noisePixSize)))*info.white_idx);
mask3D(:,:,1) = noiseImg;
mask3D(:,:,2) = noiseImg;
mask3D(:,:,3) = noiseImg;
mask3D(:,:,4) = apertureNoise;
texMask = Screen('MakeTexture',win,mask3D);

end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
function gaussian = GenerateGaussian(m, n, sigma1,sigma2, theta,xoff,yoff)
% generates a 2D gaussian with a given patch size, sd, orientation and offset
% gaussian = GenerateGaussian(256,256, 32,32, pi/2,0,0); ishow(gaussian)
% J Greenwood 2009

m = round(m);
n = round(n);

[X,Y]=meshgrid(-m/2:m/2-1,-n/2:n/2-1);
X  = X-xoff;
Y  = Y-yoff;

% speedy variables
c1=cos(pi-theta);
s1=sin(pi-theta);
sig1_squared=2*sigma1*sigma1;
sig2_squared=2*sigma2*sigma2;

% co-ordinate matrices
Xt=zeros(m,n);
Yt=zeros(m,n);

% rotate co-ordinates
Xt = X.*c1 + Y.*s1;
Yt = Y.*c1 - X.*s1;

gaussian = exp(-(Xt.*Xt)/sig1_squared-(Yt.*Yt)/sig2_squared);
end
% -------------------------------------------------------------------------
