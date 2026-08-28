function [resp,time,trl] = On_Screen(info,trl,sub,gabor,mask)
% First column  = Hit
% Second column = False Alarm
% Third column  =  Correct rejection
% fourth column = Miss
% fifth column  = Reported target orientation if subject saw a target
resp = zeros(info.ntrials,5);

ResponsePixx('Close');
ResponsePixx('Open');

%% Screen setup

FlushEvents;
PsychDefaultSetup(2);% default settings for setting up Psychtoolbox

% Screen setup
Screen('Preference', 'SyncTestSettings', 0.01, 50, 0.25);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'Verbosity', 0);
Screen('Preference', 'SkipSyncTests', 1);

% Define black, white, and gray color indices.
info.white_idx = WhiteIndex(info.scr_num);
info.black_idx = BlackIndex(info.scr_num);
info.gray_idx = info.white_idx/2;

% Open a fullscreen Psychtoolbox window.
[win, info.scr_rect] = PsychImaging('OpenWindow', info.scr_num, info.gray_idx, [], 32, 2, [], []);

%%

% Eyetracking general setup here

%%

topPriorityLevel = MaxPriority(win);
Priority(topPriorityLevel);
HideCursor;
ListenChar(-1);


%%

block_counter = 0;

% trial count
trial = 1;

try


    % MAIN TRIAL LOOP
    while trial <= info.ntrials


        % Create gabor patches
        gabor.contrast = sub.targ;
        [gabortex, propertiesMat] = stim_gabor(win,gabor);

        % Create mask patches
        texMaskR = mask_noise(win, mask, info);
        texMaskL = mask_noise(win, mask, info);


        SRT2 = 2;

        if trl.onset_blocks(trial,1) == 1

            block_counter = block_counter + 1;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Shows a message on the screen at the beginning of each short
            % block
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Run eyetracker drift correction here
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        end


        % Draw fixation point
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix,info.white_idx, [], 2,1);
        Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
        Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        time.fp_on(trial) = Screen('Flip', win);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Using the eyetracker, wait until participant is fixating on the
        % fixation point for 500 ms
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



        % FRAME LOOP
        % Each trial ends 200 ms after mask offset
        for frame = 1:trl.wnoise_off(trial,1)+24


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Get current eye position sample
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

            % Saccadic cue presentation
            if frame >= trl.cue_on(trial,1) && frame <= trl.cue_off(trial,1)

                % Congruent saccadic and response cue positions
                if info.matrix(trial,1) == 1 || info.matrix(trial,1) == 2
                    % Saccadic cue points left
                    if info.matrix(trial,3) == 1
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                        % Saccadic cue points right
                    else
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                    end

                    % Incongruent saccadic and response cue positions
                else
                    % Saccadic cue points left
                    if info.matrix(trial,3) == 1
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter + info.cue_length_px,info.scr_ycenter, info.cue_width_px);
                        % Saccadic cue points right
                    else
                        Screen('DrawLine', win, info.black_idx, info.scr_xcenter,info.scr_ycenter ...
                            ,info.scr_xcenter - info.cue_length_px,info.scr_ycenter, info.cue_width_px);

                    end
                end
            end

            % Draw fixation point and placeholders
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);

            % Target is presented if the current trial is not a catch trial
            if info.matrix(trial,4) == 0
                if frame >= trl.targ_on(trial,1) && frame <= trl.targ_off(trial,1)

                    if info.matrix(trial,3) == 1
                        Screen('BlendFunction', win, 'GL_ONE', 'GL_ZERO');
                        Screen('DrawTextures', win, gabortex, [], info.coordL, trl.targ_ori(trial),...
                            0, 1, [], [], kPsychDontDoRotation, propertiesMat');
                    else

                        Screen('BlendFunction', win, 'GL_ONE', 'GL_ZERO');
                        Screen('DrawTextures', win, gabortex, [], info.coordR, trl.targ_ori(trial),...
                            0, 1, [], [], kPsychDontDoRotation, propertiesMat');
                    end

                end
            end


            % Draw mask patches
            if frame >= trl.wnoise_on(trial,1) && frame <= trl.wnoise_off(trial,1)
                Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
                Screen('DrawTextures',win,texMaskL,[],info.coordL,0,[],[]);
                Screen('DrawTextures',win,texMaskR,[],info.coordR,0,[],[]);
            end


            % Flips screen every frame
            % sends trigger infomation to eyetracker (not shown here)
            Screen('Flip', win);


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % with the eyetracker, checks if and when fixation position 
            % moved from the screen center
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        end

        % Draw fixation point and placeholders
        Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
        Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);

        % Draw Response cue on the left or right side
        if info.matrix(trial,3) == 1
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix*1.5,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
        else
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix*1.5,info.black_idx,[],2,1);
        end

        % Flip screen
        Screen('Flip', win);


        % ResponsePixx color mapping
        %%% red    [1] = right
        %%% yellow [2] = front
        %%% green  [3] = left
        %%% blue   [4] = bottom
        %%% white  [5] = middle


        % Get first perceptual response: Target Detection
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
                end
            end
        end
        ResponsePixx('StopNow', 1, [0 0 0 0 0], 0);



        % In case of target detection, get second perceptual response:
        % Target Orientation
        if response == 1

            ResponsePixx('StartNow', 1, [1 0 1 0 0], 1);
            while 1
                [buttons, ~, ~] = ResponsePixx('GetLoggedResponses', 1, 1, 2000);
                if ~isempty(buttons)

                    % Invert button indexes based on the subject number
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



        % Records subject report as being a hit, false alarm, correct
        % rejection or miss and discrimination report 
        if response == 1 && info.matrix(trial,4) == 0 % Hit
            resp(trial,1) = 1;
            resp(trial,5) = targ_ori;
        elseif response == 1 && info.matrix(trial,4) == 1 % False alarm
            resp(trial,2) = 1;
            resp(trial,5) = targ_ori;
        elseif response == 0 && info.matrix(trial,4) == 1 % Correct Rejection
            resp(trial,3) = 1;
        elseif response == 0 && info.matrix(trial,4) == 0 % Miss
            resp(trial,4) = 1;
        end



        % For training trials only: The white fixation point turns yellow
        % (target presented) or blue (target not presented) after percetual
        % report
        if (trial >= 1 && trial <= 60) || (trial >= 421 && trial <= 480)

            tex_col; % tex_col receives the color index (blue or yellow)

            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawTexture', win, tex_col, [], [info.scr_xcenter - info.dot_size_pix/2 ...
                info.scr_ycenter - info.dot_size_pix/2 ...
                info.scr_xcenter + info.dot_size_pix/2 ...
                info.scr_ycenter + info.dot_size_pix/2], 0);
            Screen('Flip', win); WaitSecs(0.3);



            % Draw white fixation point and placeholders
            Screen('BlendFunction',win,GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix*2, info.black_idx, [], 2,1);
            Screen('DrawDots', win, [info.scr_xcenter info.scr_ycenter], info.dot_size_pix, info.white_idx, [], 2,1);
            Screen('DrawDots',win,info.pholdercoordL,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('DrawDots',win,info.pholdercoordR,info.dot_size_pix,info.black_idx,[],2,1);
            Screen('Flip', win); WaitSecs(0.2);

        end


        % White fixation point turns orange if saccade latency is higher
        % than 300 ms
        if  SRT2

            tex_col2; % tex_col2 receives the color index (orange)

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




        if trl.offset_blocks(trial,1) ~= 0

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Shows a message on the screen at the end of each short block
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        end


        trial = trial + 1;


    end

    Screen('CloseAll');
    ResponsePixx('Close');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % CLose eyelink file and save it. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    FlushEvents;
    ListenChar(0);
    ShowCursor;
    Priority(0);


catch

    psychrethrow(psychlasterror);
    sca; close all;

end


end