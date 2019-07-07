format long g
format compact
clc
close all
clearvars

% get the location of the script file to save figures
full_path = mfilename('fullpath');
[startpath,  filename, ext] = fileparts(full_path);
plot_num = 1;

%% Ask the user for the needed files

% Ask for the current results file.  If no file is selected assume that we
% are starting at iteration 1 and nothing has been run yet
file_filter = {'*.mat','Mat Files';'*.*','All Files' };

startpath = 'D:\IUPUI\DfD\dfd_dnn_pso\pso_results\';

[mat_save_file, mat_save_path] = uigetfile(file_filter, 'Select Mat File', startpath);
if(mat_save_path == 0)
    return;
end

load(fullfile(mat_save_path,mat_save_file));

commandwindow;

%% start running the analysis

% get the number of particles 
N = size(X,1);

GB = G(end);

num_params = numel(GB.con) + numel(GB.bn) + numel(GB.act) + numel(GB.fc);

m = zeros(N,itr);

% cycle through the ierations to the the percentage 
for idx=1:itr
    
    fprintf('Iteration: %03d: ', idx);
    % cycle through the particles
    for jdx=1:N
        
        match_con = (GB.con == X(jdx,idx).con);
        match_bn = (GB.bn == X(jdx,idx).bn);
        match_act = (GB.act == X(jdx,idx).act);
        match_fc = (GB.fc == X(jdx,idx).fc);
        
        m(jdx,idx) = sum(match_con(:)) + sum(match_bn(:)) + sum(match_act(:)) + sum(match_fc(:));
        
        fprintf('%1.4f, ', m(jdx,idx)/num_params);
        
    end
    fprintf('\n');
    
end

%% get the cummulative results

m_total = sum(m,1);

m_total = m_total/(num_params*N); 

lim = [0.90, 0.95, 0.99];

for idx=1:numel(lim)
    p_index(idx) = find(m_total > lim(idx), 1, 'first');
end


%% plot the results

col = ['m', 'r', 'g'];

figure(plot_num);
set(gcf,'position',([50,50,1200,600]),'color','w')
box on;
grid on;
hold on;

p1 = plot([1:1:itr], m_total*100, '-b', 'LineWidth', 1);

for idx=1:numel(lim)  
    %l{idx} = plot([1,p_index(idx)], [lim(idx), lim(idx)]*100, 'LineStyle' ,'--', 'LineWidth', 1, 'Color', col(idx));
    %stem(p_index(idx), lim(idx)*100, 'LineStyle' ,'--', 'LineWidth', 1, 'Color', col(idx), 'Marker', 'none');
    
    l{idx} = plot([0,itr+1], [lim(idx), lim(idx)]*100, 'LineStyle' ,'--', 'LineWidth', 1, 'Color', col(idx));
    stem(p_index(idx), m_total(p_index(idx))*100, 'LineStyle' ,'--', 'LineWidth', 1, 'Color', 'k', 'Marker', 'none');
end

set(gca, 'fontweight', 'bold', 'FontSize', 13);

% X-axis
xlim([1 itr]);
xticks([0:5:itr]);
xtickangle(90);
xlabel('Iteration', 'fontweight','bold','FontSize', 13);
set(gca,'XMinorTick','on', 'XMinorGrid','on');

% Y-axis
plt_step = 20;
plt_min = floor(min(m_total)*plt_step)/plt_step;
plt_max = 1;
ylim([plt_min plt_max]*100);
yticks([plt_min:0.05:plt_max]*100);
ylabel('Convergence (%)', 'fontweight','bold','FontSize', 13);
ytickformat('%2.2f');
set(gca,'YMinorTick','on', 'YMinorGrid','on');

title('PSO Particle Convergence Chart', 'fontweight','bold','FontSize', 16);

l2 = [p1];
plot_name = {'Particle Convergence'};

for idx=1:numel(lim) 
    l2 = cat(2, l2, l{idx});
    plot_name{idx+1} = strcat(num2str(lim(idx)*100, '%2.2f'),'% Convergence');
end

lgd = legend(l2, plot_name, 'location', 'southwest', 'orientation', 'vertical');
tmp = lgd.Position;
lgd.Position = [0.1, tmp(2:4)];

ax = gca;
ax.YAxis.MinorTickValues = (plt_min:0.025:plt_max)*100;
ax.XAxis.MinorTickValues = (1:1:itr);
ax.Position = [0.08 0.1 0.90 0.85];

plot_num = plot_num + 1;


