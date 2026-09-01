%%  SRT analysis and plots considering only signal-present trials. 

% Conditions:
% 1 = Towards + High Prob
% 2 = Towards + Low Prob
% 3 = Away + High Prob
% 4 = Away + Low Prob

% The variable below will receive the saccade latency values for each subject and
% condition
SRT2 = NaN(19,4);


data_path = sprintf('Insert_folder_location_here/Data_and_analysis_scripts/Data_participants/');
addpath(genpath(data_path));



for subject = 1:19



    files = fullfile(sprintf('%s/Data_subject_%d.mat',data_path,subject));
    file = dir(files);
    load(file.name);


    SRT2(subject,1) = median(Data_Table{Data_Table{:,"Condition"} == 1 & Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"oculomotor_analysis"} == 1,"sacc_onset"});
    SRT2(subject,2) = median(Data_Table{Data_Table{:,"Condition"} == 2 & Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"oculomotor_analysis"} == 1,"sacc_onset"});
    SRT2(subject,3) = median(Data_Table{Data_Table{:,"Condition"} == 3 & Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"oculomotor_analysis"} == 1,"sacc_onset"});
    SRT2(subject,4) = median(Data_Table{Data_Table{:,"Condition"} == 4 & Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"oculomotor_analysis"} == 1,"sacc_onset"});

end

%% Saccade latency plots


data_path3 = sprintf('Insert_folder_location_here/Data_and_analysis_scripts/libra-master/');
addpath(genpath(data_path3));


 SRT_subjects = [1:9 11:17 19];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BAGPLOT COMPARING LATENCY TOWARDS VS AWAY

figure
subplot(2,4,5)
colors = [[.3 .3 .3];[.65 .65 .65]];


% --- Background patches ---
xLimits = [190 260];
yLimits = [190 260];

% --- Gray triangle: BELOW diagonal (Away > Towards) ---
fill([xLimits(1) xLimits(2) xLimits(2)], ...
     [yLimits(1) yLimits(1) yLimits(2)], ...
     colors(2,:), 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;

% --- Green triangle: ABOVE diagonal (Towards > Away) ---
fill([xLimits(1) xLimits(1) xLimits(2)], ...
     [yLimits(1) yLimits(2) yLimits(2)], ...
     colors(1,:), 'EdgeColor', 'none', 'FaceAlpha', 1);

% Draw diagonal to visually separate the two regions
%plot(xLimits, yLimits, '--k', 'LineWidth', 1);

%result1 = bagplot([mean(SRT(idx,3:4),2) mean(SRT(idx,1:2),2)], ...
%    'type','hd','colorbag',[42 255 213]/255,'colorfence',[42 255 213]/255);

X = [mean(SRT2(SRT_subjects,3:4),2) mean(SRT2(SRT_subjects,1:2),2)];

% X = unique(X,'rows');
% X = X + randn(size(X))*1e-1;

result1 = bagplot(X, ...
    'type','hd','colorbag',[42 255 213]/255,'colorfence',[42 255 213]/255);


set(gca,'TickDir','out');
set(gca, 'Box', 'off');
set(gca, 'Color', 'none');   % Make axes background transparent so patches show
ax = gca;
ax.YLim = [190 260];
ax.XLim = [190 260];
ax.FontSize = 8;
ax.LineWidth = 1;
ax.XTick = 190:20:260;
ax.YTick = 190:20:260;
ax.FontWeight = "normal";

 ylabel('Latency Towards (ms)','FontSize',8);
 xlabel('Latency Away (ms)','FontSize',8);
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BAGPLOT COMPARING LATENCY IN TOWARDS BETWEEN HIGH AND LOW PROB
subplot(2,4,6)

colors = [([138 153 201]/255) 
               ([230 138 110]/255) ];

% --- Background patches ---
xLimits = [190 260];
yLimits = [190 260];

% --- Gray triangle: BELOW diagonal (Away > Towards) ---
fill([xLimits(1) xLimits(2) xLimits(2)], ...
     [yLimits(1) yLimits(1) yLimits(2)], ...
     colors(2,:), 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;

% --- Green triangle: ABOVE diagonal (Towards > Away) ---
fill([xLimits(1) xLimits(1) xLimits(2)], ...
     [yLimits(1) yLimits(2) yLimits(2)], ...
     colors(1,:), 'EdgeColor', 'none', 'FaceAlpha', 1);

% Draw diagonal to visually separate the two regions
%plot(xLimits, yLimits, '--k', 'LineWidth', 1);

%result2 = bagplot([mean(SRT(idx,1),2) mean(SRT(idx,2),2)], ...
%    'type','hd','colorbag',[1 1 1],'colorfence',[1 1 1]);

X = [mean(SRT2(SRT_subjects,1),2) mean(SRT2(SRT_subjects,2),2)];

X = unique(X,'rows');
X = X + randn(size(X))*1e-1;

result2 = bagplot(X, ...
    'type','hd','colorbag',[1 1 1],'colorfence',[1 1 1],'sizesubset',20);

set(gca,'TickDir','out');
set(gca, 'Box', 'off');
set(gca, 'Color', 'none');   % Make axes background transparent so patches show
ax = gca;
ax.YLim = [190 260];
ax.XLim = [190 260];
ax.FontSize = 8;
ax.LineWidth = 1;
ax.XTick = 190:20:260;
ax.YTick = 190:20:260;
ax.FontWeight = "normal";

 ylabel('Latency Low Prob. (ms)','FontSize',8);
 xlabel('Latency High Prob. (ms)','FontSize',8);
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BAGPLOT COMPARING LATENCY IN AWAY BETWEEN HIGH AND LOW PROB
subplot(2,4,7)

colors = [[138 153 201]/255;[230 138 110]/255];

% --- Background patches ---
xLimits = [190 260];
yLimits = [190 260];

% --- Gray triangle: BELOW diagonal (Away > Towards) ---
fill([xLimits(1) xLimits(2) xLimits(2)], ...
     [yLimits(1) yLimits(1) yLimits(2)], ...
     colors(2,:), 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on;

% --- Green triangle: ABOVE diagonal (Towards > Away) ---
fill([xLimits(1) xLimits(1) xLimits(2)], ...
     [yLimits(1) yLimits(2) yLimits(2)], ...
     colors(1,:), 'EdgeColor', 'none', 'FaceAlpha', 1);

% Draw diagonal to visually separate the two regions
%plot(xLimits, yLimits, '--k', 'LineWidth', 1);

%result3 = bagplot([mean(SRT(idx,3),2) mean(SRT(idx,4),2)], ...
%    'type','hd','colorbag',[1 1 1],'colorfence',[1 1 1]);

X = [mean(SRT2(SRT_subjects,3),2) mean(SRT2(SRT_subjects,4),2)];

X = unique(X,'rows');
X = X + randn(size(X))*1e-1;

result3 = bagplot(X, ...
    'type','hd','colorbag',[1 1 1],'colorfence',[1 1 1],'sizesubset',20);

set(gca,'TickDir','out');
set(gca, 'Box', 'off');
set(gca, 'Color', 'none');   % Make axes background transparent so patches show
ax = gca;
ax.YLim = [190 260];
ax.XLim = [190 260];
ax.FontSize = 8;
ax.LineWidth = 1;
ax.XTick = 190:20:260;
ax.YTick = 190:20:260;
ax.FontWeight = "normal";

 ylabel('Latency Low Prob. (ms)','FontSize',8);
 xlabel('Latency High Prob. (ms)','FontSize',8);
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT FOR SRT BETWEEN TOWARDS AND AWAY
subplot(2,4,1)

Towards = mean(SRT2(SRT_subjects,1:2),2);
Away    = mean(SRT2(SRT_subjects,3:4),2);

data = [Away Towards];

subj_mean  = mean(data,2);
grand_mean = mean(data(:));

norm_data = data - subj_mean + grand_mean;

k = size(data,2);

sem = std(norm_data) ./ sqrt(size(norm_data,1));
sem = sem * sqrt(k/(k-1));

means = mean(data);


b = barh([.28 .3],means,'BarWidth',.6,'FaceAlpha',1,'LineWidth',1.2);

hold on;
b.FaceColor = 'flat';
b.EdgeColor = "none";
b.LineWidth = 1.2;


b.CData(2,:) = [.3 .3 .3];   % Color Towards 
b.CData(1,:) = [.65 .65 .65];   % Color Away


errorbar(means,[.28 .3], sem,'horizontal', 'k', 'LineStyle','none','LineWidth',1.2,'CapSize',0);

set(gca, 'YTick', [.28 .3], 'YTickLabel', {'Away','Towards'},'FontSize',8);
set(gca,'XLim',[220 240], 'XTick', 220:5:240, 'XTickLabel', 220:5:240,'FontSize',8);
xlabel('Saccade Latency (ms)','FontSize',8);
%ylabel('Feature Probability','FontSize',8);

set(gca,'TickDir','out');
set(gca, 'Box', 'off','XColor','k','YColor','k','YLimitMethod','tickaligned');
ylim([0.09 0.32])
box off;

ax = gca;
ax.XAxisLocation = 'top';

t = title('Saccade Direction');
t.FontSize = 8;
t.Position(2) = 1.15;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT FOR SRT BETWEEN HIGH AND LOW PROB IN THE TOWARDS CONDITION
subplot(2,4,2)

Towards_High = mean(SRT2(SRT_subjects,1),2);
Towards_Low    = mean(SRT2(SRT_subjects,2),2);

data = [Towards_Low Towards_High];

subj_mean  = mean(data,2);
grand_mean = mean(data(:));

norm_data = data - subj_mean + grand_mean;

k = size(data,2);

sem = std(norm_data) ./ sqrt(size(norm_data,1));
sem = sem * sqrt(k/(k-1));

means = mean(data);



b2 = barh([.28 .3],means,'BarWidth',.6,'FaceAlpha',1,'LineWidth',1.2);

hold on;
b2.FaceColor = 'flat';
b2.EdgeColor = "none";
b2.LineWidth = 1.2;



b2.CData(2,:) = ([230 138 110]/255) ;   % Color Towards High 
b2.CData(1,:) = ([138 153 201]/255) ;   % Color Towards Low


errorbar(means,[.28 .3], sem,'horizontal', 'k', 'LineStyle','none','LineWidth',1.2,'CapSize',0);

set(gca, 'YTick', [.28 .3], 'YTickLabel', {'Low','High'},'FontSize',8);
set(gca,'XLim',[220 240], 'XTick', 220:5:240, 'XTickLabel', 220:5:240,'FontSize',8);
xlabel('Saccade Latency (ms)','FontSize',8);
%ylabel('Feature Probability','FontSize',8);

set(gca,'TickDir','out');
set(gca, 'Box', 'off','XColor','k','YColor','k','YLimitMethod','tickaligned');
ylim([0.09 0.32])
box off;

ax = gca;
ax.XAxisLocation = 'top';

t = title('Feature Probability');
t.FontSize = 8;
t.Position(2) = 1.15;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PLOT FOR SRT BETWEEN HIGH AND LOW PROB IN THE AWAY CONDITION
subplot(2,4,3)


Away_High = mean(SRT2(SRT_subjects,3),2);
Away_Low    = mean(SRT2(SRT_subjects,4),2);

data = [Away_Low Away_High];

subj_mean  = mean(data,2);
grand_mean = mean(data(:));

norm_data = data - subj_mean + grand_mean;

k = size(data,2);

sem = std(norm_data) ./ sqrt(size(norm_data,1));
sem = sem * sqrt(k/(k-1));

means = mean(data);



b3 = barh([.28 .3],means,'BarWidth',.6,'FaceAlpha',1,'LineWidth',1.2);

hold on;
b3.FaceColor = 'flat';
b3.EdgeColor = "none";
b3.LineWidth = 1.2;



b3.CData(2,:) = [230 138 110]/255;   % Color Away High 
b3.CData(1,:) = [138 153 201]/255;   % Color Away Low


errorbar(means,[.28 .3], sem,'horizontal', 'k', 'LineStyle','none','LineWidth',1.2,'CapSize',0);

set(gca, 'YTick', [.28 .3], 'YTickLabel', {'Low','High'},'FontSize',8);
set(gca,'XLim',[220 240], 'XTick', 220:5:240, 'XTickLabel', 220:5:240,'FontSize',8);
xlabel('Saccade Latency (ms)','FontSize',8);
%ylabel('Feature Probability','FontSize',8);

set(gca,'TickDir','out');
set(gca, 'Box', 'off','XColor','k','YColor','k','YLimitMethod','tickaligned');
ylim([0.09 0.32])
box off;

ax = gca;
ax.XAxisLocation = 'top';

t = title('Feature Probability');
t.FontSize = 8;
t.Position(2) = 1.15;
