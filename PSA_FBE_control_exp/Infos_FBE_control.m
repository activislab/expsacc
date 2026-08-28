git_path = 'Insert_git_folder_location_here';
addpath(genpath(git_path));

pc_path = 'Insert_future_files_location_here';
addpath(genpath(pc_path));

% Ask for the participant number
answer = inputdlg({'Participant number'}, '', [1 25]);
sub.id = answer{1}; sub.id_num = str2double(answer{1});

%% Screen setup
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Seed the random number generator.
% This method ensures a different random sequence each time the script runs
% while remaining compatible with older MATLAB versions.
rng('shuffle')

% Get the available screen numbers.
screens = Screen('Screens');

% Use the external screen for stimulus presentation.
info.scr_num = min(screens);

% Define black, white, and gray color indices.
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

% Open a fullscreen Psychtoolbox window.
[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.gray_idx, [], 32, 2, [], []);

% Get the screen inter-frame interval.
info.scr_ifi = Screen('GetFlipInterval', win);

sca;
clc;

% Total number of trials in one session (including training trials).
info.ntrials = 840;

%% Get the screen dimensions

% Physical screen size (cm).
[scr_xsize_mm, scr_ysize_mm] = Screen('DisplaySize', info.scr_num);
info.scr_xsize_cm = scr_xsize_mm/10;
info.scr_ysize_cm = scr_ysize_mm/10;

% Screen resolution (pixels).
info.scr_xsize = info.scr_rect(3);
info.scr_ysize = info.scr_rect(4);

% Screen center coordinates (pixels).
[info.scr_xcenter, info.scr_ycenter] = RectCenter(info.scr_rect);

% Monitor refresh rate (Hz).
info.scr_rrate = round(1/info.scr_ifi);

% Viewing distance (cm).
info.scr_dist_cm = 57;

% Parameters for the fixation period before each trial.
info.fix_dur_sec = 0.5;         % Required fixation duration (s).
info.roi_fix_dva = 2;           % Radius of the fixation ROI (2 dva; 4 dva diameter).
info.roi_fix_pix = dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,info.roi_fix_dva);

%% Gabor parameters

gabor.rad = 1.1; % Radius (dva).
gabor.radPix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, gabor.rad));

% Possible Gabor orientations.
gabor.orientation = [0 90];

% Gabor properties.
gabor.contrast = 1;
gabor.aspectRatio = 1.0;
gabor.phase = 0;

% Spatial frequency (cycles per pixel).
% One cycle = Gray → Black → Gray → White → Gray.
gabor.numCycles = 5.5;
gabor.DimPix = info.scr_rect(4)/2;
gabor.freq = gabor.numCycles/gabor.DimPix;

%% White noise mask parameters

mask.rad       = gabor.radPix;      % Mask radius.
mask.pixpc     = 7.27;              % Pixels per cycle.
mask.sigma_period = 0.9;
mask.sigma        = mask.pixpc * mask.sigma_period;
mask.noisePixSize = mask.rad / 5;

%% Gabor positions

info.EccDVA = 8; % Target eccentricity (dva).
info.Ecc = round(dva2pix(info.scr_dist_cm,info.scr_xsize_cm,info.scr_xsize,info.EccDVA));

info.stimDim = gabor.radPix * 2;

rectt = [0 0 info.stimDim info.stimDim];

% Horizontal positions of the left and right Gabors.
coordL_gabor = info.scr_xcenter - info.Ecc;
coordR_gabor = info.scr_xcenter + info.Ecc;

% Screen coordinates for the left and right Gabor stimuli.
info.coordL = CenterRectOnPoint(rectt,coordL_gabor,info.scr_ycenter)';   % Left Gabor position
info.coordR = CenterRectOnPoint(rectt,coordR_gabor,info.scr_ycenter)';   % Right Gabor position

%% Fixation dot parameters

info.dot_size_dva = 0.3;        % Fixation dot diameter (dva).
info.dot_size_pix = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.dot_size_dva));

%% Saccade cue parameters

info.cue_width_dva = 0.15;   % Cue width (dva).
info.cue_length_dva = 0.7;   % Cue length (dva).

% Saccade cue dimensions converted to pixels.
info.cue_width_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_width_dva));
info.cue_length_px = round(dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize, info.cue_length_dva));

%% Placeholder parameters

info.pholder_size_dva = 0.3;               % Placeholder size (dva).
info.dist_pholder_y_perto_dva = 1.415;     % Vertical eccentricity relative to screen center.
info.dist_pholder_x_perto_dva = 8-1.415;   % Horizontal eccentricity of the near placeholder.
info.dist_pholder_x_longe_dva = 8+1.415;   % Horizontal eccentricity of the far placeholder.

% Convert placeholder dimensions and positions to pixels.
info.pholder_size_px = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.pholder_size_dva);
info.dist_pholder_y_perto_px = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_y_perto_dva);
info.dist_pholder_x_perto_px = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_x_perto_dva);
info.dist_pholder_x_longe_px = dva2pix(info.scr_dist_cm, info.scr_xsize_cm, info.scr_xsize,info.dist_pholder_x_longe_dva);

% Define the stimulus presentation positions.
y1 = info.scr_ycenter - info.dist_pholder_y_perto_px;
y2 = info.scr_ycenter + info.dist_pholder_y_perto_px;

x3  = info.scr_xcenter - info.dist_pholder_x_perto_px; % Near left placeholder
x3a = info.scr_xcenter - info.dist_pholder_x_longe_px; % Far left placeholder
x4  = info.scr_xcenter + info.dist_pholder_x_perto_px; % Near right placeholder
x4a = info.scr_xcenter + info.dist_pholder_x_longe_px; % Far right placeholder

% Placeholder coordinates for the left and right visual fields.
info.pholdercoordL = [x3,  x3a, x3,  x3a; y2, y2, y1, y1];
info.pholdercoordR = [x4,  x4a, x4,  x4a; y2, y2, y1, y1];

%% Condition codes

% 1 = Towards + High Prob
% 2 = Towards + Low Prob

% Matrix columns:
% Column 1: Conditions 1-2
% Column 2: Feature
%           1 = Clockwise
%           2 = Counterclockwise
% Column 3: Target side
%           1 = Left
%           2 = Right
% Column 4: Training
%           1 = training
%           0 = data collection
% Column 5: Target Orientation
%           1 = Clockwise
%           2 = CounterClockwise

condition1 = [repelem(1,72) repelem(2,18) repelem(1,72)  repelem(2,18)]';

feature_type1 = repelem(1, 180)';

target_side1 = repelem([1 2], 90)';

% Create the base trial matrix.
matrix1 = repmat([condition1 feature_type1  target_side1],2,1);

% Duplicate to create two feature sets.
matrix1 = [matrix1; matrix1];

% Assign feature type 2 to the second half.
matrix1(361:end,2) = 2;


% Counterbalance the feature condition across participants.
if rem(sub.id_num,2) == 1
    trl.feature_ses = [1 2];
else
    trl.feature_ses = [2 1];
end

% Create the trial matrix for each session, including
% feature condition, timing, and target orientation.

for session = 1

    % Assign the frequent feature for each half of the session.
    matrix1(1:360,2)   = trl.feature_ses(session,1);
    matrix1(361:720,2) = trl.feature_ses(session,2);


    % Randomize trials separately for the two halves of the experiment.
    matrix(1:360,:)   = Shuffle(matrix1(1:360,:),2);
    matrix(361:720,:)   = Shuffle(matrix1(361:720,:),2);

    % Randomize the order of 30-trial blocks within each half.
    blocks = [(1:30:720)' (30:30:720)'];

    shuffled_blocks1 = Shuffle(blocks(1:12,:),2);
    shuffled_blocks2 = Shuffle(blocks(13:24,:),2);
    shuffled_blocks = [shuffled_blocks1;shuffled_blocks2];

    for m = 1:24

        matrix2(blocks(m,1):blocks(m,2),:) = matrix(shuffled_blocks(m,1):shuffled_blocks(m,2),:);

    end

    % Create shuffled versions for the complementary training blocks.
    mat_trng1 = Shuffle(matrix2(331:360,:),2);
    mat_trng2 = Shuffle(matrix2(691:720,:),2);
    % Create shuffled versions for the complementary training blocks.
    mat_trng3 = Shuffle(matrix2(331:360,:),2);
    mat_trng4 = Shuffle(matrix2(691:720,:),2);

    % Shuffle the two training sets.
    mat_trng11 = Shuffle([mat_trng1; mat_trng3],2);
    mat_trng22 = Shuffle([mat_trng2; mat_trng4],2);

    % Assemble the complete session matrix:
    % Training -> Experiment -> Training -> Experiment.
    info.matrix = [mat_trng11;         % Training
        matrix2(1:360,:);   % Experimental trials
        mat_trng22;         % Training
        matrix2(361:end,:)];% Experimental trials

    % This fourth column represents training (ones) and no training trials (zeros)
    info.matrix(:,4) = [repelem(1,60) repelem(0,360) repelem(1,60) repelem(0,360)]';

    %% Target orientation assignment

    % Target orientations when the high-probability feature is clockwise (315°).
    trl.targ_ori((info.matrix(:,1) == 1 & info.matrix(:,2) == 1),1) = 315; % Clockwise
    trl.targ_ori((info.matrix(:,1) == 2 & info.matrix(:,2) == 1),1) = 45;  % Counterclockwise

    % Target orientations when the high-probability feature is counterclockwise (45°).
    trl.targ_ori((info.matrix(:,1) == 1 & info.matrix(:,2) == 2),1) = 45;  % Counterclockwise
    trl.targ_ori((info.matrix(:,1) == 2 & info.matrix(:,2) == 2),1) = 315; % Clockwise

    % Mark the first trial of each block.
    trl.onset_blocks = repmat([1 repelem(0,29)],1,28)';

    % Mark the last trial of each block.
    trl.offset_blocks = repmat([repelem(0,29) 1],1,28)';
    % Mark the beginning of the resting phase.
    trl.offset_blocks(60:60:840,1) = 2;

    % Define cue onset.
    % Cue onset is randomized between 500 and 900 ms after fixation onset
    % to reduce temporal expectation.
    trl.cue_on = randi([60 109],1,840)';

     % Cue duration (75 ms).
    trl.cue_off = trl.cue_on + 9;

    % Target onset (150 ms SOA relative to cue onset).
    trl.targ_on = trl.cue_on + 18; 

    % Target duration (~41 ms).
    trl.targ_off = trl.targ_on + 5;

    % White noise mask timing.
    trl.wnoise_on  = trl.targ_off + 2;   % 16 ms SOA after target offset
    trl.wnoise_off = trl.wnoise_on + 12; % 100 ms duration

    % Counter for repeated blocks.
    trl.repeated_blk = zeros(1,2);

    info.matrix(trl.targ_ori(:,1)==45,5) = 2;
    info.matrix(trl.targ_ori(:,1)==315,5) = 1;

       %% Create participant data directories

    if ~exist(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Task/', pc_path, sub.id_num))
    end
    if ~exist(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Eye/', pc_path, sub.id_num))
    end


    %% Save session files

    % Save trial information and experiment parameters.
    sub.trlinfo_fname = sprintf('ses_%d_trlinfo_sub_%d_%s',session, sub.id_num, datestr(now,'yymmdd-HHMM')); %#ok<*TNOW1,*DATST>
    save(fullfile(sprintf('%s/Data/S%d/%s', pc_path, sub.id_num), [sub.trlinfo_fname, '.mat']), 'info', 'trl', 'sub','gabor','mask', '-v7.3');

    fprintf('Session_%d...',session)
    fprintf('\nDone!\n')

end

