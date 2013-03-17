function rcic_calc_average_contrasts(cfg)
% function rcic_calc_average_contrasts(cfg)
%
% The function calculates the average weighting parameters for different
% response keys or response key combinations.
%
% Copyright: Oliver Langner June 2010, adapted by Ron Dotsch

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%structure with default settings
defaults = struct( ...
    'root', pwd, ...                        %root directory
    'resp_col', 'Response', ...             %column name of response column
    'stim_col', 'ImageNr', ...               %name of stimulus number column
    'cond', {{'Condition1', {1}}} ...       %condition definition
    );

%set defaults not defined in cfg
cfg = join_configs(defaults, cfg);

%number of conditions
nrC = length(cfg.cond);

%load needed data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load behavioral data
load(fullfile(cfg.root, 'rcic_data.mat'), 'data', 'contrast');

%get number of participants
nrP = length(data);

%calculate mean contrast weights %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Calculating mean contrast parameters...');

%init container for mean parameters (weights x conditions x participants)
m_par = zeros(size(contrast, 1), nrC, nrP);

for p = 1 : nrP %loop over participants
    for c = 1 : nrC %loop over conditions
        
        %get index of stimulus and trial columns
        respIdx = find(strcmp(cfg.resp_col, data{p}.header));
        stimIdx = find(strcmp(cfg.stim_col, data{p}.header));
        
        %get index of trials matching condition
        idx1 = find_matching(data{p}.data(:, respIdx), cfg.cond{c}{2});
        
        %get image numbers of those trials
        nr1 = cell2mat(data{p}.data(idx1, stimIdx));
        
        if (length(cfg.cond{c}) == 2) %only one condition
            
            %calculate mean parameters
            m_par(:, c, p) = mean(contrast(:, nr1), 2);
            
        else %difference between conditions
            
            %get index of trials matching complement condition
            idx2 = find_matching(data{p}.data(:, respIdx), cfg.cond{c}{3});
            
            %get image numbers of those trials
            nr2 = cell2mat(data{p}.data(idx2, stimIdx));
            
            %calculate mean difference parameters
            m_par(:, c, p) = mean([contrast(:, nr1) -contrast(:, nr2)], 2);
        end
    end
end

fprintf('Done!\n');

%save mean parameters to file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Adding mean parameters to rcic_data.mat...');

%rename cfg to prevent overwriting
avg_cfg = cfg;

%append average parameters
save(fullfile(cfg.root, 'rcic_data.mat'), 'm_par', 'avg_cfg', '-append');

fprintf('Done!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [idx] = find_matching(data, cond_resp)

if isnumeric(data{1})
    %get fit of actual and desired responses (using numbers)
    tmp = cellfun(@(x) cell2mat(data) == x, cond_resp, ...
        'UniformOutput', false);
else
    %get fit of actual and desired responses (trying strings)
    tmp = cellfun(@(x) strcmp(x, data), cond_resp, 'UniformOutput', false);
end

%get index of trials with at least one matching response
idx = any(cat(2, tmp{:}), 2);
