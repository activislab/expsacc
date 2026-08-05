function [srt,resp,time,trl] = On_Screen(info,trl,sub,gabor,mask)
% First column  = Hits;
% Second column = False Alarms
% Third column  =  Correct rejections
% fourth column = Miss
% fifth column  = Reported target orientation if subject saw a target
resp = zeros(info.ntrials,5);

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

block_counter = 0;

session = 1;

try

    abort = false;


    % movieName = 'trial_recording_fast.mp4';
    % moviePtr = Screen('CreateMovie', win, movieName, [], [], 120);

    while session <= info.ntrials % 1:info.ntrials


        % Cria gabor patch com contrast especifico
        gabor.contrast = sub.targ;
        [gabortex, propertiesMat] = stim_gabor(win,gabor);


        SRT2 = 2; resp_trng = 2;


        Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode before drawing Host PC graphics and before recording

        % Cria Mask (White Noise patch)
        texMaskR = mask_noise(win, mask, info);
        texMaskL = mask_noise(win, mask, info);

        if trl.onset_blocks(session,1) == 1

            block_counter = block_counter + 1;


            if session == 421

                Screen('TextSize',win, 45);
                texto1 = 'Alvo mais provável mudou!' ;
                texto2 = 'Chame o pesquisador!';
                DrawFormattedText(win, [texto1 '\n' texto2], 'center', info.scr_ycenter,[1 1 1]);
                Screen('FrameRect',win,[1 1 1], [960-500 540-400 960+500 540+400],4);

                Screen('Flip', win);

                ResponsePixx('StartNow', 1, [0 0 0 0 1], 1);
                while 1
                    [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                    if ~isempty(buttons)
                        if buttons(1,5) == 1         % White button
                            break;
                        end
                    end
                end
                ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            end



            Screen('TextSize',win, 24);


            if info.matrix(session,2) == 1
                ex_img = imread('/home/kaneda/Documents/GitHub/PSA_FBA/Images/target_CW.png');
            else
                ex_img = imread('/home/kaneda/Documents/GitHub/PSA_FBA/Images/target_CCW.png');
            end

            ex_tex = Screen('MakeTexture', win, ex_img); clear ex_img;
            Screen('DrawTexture', win, ex_tex, [], [], 0);


            txt_ = '----------------------';
            txt4 = 'ORIENTAÇÃO MAIS PROVÁVEL ABAIXO!';
            color = [0 0 1];


            txt5 = '';

            DrawFormattedText(win, [txt_ txt_ txt_ txt_ '\n' txt5 '\n' txt_ txt_ txt_ txt_], 'center', info.scr_ycenter - 130, info.black_idx);
            DrawFormattedText(win, [txt5 '\n' txt4 '\n' txt5], 'center', info.scr_ycenter - 130, color);



            txt1 = 'Pressione o botão            para iniciar!';
            txt2 = ' branco';
            txt3 = sprintf('Bloco %d/%d', block_counter, sum(trl.onset_blocks));
            DrawFormattedText(win, [txt_ txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.black_idx);
            DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.black_idx);
            DrawFormattedText(win, txt2, info.scr_xcenter - 8, info.scr_ycenter + 130, [1 1 1]);
            DrawFormattedText(win, [txt_ txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.black_idx);
            DrawFormattedText(win, txt3, 'center', info.scr_ycenter + 180,info.black_idx);
            DrawFormattedText(win, txt_, 'center', info.scr_ycenter + 200,info.black_idx);


            if ismember(session,[1 31 421 451])

                texto1 = 'HORA DO TREINO!' ;
                DrawFormattedText(win, texto1, 'center', info.scr_ycenter - 300,color);
                Screen('FrameRect',win,color, [960-500 540-400 960+500 540+400],4);

            end

            Screen('Flip', win);

            ResponsePixx('StartNow', 1, [0 0 0 0 1], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)
                    if buttons(1,5) == 1         % White button
                        break;
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            if abort == false
                EyelinkDoDriftCorrection(el, [info.scr_xcenter, info.scr_ycenter]);      % Run eyetracker drift correction
                WaitSecs(1);
            end


        end

        Eyelink('Command', 'clear_screen 0');       % Clear Host PC display from any previus drawing
        Eyelink('ImageTransfer', '/home/kaneda/Documents/GitHub/PSA_FBA/Images/trl_on.bmp', 0, 0, 0, 0, 0, 0);
        Eyelink('StartRecording');
        Eyelink('Command', 'record_status_message "TRIAL %d/%d"', session, size(info.ntrials,1));


        % DRAW FIXATION POINT FOR 500 MS BEFORE TRIAL ONSET.
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix,info.white_idx, [], 2,1);
        Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
        Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        time.fp_on(session) = Screen('Flip', win);


        tic;
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


            times = GetSecs;

            if Eyelink('NewFloatSampleAvailable') > 0
                evt = Eyelink('NewestFloatSample');                     % Get the sample in the form of an event structure
                x_gaze = evt.gx(eye_used);                              % Get current gaze position from sample
                y_gaze = evt.gy(eye_used);
            end


            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

            % CUE ONSET
            if trial >= trl.cue_on(session,1) && trial <= trl.cue_off(session,1)

                % Cue on valid condition
                if info.matrix(session,1) == 1 || info.matrix(session,1) == 2
                    if info.matrix(session,3) == 1
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                    else
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                    end

                else % Cue on invalid condition
                    if info.matrix(session,3) == 1

                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                    else
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);

                    end
                end
            end

            % DRAW FIXATION POINT AND PLACEHOLDERS
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);

            % SHOW TARGET if this trial isn't catch
            if info.matrix(session,4) == 0
                if trial >= trl.targ_on(session,1) && trial <= trl.targ_off(session,1)

                    if info.matrix(session,3) == 1
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

                % if info.matrix(session,3) == 1

                Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTextures',win,texMaskL,[],info.coordL,0,[],[]);

                % else
                Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTextures',win,texMaskR,[],info.coordR,0,[],[]);
                % end

            end


            if trial == 1
                time.trl_on(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('trial_onset_%1d', session));
                Eyelink('Command', 'record_status_message "TRIAL %d', session);
            elseif trial == trl.cue_on(session,1)
                time.cue_on(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('cue_on_%1d', session));
            elseif trial == trl.cue_off(session,1)
                time.cue_off(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('cue_off_%1d', session));
            elseif trial == trl.targ_on(session,1)
                time.targ_on(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('targ_on_%1d', session));
            elseif trial == trl.targ_off(session,1)
                time.targ_off(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('targ_off_%1d', session));
            elseif trial == trl.wnoise_on(session,1)
                time.wnoise_on(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('wnoise_on_%1d', session));
            elseif trial == trl.wnoise_off(session,1)
                time.wnoise_off(session) = Screen('Flip', win);
                Eyelink('Message', sprintf('wnoise_off_%1d', session));
            else
                Screen('Flip', win);
            end


            % if trial == trl.wnoise_on(session,1)
            %     if info.matrix(session,3) == 2
            %         current_display = Screen('GetImage',win);
            %         imwrite(current_display, 'wnoise.png');
            %     end
            % end


            if trial >= trl.cue_on(session,1)
                if ~inFixWindow(x_gaze,y_gaze,fix_win_center)
                    if SRT2 == 2
                        SRT2 = times - time.cue_on(session);
                        srt(session) = SRT2; %#ok<AGROW>
                    end
                end
            end


            % % Add frame to movie
            % Screen('AddFrameToMovie', win);

        end

        % DRAW FIXATION POINT AND PLACEHOLDERS
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);

        if info.matrix(session,3) == 1
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix*1.5,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        else
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix*1.5,info.black_idx,[],2,1);
        end


        Screen('Flip', win);
        
            %         % Add frame to movie
            % Screen('AddFrameToMovie', win);

    


        % if info.matrix(session,3) == 2
        %     current_display = Screen('GetImage',win);
        %     imwrite(current_display, 'cue_resp.png');
        % end



        % ResponsePixx color mapping
        %%% red    [1] = right
        %%% yellow [2] = front
        %%% green  [3] = left
        %%% blue   [4] = bottom
        %%% white  [5] = middle


        ResponsePixx('StartNow', 1, [0 1 0 1 0], 1);
        while 1
            [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
            if ~isempty(buttons)
                if buttons(1,2) == 1         % Yellow button (saw the target)
                    response = 1;
                    break;
                elseif buttons(1,4) == 1     % Blue button (didn't see the target)
                    response = 0;
                    break;
                    % elseif ~isempty(buttons)
                    %     if buttons(1,2) == 1     % Yellow button
                    %         abort = true;
                    %         break;
                    %     end
                end
            end
        end
        ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

        if abort == true
            break;
        end

        % get orientation response if subject reports target present
        if response == 1

            ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)

                    if rem(sub.id_num,2) == 1
                        if buttons(1,1) == 1         % Red button (CCW)
                            targ_ori = 2;
                            break;
                        elseif buttons(1,3) == 1     % Green button (CW)
                            targ_ori = 1;
                            break;
                        end

                    else

                        if buttons(1,1) == 1         % Red button (CW)
                            targ_ori = 1;
                            break;
                        elseif buttons(1,3) == 1     % Green button (CCW)
                            targ_ori = 2;
                            break;
                        end

                    end

                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

        end

        toc



        % Colect answer for each trial.
        if response == 1 && info.matrix(session,4) == 0 % Hit
            resp(session,1) = 1;
            resp(session,5) = targ_ori;
        elseif response == 1 && info.matrix(session,4) == 1 % False alarm
            resp(session,2) = 1;
            resp(session,5) = targ_ori;
        elseif response == 0 && info.matrix(session,4) == 1 % Correct Rejection
            resp(session,3) = 1;
        elseif response == 0 && info.matrix(session,4) == 0 % Miss
            resp(session,4) = 1;
        end




        if (session >= 1 && session <= 60) || (session >= 421 && session <= 480)

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

            %                     % Add frame to movie
            % Screen('AddFrameToMovie', win);

        end


        if  SRT2 > 0.33  % || FIX == 3

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



            % Screen('FinalizeMovie', moviePtr);
        %--------------------------------------------------------------------------

        if session == 60 || session == 480

            txt6 = 'Deseja realizar o treino novamente? \n\n (Sim - verde / Não - Vermelho)';
            DrawFormattedText(win, txt6, 'center', info.scr_ycenter - 250, info.white_idx);
            Screen('Flip', win);


            ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)
                    if buttons(1,1) == 1         % Red button (go to experiment)
                        resp_trng = 1;
                        break;
                    elseif buttons(1,3) == 1     % Green button (training again)
                        resp_trng = 0;
                        break;
                        % elseif ~isempty(buttons)
                        %     if buttons(1,2) == 1     % Yellow button
                        %         abort = true;
                        %         break;
                        %     end
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            if resp_trng == 0
                if session == 60
                    trl.repeated_blk(1,1) = 1;
                elseif session == 480
                    trl.repeated_blk(1,2) = 1; 
                end
            end

        end

        %--------------------------------------------------------------------------


        if trl.offset_blocks(session,1) ~= 0  

            if session == size(trl.onset_blocks,1)
                txt = 'Voce completou todos os blocos da sessão. \n\n Parabéns!';
                DrawFormattedText(win, txt, 'center', info.scr_ycenter - 250, info.black_idx);
            elseif trl.offset_blocks(session,1) == 1

                txt = sprintf('Bloco %i/%i completo.', block_counter, sum(trl.onset_blocks));
                txt1 = 'Pressione o botão            para continuar!';
                txt2 = ' branco';

                txt_ = '----------------------';
                DrawFormattedText(win, txt, 'center', info.scr_ycenter, info.black_idx);
                DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.black_idx);
                DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.black_idx);
                DrawFormattedText(win, txt2, info.scr_xcenter - 24, info.scr_ycenter + 130, [1 1 1]);
                DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.black_idx);

            elseif trl.offset_blocks(session,1) == 2

                txt = sprintf('Bloco %i/%i completo.', block_counter, sum(trl.onset_blocks));
                txt1 = 'Pressione o botão            para continuar!';
                txt2 = ' branco';
                txt3 = 'Hora do descanso!';

                txt_ = '----------------------';
                DrawFormattedText(win, txt, 'center', info.scr_ycenter, info.black_idx);
                DrawFormattedText(win, txt3, 'center', info.scr_ycenter+65, color);
                DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter +100,info.black_idx);
                DrawFormattedText(win, txt1, 'center', info.scr_ycenter + 130, info.black_idx);
                DrawFormattedText(win, txt2, info.scr_xcenter - 24, info.scr_ycenter + 130, [1 1 1]);
                DrawFormattedText(win, [txt_ txt_ txt_], 'center', info.scr_ycenter + 150,info.black_idx);

            end
            Screen('Flip', win);

            ResponsePixx('StartNow', 1, [0 0 0 0 1], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)
                    if buttons(1,5) == 1         % White button
                        break;
                    end
                end
            end
            ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);

            if abort == true
                break;
            end


        end


        if resp_trng == 0

            session = abs(session - 60);

             block_counter = block_counter - 2;
        end

        session = session + 1;


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