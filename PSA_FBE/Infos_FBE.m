
git_path = '/home/kaneda/Documents/GitHub/expsacc/PSA_FBE';
addpath(genpath(git_path));

pc_path = '/home/kaneda/Documents/Projects/PSA_FBE';
addpath(genpath(pc_path));

% Ask subject number
answer = inputdlg({'Numero voluntario'}, '', [1 25]);
sub.id = answer{1}; sub.id_num = str2double(answer{1});


%% INFORMAÇÕES SOBRE O TECLADO
KbName('UnifyKeyNames');
info.escapeKey = KbName('ESCAPE');
info.s         = KbName('S');
info.n         = KbName('N');
info.space     = KbName('space');
%% Screen setup
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Seed the random number generator. Here we use an older way to be
% compatible with older systems.
rng('shuffle')

screens = Screen('Screens');% Get the screen numbers.
info.scr_num = min(screens);% draw to the externalscreen.

% Define black and white (white== 1 and black, 0).
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

% Open an screen window
[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.gray_idx, [], 32, 2, [], []); % RODA EM TELA TODA

% Inter-flip interval
info.scr_ifi = Screen('GetFlipInterval', win);

sca; clc;

info.ntrials = 840;

%% Get the size of the screen window in pixels

[scr_xsize_mm, scr_ysize_mm] = Screen('DisplaySize', info.scr_num);
info.scr_xsize_cm = scr_xsize_mm/10;
info.scr_ysize_cm = scr_ysize_mm/10;
% Screen size in pixels
%or, by:[scrX,scrY] = Screen('WindowSize',info.scr_num); % in  pixels
info.scr_xsize = info.scr_rect(3);
info.scr_ysize = info.scr_rect(4);

% Centre coordinate of the window
[info.scr_xcenter, info.scr_ycenter] = RectCenter(info.scr_rect); % in pixels
info.scr_rrate = round(1/info.scr_ifi);     % Refresh rate
info.scr_dist_cm = 57;          % Viewing distance from screen (cm)

% parameters for fixation period before every trial onset.
info.fix_dur_sec = 0.5;         % Duration of fixation at ROI to start trial in secs
info.roi_fix_dva = 2;           % size of fixation window ROI
info.roi_fix_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,info.roi_fix_dva);
%% Gabor INFOS

gabor.rad = 1.1; %0.8;%1.4; %(radius in dva)
gabor.radPix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, gabor.rad));

gabor.orientation = [0 90]; % all possibilities: 1:cw; 2:ccw

gabor.contrast = 1; %0.8;
gabor.aspectRatio = 1.0;
gabor.phase = 0;

% Spatial Frequency (Cycles Per Pixel)
% One Cycle = Grey-Black-Grey-White-Grey i.e. One Black and One White Lobe
gabor.numCycles = 5.5;%6;%3 % para computar 'cycles/pixels'
gabor.DimPix = info.scr_rect(4)/2;
gabor.freq = gabor.numCycles/gabor.DimPix;%freq_pix;

%% infos Mask (white noise mask) do script da nina hanning

mask.rad       = gabor.radPix;%30;               % item radius
mask.pixpc     = 7.27;%10;               % gabor frequency (in pixels per cycle; e.g. 10 for 1 cicle per 10 pixel)
mask.sigma_period      = 0.9;
mask.sigma             = mask.pixpc*mask.sigma_period;
mask.noisePixSize      = mask.rad/5; %%%% GOOD PROXY? %%% was 5 before

%% Posicoes dos Gabors
info.EccDVA = 8; % target eccentricity
info.Ecc = round(dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,info.EccDVA));

info.stimDim = gabor.radPix*2;

rectt = [0 0 info.stimDim info.stimDim];
coordL_gabor = info.scr_xcenter - info.Ecc;
coordR_gabor = info.scr_xcenter + info.Ecc;

info.coordL = CenterRectOnPoint(rectt,coordL_gabor,info.scr_ycenter)';   % posição gabor esquerda
info.coordR = CenterRectOnPoint(rectt,coordR_gabor,info.scr_ycenter)';   % posição gabor direita


%% Infos Fixation Dot
info.dot_size_dva = 0.3;        % fixation Dot diameter
info.dot_size_pix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.dot_size_dva));

%% Infos Saccade_Cue
info.cue_width_dva = 0.15; % saccade cue width in dva
info.cue_length_dva = 0.7; % saccade cue length in dva

info.cue_width_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_width_dva));% saccade cue width converted to pixels
info.cue_length_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_length_dva)); % saccade cue length converted to pixels

%% PLACEHOLDERS INFOS

info.pholder_size_dva = 0.3;       % tamanho placeholders
info.dist_pholder_y_perto_dva     = 1.415; %2;       % excent. dos pholders em relação ao centro do eixo y.
info.dist_pholder_x_perto_dva     = 8-1.415; %6;        % excent. placeholder mais perto em relação ao eixo x
info.dist_pholder_x_longe_dva     = 8+1.415; %10;       % excent. placeholder mais distante em relação ao eixo x

info.pholder_size_px     = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.pholder_size_dva);
info.dist_pholder_y_perto_px     = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_y_perto_dva);
info.dist_pholder_x_perto_px     = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_x_perto_dva);
info.dist_pholder_x_longe_px    = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_x_longe_dva);

% define posição de apresentação dos estímulos
y1 = info.scr_ycenter - info.dist_pholder_y_perto_px;
y2 = info.scr_ycenter + info.dist_pholder_y_perto_px;

x3  = info.scr_xcenter - info.dist_pholder_x_perto_px; % pholder perto esquerda
x3a = info.scr_xcenter - info.dist_pholder_x_longe_px; % pholder distante esquerda
x4  = info.scr_xcenter + info.dist_pholder_x_perto_px; % pholder perto direita
x4a = info.scr_xcenter + info.dist_pholder_x_longe_px; % pholder distante direita

info.pholdercoordL = [x3,  x3a, x3,  x3a; y2, y2, y1, y1];  % coordenadas pista lado esquerdo
info.pholdercoordR = [x4,  x4a, x4,  x4a; y2, y2, y1, y1];  % coord pista lado direito

%%
% There are four conditions: saccade congruent (SC) Neutral-Nonsaccade (NE) and feature
% congruent (FC) and incongruent (FI).

% 1 = VAL + FC
% 2 = VAL + FI
% 3 = INVAL + FC
% 4 = INVAL + FI



%        conditions 1:4    feature      targ side       catch trials
%           see above      1 = CW       1 = left        0 = no catch
%                          2 = CCW      2 = right        1 = catch

condition1 = [repelem(1,72) repelem(2,18) repelem(1,72)  repelem(2,18)]';
condition2 = [repelem(3,72) repelem(4,18) repelem(3,72)  repelem(4,18)]';

feature_type1 = repelem(1, 180)';

target_side1 = repelem([1 2], 90)';

catch_trl1 = repmat([repelem(0,60) repelem(1,12) repelem(0,15)  repelem(1,3)]',2,1);

matrix1 = repmat([condition1 feature_type1  target_side1  catch_trl1],2,1); 

matrix1(181:end,1) = condition2;

matrix1 = [matrix1; matrix1];

matrix1(361:end,2) = 2; 



if rem(sub.id_num,2) == 1
    trl.feature_ses = [1 2;2 1];
else
    trl.feature_ses = [2 1; 1 2];
end

% create matrix of trials for each session, as well as timings for cue and
% target appearance and target orientation.

for session = 1:2

    matrix1(1:360,2)   = trl.feature_ses(session,1);
    matrix1(361:720,2) = trl.feature_ses(session,2);


    % Randomize trials separetly for saccade and neutral conditions.
    matrix(1:360,:)   = Shuffle(matrix1(1:360,:),2);   % saccade 
    %matrix(181:360,:) = Shuffle(matrix1(181:360,:),2); % neutral
    matrix(361:720,:)   = Shuffle(matrix1(361:720,:),2);   % saccade 
    %matrix(541:720,:) = Shuffle(matrix1(541:720,:),2); % neutral
  
    % Randomize blocks of trials in a given session. each block contains 30
    % trials. If the number condition is 1 or 2, is a saccade block,
    % whereas a number 3 or 4 is a neutral block (no saccade). 
    blocks = [(1:30:720)' (30:30:720)'];
    
    shuffled_blocks1 = Shuffle(blocks(1:12,:),2);
    shuffled_blocks2 = Shuffle(blocks(13:24,:),2);
    shuffled_blocks = [shuffled_blocks1;shuffled_blocks2];

    for m = 1:24

        matrix2(blocks(m,1):blocks(m,2),:) = matrix(shuffled_blocks(m,1):shuffled_blocks(m,2),:);
    
    end
 
   mat_trng1 = matrix2(331:360,:);
   mat_trng2 = matrix2(691:720,:);
   mat_trng3 = Shuffle(matrix2(331:360,:),2);
   mat_trng4 = Shuffle(matrix2(691:720,:),2);


   mat_trng1(mat_trng1(:,1) == 3 ,1) = 1;
   mat_trng1(mat_trng1(:,1) == 4 ,1) = 2;

   mat_trng2(mat_trng2(:,1) == 3 ,1) = 1;
   mat_trng2(mat_trng2(:,1) == 4 ,1) = 2;

   mat_trng3(mat_trng3(:,1) == 1 ,1) = 3;
   mat_trng3(mat_trng3(:,1) == 2 ,1) = 4;

   mat_trng4(mat_trng4(:,1) == 1 ,1) = 3;
   mat_trng4(mat_trng4(:,1) == 2 ,1) = 4;


    mat_trng11 = Shuffle([mat_trng1; mat_trng3],2);
    mat_trng22 = Shuffle([mat_trng2; mat_trng4],2);

   info.matrix = [mat_trng11;         % Training
                 matrix2(1:360,:);    % Experiment
                 mat_trng22;          % Training
                 matrix2(361:end,:)]; % Experiment
   
   % This fifth column represents training (ones) and no training trials (zeros)
   info.matrix(:,5) = [repelem(1,60) repelem(0,360) repelem(1,60) repelem(0,360)]';

    %%
    % target orientation for each trial when the most probable orientation
    % is clockwise (315)
     trl.targ_ori((info.matrix(:,1) == 1 & info.matrix(:,2) == 1),1) = 315;      % clockwise orientation
     trl.targ_ori((info.matrix(:,1) == 2 & info.matrix(:,2) == 1),1) = 45;      % counterclockwise orientation
     trl.targ_ori((info.matrix(:,1) == 3 & info.matrix(:,2) == 1),1) = 315;      % clockwise orientation
     trl.targ_ori((info.matrix(:,1) == 4 & info.matrix(:,2) == 1),1) = 45;      % counterclockwise orientation
  
    % target orientation for each trial when the most probable orientation
    % is counterclockwise (45)
     trl.targ_ori((info.matrix(:,1) == 1 & info.matrix(:,2) == 2),1) = 45;    
     trl.targ_ori((info.matrix(:,1) == 2 & info.matrix(:,2) == 2),1) = 315;     
     trl.targ_ori((info.matrix(:,1) == 3 & info.matrix(:,2) == 2),1) = 45;      
     trl.targ_ori((info.matrix(:,1) == 4 & info.matrix(:,2) == 2),1) = 315;      


    % ones mark the beginning of a block of trials.
    trl.onset_blocks = repmat([1 repelem(0,29)],1,28)';

    % ones mark the end of a block of trials.
    trl.offset_blocks = repmat([repelem(0,29) 1],1,28)';
    % twos mark the resting block
    trl.offset_blocks(60:60:840,1) = 2;

    % defines trial onset and offset. the onsets are randomized to occur
    % between 500 (60 frames) - 900 (109 frames) ms after fixation onset to avoid temporal
    % expectation.
    trl.cue_on = randi([60 109],1,840)';
    trl.cue_off = trl.cue_on + 9; % cue offset after 75 ms

    trl.targ_on = trl.cue_on + 18; % presents the target 150ms after cue onset (SOA)
    trl.targ_off = trl.targ_on + 5; % it will stay on the screen for 40ms

    % White Noise timing based on target offset
    trl.wnoise_on  = trl.targ_off + 2;   % 16ms ms SOA wnoise-target
    trl.wnoise_off = trl.wnoise_on + 12; % 100 ms duration

    trl.repeated_blk = zeros(1,2);

    %% Create data directories

    if ~exist(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num))
    end
    if ~exist(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num))
    end


    %%
    %%% Save files

    % Save trials information
    sub.trlinfo_fname = sprintf('ses_%d_trlinfo_sub_%d_%s',session, sub.id_num, datestr(now,'yymmdd-HHMM')); %#ok<*TNOW1,*DATST>
    save(fullfile(sprintf('%s/Data/S%d/%s', pc_path, sub.id_num), [sub.trlinfo_fname, '.mat']), 'info', 'trl', 'sub','gabor','mask', '-v7.3');

    fprintf('Sessão_%d...',session)
    fprintf('\nFeito!\n')

end

