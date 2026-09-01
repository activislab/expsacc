%% d' prime analysis for each Condition:
% 1 = Towards + High Prob
% 2 = Towards + Low Prob
% 3 = Away + High Prob
% 4 = Away + Low Prob

% For more details on how to compute visual sensitivity and criterion for
% multialternative detection tasks, see " Sridharan, D.,
% Steinmetz, N. A., Moore, T., & Knudsen, E. I. (2014). Distinguishing
% bias from sensitivity effects in multialternative detection tasks.
% Journal of Vision, 14(9), 16-16."


% The variable below will receive the dprime values for each subject and
% condition
dprime = NaN(19,4);


data_path = sprintf('Insert_folder_location_here/Data_and_analysis_scripts/Data_participants/');
addpath(genpath(data_path));

data_path2 = sprintf('Insert_folder_location_here/Data_and_analysis_scripts/mADC-Model-master/');
addpath(genpath(data_path2));

for subject = 1:19



    files = fullfile(sprintf('%s/Data_subject_%d.mat',data_path,subject));
    file = dir(files);
    load(file.name);


    correct_report = (Data_Table{:,"Ori_report"} == Data_Table{:,"Target_orientation"}) & (Data_Table{:,"Ori_report"} ~= 0);

    % Sum of correct target discriminations for each condition
    for cond_hit = 1:4
        hit(cond_hit) = sum(Data_Table{:,"Condition"} == cond_hit & Data_Table{:,"Hit"} == 1 & ...
            Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"perceptual_analysis"} == 1 & ...
            correct_report(:,1) == 1);
    end


    % Sum of misidentifications for each condition.
    % Misidentification: Incorrect target orientation report when correctly
    % reporting target presence.
    for cond_misid = 1:4
        misid(cond_misid) = sum(Data_Table{:,"Condition"} == cond_misid & Data_Table{:,"Hit"} == 1 & ...
            Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"perceptual_analysis"} == 1 & ...
            correct_report(:,1) == 0);
    end


    % Sum of False alarms for each condition
    for cond_fa = 1:4
        fa(cond_fa) = sum(Data_Table{:,"Condition"} == cond_fa & Data_Table{:,"False_alarm"} == 1 & ...
            Data_Table{:,"Catch_trial"} == 1 & Data_Table{:,"perceptual_analysis"} == 1);
    end
    fa_towards = sum(fa(1:2));
    fa_away = sum(fa(3:4));


    % Sum of Correct Rejection for each condition
    for cond_cr = 1:4
        cr(cond_cr) = sum(Data_Table{:,"Condition"} == cond_cr & Data_Table{:,"Correct_rejection"} == 1 & ...
            Data_Table{:,"Catch_trial"} == 1 & Data_Table{:,"perceptual_analysis"} == 1);
    end
    cr_towards = sum(cr(1:2));
    cr_away = sum(cr(3:4));


    % Sum of misses for each condition
    for cond_miss = 1:4
        miss(cond_miss) = sum(Data_Table{:,"Condition"} == cond_miss & Data_Table{:,"Miss"} == 1 & ...
            Data_Table{:,"Catch_trial"} == 0 & Data_Table{:,"perceptual_analysis"} == 1);
    end



    Matrix_towards = [hit(1)       misid(2)     miss(1)
        misid(1)     hit(2)       miss(2)
        fa_towards   fa_towards   cr_towards];

    [theta_est_towards,  ~,  ~,  ~, ~] = mADC_model_fit(Matrix_towards);


    Matrix_away = [hit(3)       misid(4)     miss(3)
        misid(3)     hit(4)       miss(4)
        fa_away      fa_away      cr_away];

    [theta_est_away,  ~,  ~,  ~, ~] = mADC_model_fit(Matrix_away);

    dprime(subject,:) = [theta_est_towards(1,1:2) theta_est_away(1,1:2)];

end


%% RAINCLOUD PLOTS FOR EACH CONDITION (FOUR IN TOTAL)


data_path3 = sprintf('Insert_folder_location_here/Data_and_analysis_scripts/libra-master/');
addpath(genpath(data_path3));




figure
% % First subplot (top panel)

subplot(2,4,[3 4])
hold on;

data = dprime([1:9 11:17 19],:);

% Set parameters (keep your original parameters)
boxWidth = 0.5;
cloudWidth = 0.3;
dotSize = 7;
dotAlpha = 0.8;
linesize = .6;
colors = [[230 138 110]/255;[138 153 201]/255;...
    [230 138 110]/255;[138 153 201]/255;];
lineColor = [0.7 0.7 0.7];
lineAlpha = 0.4;
xPos = [1, 2, 3.5, 4.5];

% Rest of your original plotting code (unchanged)
for row = 1:size(data,1)
    if ~isnan(data(row,1)) && ~isnan(data(row,2))
        plot([xPos(1)+.19 xPos(2)-.19], [data(row,1) data(row,2)], ...
            'Color', [lineColor, lineAlpha], 'LineWidth', linesize);
    end
    if ~isnan(data(row,3)) && ~isnan(data(row,4))
        plot([xPos(3)+.19 xPos(4)-.19], [data(row,3) data(row,4)], ...
            'Color', [lineColor, lineAlpha], 'LineWidth', linesize);
    end
end

for i = 1:4
    currData = data(:,i);
    currData = currData(~isnan(currData));

    if ismember(i, [2,4])
        boxplot(currData, 'Positions', xPos(i)-.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol','','BoxStyle','filled','PlotStyle','compact');

        % Compute mean
        m = mean(currData);
        % Define horizontal line width (small)
        meanWidth = 0.12;
        % Plot mean as horizontal blue line
        if ismember(i, [2,4])
            xCenter = xPos(i) - .08; % same as boxplot position
        else
            xCenter = xPos(i) + .08;
        end
        plot(xCenter, m,'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');


        scatter(xPos(i)-.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);

        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) + f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);
    else
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) - f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);
        scatter(xPos(i)+.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);

        boxplot(currData, 'Positions', xPos(i)+.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol', '','BoxStyle','filled','PlotStyle','compact');

        % Compute mean
        m = mean(currData);
        % Define horizontal line width (small)
        meanWidth = 0.12;
        % Plot mean as horizontal blue line
        if ismember(i, [2,4])
            xCenter = xPos(i) - .08; % same as boxplot position
        else
            xCenter = xPos(i) + .08;
        end
        plot(xCenter, m,'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');

    end
end

% Adjust axes and labels
xlim([0.5, 5]);
ylim([-1, 5]);
xticks([mean(xPos(1:2)), mean(xPos(3:4))]);
yticks([0 1 2 3 4]);
xticklabels({'Towards', 'Away'});
ylabel('Sensitivity (d'')','FontSize',8);
xlabel('Saccade Direction','FontWeight','bold');

% Add legend
h = gobjects(2,1);
h(1) = scatter(NaN, NaN, dotSize, 'MarkerFaceColor', colors(1,:), 'MarkerEdgeColor', 'none');
h(2) = scatter(NaN, NaN, dotSize, 'MarkerFaceColor', colors(2,:), 'MarkerEdgeColor', 'none');
leg = legend(h, {'High', 'Low'}, 'Location', 'best', 'Box', 'off');
title(leg,'Feature Probability','FontWeight','bold')
% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;

% Add divider between congruency conditions
line([2.75 2.75], ylim, 'Color', [0.5 0.5 0.5], 'LineStyle', '--', 'HandleVisibility', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RAINCLOUD COMPARING SACCADE TOWARDS VS AWAY
%--------------------------------------------------------------------------

subplot(2,4,1)

% Set parameters - now only need 2 colors since we have 2 groups
boxWidth = 0.5;
cloudWidth = 0.3;
%dotSize = 10;
dotAlpha = 0.8;
colors = [[.3 .3 .3];[.65 .65 .65]];

lineColor = [0.7 0.7 0.7];
lineAlpha = 0.4;
xPos = [1, 2]; % Only 2 positions now

% Group the data: columns 1&2 become group 1, columns 3&4 become group 2
groupedData = zeros(size(data,1), 2);
groupedData(:,1) = mean(data(:,[1,2]), 2, 'omitnan'); % Average of columns 1&2
groupedData(:,2) = mean(data(:,[3,4]), 2, 'omitnan'); % Average of columns 3&4

% Plot connecting lines between the two groups
hold on;
for row = 1:size(groupedData,1)
    if ~isnan(groupedData(row,1)) && ~isnan(groupedData(row,2))
        plot([xPos(1)+.19 xPos(2)-.19], [groupedData(row,1) groupedData(row,2)], ...
            'Color', [lineColor, lineAlpha], 'LineWidth', linesize);
    end
end

% Plot for each group
for i = 1:2
    currData = groupedData(:,i);
    currData = currData(~isnan(currData));

    if i == 2 % Right side (Group 2: columns 3&4)
        % Boxplot on the left side of position
        boxplot(currData, 'Positions', xPos(i)-.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol','','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)-.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');

        % Scatter points on the left side
        scatter(xPos(i)-.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);


        % Density distribution on the right side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) + f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);

    else % Left side (Group 1: columns 1&2)
        % Density distribution on the left side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) - f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);

        % Scatter points on the right side
        scatter(xPos(i)+.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);

        % Boxplot on the right side of position
        boxplot(currData, 'Positions', xPos(i)+.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol', '','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)+.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');
    end
end

% Adjust axes and labels
xlim([0.5, 2.5]);
ylim([-1, 5]);
xticks(xPos);
yticks([0 1 2 3 4]);
xticklabels({'Towards', 'Away'});
ylabel('Sensitivity (d'')','FontSize',8);
xlabel('Saccade Direction','FontWeight','bold');


% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);

text(mean(xPos), 3.3, 'p < .001', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom');
hold off;

%--------------------------------------------------------------------------
%%% BAGPLOT COMPARING SACCADE TOWARDS VS AWAY
%--------------------------------------------------------------------------
subplot(2,4,2)

colors = [[.3 .3 .3];[.65 .65 .65]];

% --- Background patches ---
xLimits = [-.2 4];
yLimits = [-.2 4];

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

result = bagplot([mean(data(:,3:4),2) mean(data(:,1:2),2)], ...
    'type','hd','colorbag',[42 255 213]/255,'colorfence',[42 255 213]/255);


ax = gca;
ax.YLim = [-.2 4];
ax.XLim = [-.2 4];

ax.FontSize = 8;
ax.LineWidth = 1;
ax.XTick = 0:1:4;
ax.YTick = 0:1:4;

ylabel('Sacc. towards (d'')','FontSize',8);
xlabel('Sacc. away (d'')','FontSize',8);

% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% RAINCLOUD COMPARING HIGH VS LOW PROBABILITY
%--------------------------------------------------------------------------

subplot(2,4,5)
%data = criterion; % dprime([1 3:9 11:13 15:end],:);

% Set parameters - now only need 2 colors since we have 2 groups
boxWidth = 0.5;
cloudWidth = 0.3;
%dotSize = 15;
dotAlpha = 0.8;
colors = [[230 138 110]/255;[138 153 201]/255];
lineColor = [0.7 0.7 0.7];
lineAlpha = 0.4;
xPos = [1, 2]; % Only 2 positions now

% Group the data: columns 1&2 become group 1, columns 3&4 become group 2
groupedData = zeros(size(data,1), 2);
groupedData(:,1) = mean(data(:,[1,3]), 2, 'omitnan'); % Average of columns 1&2
groupedData(:,2) = mean(data(:,[2,4]), 2, 'omitnan'); % Average of columns 3&4

% Plot connecting lines between the two groups
hold on;
for row = 1:size(groupedData,1)
    if ~isnan(groupedData(row,1)) && ~isnan(groupedData(row,2))
        plot([xPos(1)+.19 xPos(2)-.19], [groupedData(row,1) groupedData(row,2)], ...
            'Color', [lineColor, lineAlpha], 'LineWidth', linesize);
    end
end

% Plot for each group
for i = 1:2
    currData = groupedData(:,i);
    currData = currData(~isnan(currData));

    if i == 2 % Right side (Group 2: columns 3&4)
        % Boxplot on the left side of position
        boxplot(currData, 'Positions', xPos(i)-.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol','','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)-.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');

        % Scatter points on the left side
        scatter(xPos(i)-.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);


        % Density distribution on the right side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) + f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);

    else % Left side (Group 1: columns 1&2)
        % Density distribution on the left side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) - f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', 1);

        % Scatter points on the right side
        scatter(xPos(i)+.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);

        % Boxplot on the right side of position
        boxplot(currData, 'Positions', xPos(i)+.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol', '','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)+.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');
    end
end

% Adjust axes and labels
xlim([0.5, 2.5]);
ylim([-1, 5]);
xticks(xPos);
yticks([0 1 2 3 4]);
xticklabels({'High', 'Low'});
ylabel('Sensitivity (d'')','FontSize', 8);
xlabel('Feature Probability ','FontWeight','bold');



% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);

text(mean(xPos), 3.3, 'p < .001', ...
    'FontSize', 8, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom');

hold off;

%--------------------------------------------------------------------------
%%% BAGPLOT COMPARING HIGH VS LOW PROBABILITY
%--------------------------------------------------------------------------
subplot(2,4,6)

colors = [[230 138 110]/255;[138 153 201]/255];

% --- Background patches ---
xLimits = [-.2 4];
yLimits = [-.2 4];

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

result = bagplot([mean(data(:,[2 4]),2) mean(data(:,[1 3]),2)], ...
    'type','hd','colorbag',[1 1 1],'colorfence',[1 1 1]);


ax = gca;
ax.YLim = [-.2 4];
ax.XLim = [-.2 4];

ax.FontSize = 8;
ax.LineWidth = 1;
ax.XTick = 0:1:4;
ax.YTick = 0:1:4;

ylabel('High probability (d'')','FontSize',8);
xlabel('Low probability (d'')','FontSize',8);

% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);
hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RAINCLOUD COMPARING gain (towards - away)
%--------------------------------------------------------------------------

subplot(2,4,7)
% Set parameters - now only need 2 colors since we have 2 groups
boxWidth = 0.5;
cloudWidth = 0.3;
%dotSize = 15;
dotAlpha = 0.8;
colors = [[230 138 110]/255;[138 153 201]/255];
lineColor = [0.7 0.7 0.7];
lineAlpha = 0.4;
xPos = [1, 2]; % Only 2 positions now

% Group the data: columns 1&2 become group 1, columns 3&4 become group 2
groupedData = zeros(size(data,1), 2);
groupedData(:,1) = data(:,1) - data(:,3); % Average of columns 1&2
groupedData(:,2) = data(:,2) - data(:,4); % Average of columns 3&4

% Plot connecting lines between the two groups
hold on;
for row = 1:size(groupedData,1)
    if ~isnan(groupedData(row,1)) && ~isnan(groupedData(row,2))
        plot([xPos(1)+.19 xPos(2)-.19], [groupedData(row,1) groupedData(row,2)], ...
            'Color', [lineColor, lineAlpha], 'LineWidth', linesize);
    end
end

% Plot for each group
for i = 1:2
    currData = groupedData(:,i);
    currData = currData(~isnan(currData));

    if i == 2 % Right side (Group 2: columns 3&4)
        % Boxplot on the left side of position
        boxplot(currData, 'Positions', xPos(i)-.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol','','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)-.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');

        % Scatter points on the left side
        scatter(xPos(i)-.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);


        % Density distribution on the right side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) + f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', .4);

    else % Left side (Group 1: columns 1&2)
        % Density distribution on the left side
        [f, xi] = ksdensity(currData);
        f = f/max(f) * cloudWidth;
        patch(xPos(i) - f, xi, colors(i,:), ...
            'EdgeColor', 'none', 'FaceAlpha', .4);

        % Scatter points on the right side
        scatter(xPos(i)+.19, currData(:,1), dotSize, ...
            'MarkerFaceColor', colors(i,:), ...
            'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', dotAlpha);

        % Boxplot on the right side of position
        boxplot(currData, 'Positions', xPos(i)+.08, 'Widths', boxWidth, ...
            'Colors', colors(i,:), 'Symbol', '','BoxStyle','filled','PlotStyle','compact');

        plot(xPos(i)+.08, mean(currData),'MarkerSize', 7,'Marker','_','LineWidth',2,'MarkerEdgeColor','b');

    end
end

yline([0 0], 'LineStyle','--','Color','k','LineWidth',.8)
% Adjust axes and labels
xlim([0.5, 2.5]);
ylim([-1.5, 2.5]);
xticks(xPos);
yticks([-1:1:2]);
xticklabels({'High', 'Low'});
ylabel('d'' Gain (T - A)','FontSize', 8);
xlabel('Feature Probability','FontSize',8,'FontWeight','bold')

% Improve appearance
set(gca, 'TickDir', 'out', 'Box', 'off', 'FontSize', 8);

hold off;






