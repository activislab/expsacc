function [resp,UD] = Stair_On_Screen(info,trl,gabor,mask,sub,mat)
% First column = Hits;
% Second column = False Alarms
% Third column =  Correct rejections
% fourth column = Miss
resp = zeros(60,4);

ResponsePixx('Close');
ResponsePixx('Open');

%% Screen setup

FlushEvents;
PsychDefaultSetup(2);% default settings for setting up Psychtoolbox

Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Define black and white (white== 1 and black, 0).
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.gray_idx, [], 32, 2, [], []); % RODA EM TELA TODA

%%

% Eyetracking general setup
EyelinkInit(0);
Eyelink('OpenFile', 'FBEeye');       % Open temporary Eyelink file

% Select which events are saved in the EDF file - include everything just in case
Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
% Select which events are available online for gaze-contingent experiments - include everything just in case
Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
% Select which sample data is saved in EDF file or available online - include everything just in case
Eyelink('Command', 'file_sample_data = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');

if sub.eye == 'E'
    eye_used = 1;
    Eyelink('Command', 'active_eye = LEFT');
elseif sub.eye == 'D'
    eye_used = 2;
    Eyelink('Command', 'active_eye = RIGHT');
end

el = EyelinkInitDefaults(win);
% Set calibration/validation/drift-check(or drift-correct) size as well as background and target colors
% It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
% pupil size changes (which can cause a drift in the eye movement data)
el.calibrationtargetsize = 2;               % Outer target size as percentage of the screen
el.calibrationtargetwidth = 0.3;            % Inner target size as percentage of the screen
el.backgroundcolour = info.gray_idx;        % RGB grey
el.calibrationtargetcolour = [0 0 0];       % RGB black
% Set "Camera Setup" instructions text colour so it is different from background colour
el.msgfontcolour = [0 0 0];                 % RGB black

% Use an image file instead of the default calibration bull's eye targets
% (commenting out the following two lines will use default targets)
% el.calTargetType = 'image';
% el.calImageTargetFilename = [pwd '/' 'Images/fixTargetXXX.jpg'];

% Set calibration beeps (0 = sound off, 1 = sound on)
el.targetbeep = 0;                          % Sound a beep when a target is presented
el.feedbackbeep = 0;                        % Sound a beep after calibration or drift check/correction

EyelinkUpdateDefaults(el);

Eyelink('Command', 'screen_pixel_coords = %ld %ld %ld %ld', 0, 0, info.scr_xsize-1, info.scr_ysize-1);
Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, info.scr_xsize-1, info.scr_ysize-1);

% Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
Eyelink('Command', 'calibration_type = HV9');           % Horizontal-vertical 9-points
Eyelink('command', 'generate_default_targets = NO');    % NO = Custom calibration
% Modify calibration and validation target locations
Eyelink('command', 'calibration_samples = 10');
Eyelink('command', 'calibration_sequence = 0,1,2,3,4,5,6,7,8,9');
Eyelink('command', 'calibration_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
    960,540, 960,205, 960,875, 442,540, 1478,540, 442,205, 1478,205, 442,875, 1478,875);
Eyelink('command', 'validation_samples = 10');
Eyelink('command', 'validation_sequence = 0,1,2,3,4,5,6,7,8,9');
Eyelink('command', 'validation_targets = %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d %d,%d',...
    960,540, 960,205, 960,875, 442,540, 1478,540, 442,205, 1478,205, 442,875, 1478,875);

% Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
Eyelink('Command', 'button_function 5 "accept_target_fixation"');
Eyelink('Command', 'clear_screen 0');       % Clear Host PC display from any previus drawing

%%

topPriorityLevel = MaxPriority(win);
Priority(topPriorityLevel);
HideCursor;
ListenChar(-1);

% Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
EyelinkDoTrackerSetup(el);

% Create central square fixation window
fix_win_center = [-info.roi_fix_pix -info.roi_fix_pix info.roi_fix_pix info.roi_fix_pix];
fix_win_center = CenterRect(fix_win_center, info.scr_rect);

%%

[UD] = UD_setup(info);


try
    abort = false;

    for session = 1:info.ntrials

        if mat.matrix(session,3) == 0
            [gabor] = UD_alpha_update(gabor,UD);
        end

        [gabortex, propertiesMat] = stim_gabor(win,gabor);

        % Cria Mask (White Noise patch)
        texMaskR = mask_noise(win, mask, info);
        texMaskL = mask_noise(win, mask, info);

        FIX = 2;


        Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode before drawing Host PC graphics and before recording



        if session == 1

            txt_ = '-----------------------';
            txt1 = 'Pressione o botão            para iniciar!';
            txt2 = ' branco';

            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter -20,info.black_idx);
            DrawFormattedText(win, txt1, 'center', info.scr_ycenter, info.black_idx);
            DrawFormattedText(win, txt2, info.scr_xcenter - 8, info.scr_ycenter, [1 1 1]);
            DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 20,info.black_idx);

            Screen('Flip', win);

            ResponsePixx('StartNow', 1, [0 0 0 0 1], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)
                    if buttons(1,5) == 1         % White button
                        break;
                        % elseif buttons(1,4) == 1     % Blue button
                        %     abort = true;
                        %     break;
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            if abort == false
                EyelinkDoDriftCorrection(el, [info.scr_xcenter, info.scr_ycenter]);      % Run eyetracker drift correction
                WaitSecs(1);
            end


        end


        if abort == true
            break;
        end


        Eyelink('Command', 'clear_screen 0');       % Clear Host PC display from any previus drawing
        %Eyelink('ImageTransfer', '/home/kaneda/Documents/GitHub/PSA_FBA/Images/trl_on.bmp', 0, 0, 0, 0, 0, 0);
        Eyelink('StartRecording');
        % Eyelink('Command', 'record_status_message "TRIAL %d/%d"', session, size(info.ntrials,1));

        % DRAW FIXATION POINT in red FOR 500 MS BEFORE TRIAL ONSET.
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
        Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
        Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        time.fp_on(session) = Screen('Flip', win);

        % Wait until participant is fixating for info.fix_dur_sec
        while 1
            damn = Eyelink('CheckRecording');
            if(damn ~= 0)
                break;
            end
            if Eyelink('NewFloatSampleAvailable') > 0
                evt = Eyelink('NewestFloatSample');                     % Get the sample in the form of an event structure
                x_gaze = evt.gx(eye_used);                              % Get current gaze position from sample
                y_gaze = evt.gy(eye_used);
                if inFixWindow(x_gaze, y_gaze, fix_win_center)          % If gaze sample is within fixation window (see inFixWindow function below)
                    if (GetSecs - time.fp_on(session)) >= info.fix_dur_sec     % If gaze duration >= minimum fixation window time (fxateTime)
                        break;
                    end
                elseif ~inFixWindow(x_gaze, y_gaze, fix_win_center)     % If gaze sample is not within fixation window
                    [time.fp_on(session)] = GetSecs;                         % Reset fixation window timer
                end
            end
        end


        for trial = 1:trl.wnoise_off(session,1)+24 % TRIAL WILL END 300 MS AFTER TARG OFF (mask off)


            if Eyelink('NewFloatSampleAvailable') > 0
                evt = Eyelink('NewestFloatSample');                     % Get the sample in the form of an event structure
                x_gaze = evt.gx(eye_used);                              % Get current gaze position from sample
                y_gaze = evt.gy(eye_used);
            end
            

            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

            % CUE ONSET
            if trial >= trl.cue_on(session,1) && trial <= trl.cue_off(session,1)

                Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                    ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);

            end

            % DRAW FIXATION POINT AND PLACEHOLDERS
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);

            % SHOW TARGET if this trial isn't catch
            if mat.matrix(session,3) == 0
                if trial >= trl.targ_on(session,1) && trial <= trl.targ_off(session,1)

                    if mat.matrix(session,2) == 1
                        Screen('BlendFunction', win, 'GL_ONE', 'GL_ZERO');
                        Screen('DrawTextures', win, gabortex, [], info.coordL, trl.targ_ori(session),...
                            0, 1, [], [], kPsychDontDoRotation, propertiesMat');
                    else
                        Screen('BlendFunction', win, 'GL_ONE', 'GL_ZERO');
                        Screen('DrawTextures', win, gabortex, [], info.coordR, trl.targ_ori(session),...
                            0, 1, [], [], kPsychDontDoRotation, propertiesMat');
                    end
                end
            end

            % Draw noise patches
            if trial >= trl.wnoise_on(session,1) && trial <= trl.wnoise_off(session,1)

            %    if mat.matrix(session,2) == 1

                    Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawTextures',win,texMaskL,[],info.coordL,0,[],[]);

             %   else
                    Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                    Screen('DrawTextures',win,texMaskR,[],info.coordR,0,[],[]);
              %  end

            end


            Screen('Flip', win);

            if sub.treino == 's'
                WaitSecs(info.trng_time);
            end


             if trial >= 1 && trial <= trl.targ_off(session,1)
                    if ~inFixWindow(x_gaze,y_gaze,fix_win_center)
                        if FIX == 2
                            FIX = 3;
                        end
                    end
             end


        end


        % DRAW FIXATION POINT AND PLACEHOLDERS
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);

        if mat.matrix(session,2) == 1
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix*1.5,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        else
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix*1.5,info.black_idx,[],2,1);
        end


        Screen('Flip', win);

        ResponsePixx('StartNow', 1, [0 1 0 1 0], 1);
        while 1
            [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);

            if sub.treino == 's'

                if ~isempty(buttons)
                    if buttons(1,2) == 1         % Yellow button (saw the target)
                        response = 1;
                        break;
                    elseif buttons(1,4) == 1     % Blue button (didn't see the target)
                        response = 0;
                        %    abort = true;
                        break;
                    elseif buttons(1,5) == 1         % White button
                        abort = true;
                        break;
                    end
                end
            else
                if ~isempty(buttons)
                    if buttons(1,2) == 1         % Yellow button (saw the target)
                        response = 1;
                        break;
                    elseif buttons(1,4) == 1     % Blue button (didn't see the target)
                        response = 0;
                        %    abort = true;
                        break;
                    end
                end
            end

        end
        ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);


        % abort experiment training if abort is true. for the staircase per
        % se, it is not possible to abort during the experiment.
        if sub.treino == 's'
            if abort == true
                break;
            end
        end


        % get orientation response if subject reports target present
        if response == 1

            ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)
                    if buttons(1,1) == 1         % Red button (CW)
                        break;
                    elseif buttons(1,3) == 1     % Green button (CCW)
                        break;
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

        end


        % Colect answer for each trial.
        if response == 1 && mat.matrix(session,3) == 0 % Hit
            resp(session,1) = 1;
        elseif response == 1 && mat.matrix(session,3) == 1 % False alarm
            resp(session,2) = 1;
        elseif response == 0 && mat.matrix(session,3) == 1 % Correct Rejection
            resp(session,3) = 1;
        elseif response == 0 && mat.matrix(session,3) == 0 % Miss
            resp(session,4) = 1;
        end


        % during staircase training, fixation dot turns yellow if target
        % present or blue if absent at the end of each trial.
        if sub.treino == 's'
            if resp(session,1) == 1 || resp(session,4) == 1
                fp = imread('/home/kaneda/Documents/GitHub/PSA_FBA/Images/yfp.png');
            elseif resp(session,2) == 1 || resp(session,3) == 1
                fp = imread('/home/kaneda/Documents/GitHub/PSA_FBA/Images/bfp.png');
            end

            tex_col = Screen('MakeTexture', win, fp); clear fp;

            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawTexture', win, tex_col, [], [info.scr_xcenter - info.dot_size_pix/2 ...
                info.scr_ycenter - info.dot_size_pix/2 ...
                info.scr_xcenter + info.dot_size_pix/2 ...
                info.scr_ycenter + info.dot_size_pix/2], 0);
            Screen('Flip', win); WaitSecs(0.3);

             % DRAW FIXATION POINT AND PLACEHOLDERS
            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('Flip', win); WaitSecs(0.2);

        end


         if FIX == 3

            ofp = imread('/home/kaneda/Documents/GitHub/PSA_FBA/Images/ofp.jpg');
            tex_col2 = Screen('MakeTexture', win, ofp); clear ofp;

            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawTexture', win, tex_col2, [], [info.scr_xcenter - info.dot_size_pix/2 ...
                info.scr_ycenter - info.dot_size_pix/2 ...
                info.scr_xcenter + info.dot_size_pix/2 ...
                info.scr_ycenter + info.dot_size_pix/2], 0);
            Screen('Flip', win); WaitSecs(0.3);
        end



        % update staircase value if the current trial had a target
        if mat.matrix(session,3) == 0
            if response == 1
                outcome = 1;
            else
                outcome = 0;
            end

            [info,UD] = UD_update(info,UD,outcome);

        end


    end

    Screen('CloseAll');
    ResponsePixx('Close');

    Eyelink('CloseFile');

    ntimes = 1;
    while ntimes <= 10
        status = Eyelink('ReceiveFile');
        if status > 0
            break
        end
        ntimes = ntimes + 1;
    end
    if status <= 0
        warning('EyeLink data has not been saved properly.');
    else
        fprintf('EyeLink data saved properly on attempt %d.\n',ntimes);
    end
    Eyelink('ShutDown');


    FlushEvents;
    ListenChar(0);
    ShowCursor;
    Priority(0);


catch

    psychrethrow(psychlasterror);
    sca; close all;

end

    function fix = inFixWindow(mx,my,fix_window)
        fix = mx > fix_window(1) &&  mx <  fix_window(3) && ...
            my > fix_window(2) && my < fix_window(4) ;
    end

end