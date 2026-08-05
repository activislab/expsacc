
git_path = '/home/kaneda/Documents/GitHub/expsacc/PSA_FBE';
addpath(genpath(git_path));

pc_path = '/home/kaneda/Documents/Projects/PSA_FBE';
addpath(genpath(pc_path));

% Ask subject number
answer = inputdlg({'Número sujeito','Sessão'}, '', [1 25]);
sub.id = answer{1}; sub.id_num = str2double(answer{1});
sub.ses = answer{2}; sub.ses_num = str2double(answer{2}); 

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

info.ntrials = 60;

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

%% Gabor mask infos

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



target_side = repelem([1 2], 30)';
catch_trl = repmat([repelem(0,24) repelem(1,6)],1,2)';

%               targ orientation    target side      catch trials
%                1 = vertical        1 = left         1 = catch
%                                    2 = right        0 = no catch
%mat.matrix =    [repelem(1,60)'     target_side      catch_trl];

mat.matrix =    [repmat([1 2],1, 30)'     target_side      catch_trl];



    % randomize trials order within a given session. the loop below asures
    % that the first trial of each session is both sacade and feature
    % congruent.

    b = false;
    while b == false
        mat_rows = randperm(size(mat.matrix,1));

        mat.matrix =  mat.matrix(mat_rows,:);

        if mat.matrix(1,3) == 0 
            b = true;
        end
    end


    %%
    % target orientation for each trial in a given session.
    % trl.targ_ori(mat.matrix(:,1)' == 1,1) = 0;      % vertical orientation

    trl.targ_ori(mat.matrix(:,1)' == 1,1) = 315;      % CW orientation
    trl.targ_ori(mat.matrix(:,1)' == 2,1) = 45;      % CCW orientation
    % defines trial onset and offset. the onsets are randomized to occur
    % between 500 (60 frames) - 900 (109 frames) ms after fixation onset to avoid temporal
    % expectation.
    trl.cue_on = randi([60 109],1,60)';
    trl.cue_off = trl.cue_on + 9; % cue offset after 75 ms

    trl.targ_on = trl.cue_on + 18; % presents the target 150 ms after cue onset (SOA)
    trl.targ_off = trl.targ_on + 5; % it will stay on the screen for 50ms

    % White Noise timing based on target offset
    trl.wnoise_on  = trl.targ_off + 2;   % 16 ms ms SOA wnoise-target
    trl.wnoise_off = trl.wnoise_on + 12; % 100 ms duration


    %%
% 1Up/1Down PARAMETERS
[info] = UD_info(info,sub);

    %% Create data directories

    if ~exist(sprintf('%s/Data/S%d/Staircase/', pc_path, sub.id_num), 'dir')
        mkdir(sprintf('%s/Data/S%d/Staircase/', pc_path, sub.id_num))
    end

    %%
    %%% Save files

    % Save trials information
    sub.trlinfo_fname = sprintf('ses_%d_staircase_sub_%d_%s',sub.ses_num, sub.id_num, datestr(now,'yymmdd-HHMM')); %#ok<*TNOW1,*DATST>
    save(fullfile(sprintf('%s/Data/S%d/Staircase/%s', pc_path, sub.id_num), [sub.trlinfo_fname, '.mat']), 'info', 'trl', 'sub','gabor','mask','mat', '-v7.3');

    fprintf('\nFeito!\n')

