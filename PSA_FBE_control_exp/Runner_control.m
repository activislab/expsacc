
close all; clear; clc;

git_path = '/home/kaneda/Documents/GitHub/PSA_FBA_control_exp';
addpath(genpath(git_path));

pc_path =  '/home/kaneda/Documents/Projects/PSA_FBA_control_exp';
addpath(genpath(pc_path));

cd(git_path);


% Ask subject information
answer = inputdlg({'Número sujeito', 'Número sessão','Visibilidade gabor'}, '', [1 26], {'', '',''});
sub_id = str2double(answer{1});
sub.ses_num = str2double(answer{2}); 


% Load trial infos for this session
info_path = fullfile(sprintf('%s/Data/S%d/ses_%d_trlinfo_sub_%d*', pc_path, sub_id,sub.ses_num, sub_id));
info_file = dir(info_path);
load([info_file.folder '/' info_file.name])

sub.ses = answer{2};
sub.ses_num = str2double(answer{2});
sub.targ = str2double(answer{3});

if trl.feature_ses(sub.ses_num,1) == 1
    sub.gabor_vh = 'CW-CCW';
else
    sub.gabor_vh = 'CCW-CW';
end

if rem(sub.id_num,2) == 1
    sub.button = 'green (CW)';
else
    sub.button = 'green (CCW)';
end

% Ask (more) subject information
[sub] = Inputsubject(sub);
%save([info_file.folder '/' info_file.name], '-append', 'sub')

%% Run experiment

[srt,resp,time,trl] = On_Screen_control(info,trl,sub,gabor,mask);

%%

% Save data files
sub.data_fname = sprintf('data_sub_%d_ses_%d_%s', sub.id_num, sub.ses_num, datestr(now,'yymmdd-HHMM')); %#ok<TNOW1,DATST>
save(fullfile(sprintf('%s/Data/S%d/Task/%s', pc_path, sub.id_num), [sub.data_fname, '.mat']), 'info', 'trl', 'sub','resp','gabor','mask','time','srt', '-v7.3'); % resp

sub.eye_fname = 'FBAeye.edf';
if exist(sub.eye_fname, 'file')
    movefile(sub.eye_fname, sprintf('%s/Data/S%d/Eye/%s.edf', pc_path, sub.id_num, sub.data_fname));
else
    error('Eye-tracker data file not found!');
end


[s] = GetSRT(sub);

save(fullfile(sprintf('%s/Data/S%d/Task/%s', pc_path, sub.id_num), [sub.data_fname, '.mat']), 'info', 'trl', 'sub','resp','gabor','mask','time','srt','s', '-v7.3'); % resp
