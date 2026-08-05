path = '/home/kaneda/Documents/GitHub/expsacc/PSA_FBE/Images/img_stair_treino';
addpath(genpath(path));

Screen('Preference', 'SyncTestSettings', .01, 50, .25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

screens = Screen('Screens');        % Indexes of available screens
scr_num = screens(1);          % Screen number

% Colors indexes
white_idx = WhiteIndex(scr_num);
black_idx = BlackIndex(scr_num);
gray_idx = white_idx/2;

[win, rect] = PsychImaging('OpenWindow', scr_num, gray_idx, [], 32, 2, [], []);

scr_xsize = rect(3);
scr_ysize = rect(4);
Priority(MaxPriority(win));

%--------------------------------------------------------------------------
fp_calibration = imread(sprintf('fp_calibration.png'));
tex_fp_calibration = Screen('MakeTexture', win, fp_calibration);

FP = imread(sprintf('FP.png'));
tex_FP = Screen('MakeTexture', win, FP);

cue = imread(sprintf('cue.png'));
tex_cue = Screen('MakeTexture', win, cue);

Ltarg_CW = imread(sprintf('Ltarg_CW.png'));
tex_Ltarg_CW = Screen('MakeTexture', win, Ltarg_CW);

Ltarg_CCW = imread(sprintf('Ltarg_CCW.png'));
tex_Ltarg_CCW = Screen('MakeTexture', win, Ltarg_CCW);

Rtarg_CW = imread(sprintf('Rtarg_CW.png'));
tex_Rtarg_CW = Screen('MakeTexture', win, Rtarg_CW);

Rtarg_CCW = imread(sprintf('Rtarg_CCW.png'));
tex_Rtarg_CCW = Screen('MakeTexture', win, Rtarg_CCW);

wnoise = imread(sprintf('wnoise.png'));
tex_wnoise = Screen('MakeTexture', win, wnoise);

cue_resp = imread(sprintf('cue_resp.png'));
tex_cue_resp = Screen('MakeTexture', win, cue_resp);


clear ex_img;


%--------------------------------------------------------------------------


trl_exp = 1;
while trl_exp <= 6


    % trial onset
    if trl_exp == 1
        Screen('DrawTexture', win, tex_FP, [], [], 0);
    end

    % Cue onset
    if trl_exp == 2
        Screen('DrawTexture', win, tex_cue, [], [], 0);
    end

    % Target onset
    if trl_exp == 3
        Screen('DrawTexture', win, tex_Rtarg_CW, [], [], 0);
    end

    % Gaussian envelope onset
    if trl_exp == 4
        Screen('DrawTexture', win, tex_wnoise, [], [], 0);
    end

    % only polders and fp
    if trl_exp == 5
        Screen('DrawTexture', win, tex_FP, [], [], 0);
    end

    % response cue
    if trl_exp == 6
        Screen('DrawTexture', win, tex_cue_resp, [], [], 0);
    end



    Screen('Flip', win);
    WaitSecs(.1);

    clear buttons
    [~,~,buttons]=GetMouse;
    while buttons([1 3]) == 0
        [~,~,buttons]=GetMouse;
    end

    if buttons(3) == 1
        if trl_exp > 1
            trl_exp = trl_exp - 1;
        end
    else
        trl_exp = trl_exp + 1;
    end

    clear buttons

end

Screen('Close',win);
clear; clc;