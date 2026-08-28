
git_path = 'Insert_git_folder_location_here';
addpath(genpath(git_path));

pc_path = 'Insert_files_location_here';
addpath(genpath(pc_path));


% Ask for participant and session information. 
% Gabor visibility is based on the staircase procedure.
answer = inputdlg({'Participant number', 'Session number', 'Gabor visibility'}, '', [1 26], {'', '', ''});

sub_id = str2double(answer{1});
sub.ses_num = str2double(answer{2});

% Load the trial information corresponding to the selected session.
info_path = fullfile(sprintf('%s/Data/S%d/ses_%d_trlinfo_sub_%d*', ...
    pc_path, sub_id, sub.ses_num, sub_id));

info_file = dir(info_path);
load([info_file.folder '/' info_file.name])

sub.ses = answer{2};
sub.ses_num = str2double(answer{2});
sub.targ = str2double(answer{3});


% Collect additional participant information.
    % Participant number, session number, genre, age, dominant hand, 
    % dominant eye, corrected vision.

%% Run the experiment

[resp, time, trl] = On_Screen(info, trl, sub, gabor, mask);

%% Save experiment data

% Save behavioral and trial data.
sub.data_fname = sprintf('data_sub_%d_ses_%d_%s', ...
    sub.id_num, sub.ses_num, datestr(now,'yymmdd-HHMM')); %#ok<TNOW1,DATST>

save(fullfile(sprintf('%s/Data/S%d/Task/%s', pc_path, sub.id_num), ...
    [sub.data_fname, '.mat']), ...
    'info', 'trl', 'sub', 'resp', 'gabor', 'mask', 'time', '-v7.3');

% Move the eye-tracker EDF file to the participant's Eye folder.
sub.eye_fname = 'FBEeye.edf';

if exist(sub.eye_fname, 'file')
    movefile(sub.eye_fname, ...
        sprintf('%s/Data/S%d/Eye/%s.edf', ...
        pc_path, sub.id_num, sub.data_fname));
else
    error('Eye-tracker data file not found!');
end
