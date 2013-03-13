function rcic_calc_average_contrasts(cfg)
% function rcic_calc_average_contrasts(cfg)
%
% The function calculates the average weighting parameters for different
% response keys or response key combinations.
%
% Copyright: Oliver Langner June 2010, adapted by Ron Dotsch

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data directory
if ~isfield(cfg, 'datadir'), cfg.datadir = pwd; end

%data file
if ~isfield(cfg, 'rcicD'), cfg.rcicD = 'rcic_data.mat'; end

%stimulus file
if ~isfield(cfg, 'rcicS'), cfg.rcicS = 'rcic_stimuli.mat'; end

%stimulus column
if ~isfield(cfg, 'resp_col'), cfg.stim_col = 'resp'; end

%conditions to calculate averages for
if ~isfield(cfg, 'cond')
    cfg.cond = { ...
        {'Condition1', {1,2}} ...
        {'Condition2', {3,4}} ...
        {'DiffCI', {1,2}, {3,4}}
    };
end

%number of conditions
nrC = length(cfg.cond);

%load needed data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load behavioral data
load(fullfile(cfg.datadir, cfg.rcicD), 'data');

%get number of participants
nrP = length(data);

%load contrast weights from stimulus file
load(fullfile(cfg.datadir, cfg.rcicS), 'contrast');

%calculate mean contrast weights %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Calculating mean contrast parameters...');

%init container for mean parameters (weights x conditions x participants)
m_par = zeros(size(contrast, 1), nrC, nrP);

for p = 1 : nrP %loop over participants
    for c = 1 : nrC %loop over conditions
        
        %get index of trials matching condition
        idx1 = find_matching_trials(data{p}.(cfg.resp_col), cfg.cond{c}{2});
        
        if (length(cfg.cond{c}) == 2) %only one condition
            
            %calculate mean parameters
            m_par(:, c, p) = mean(contrast(:, idx1), 2);
            
        else %difference between conditions
            
            %get index of trials matching complement condition
            idx2 = find_matching_trials(data{p}.(resp_col), cfg.cond{c}{3});
            
            %calculate mean difference parameters
            m_par(:, c, p) = mean([contrast(:, idx1) -contrast(:, idx2)], 2);
        end
    end
end

fprintf('Done!\n');

%save mean parameters to file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving mean parameters to file %s...', ...
    fullfile(cfg.datadir, cfg.rcicD));

%rename cfg to prevent overwriting
avg_cfg = cfg;

%append average parameters
save(fullfile(cfg.datadir, cfg.rcicD), 'm_par', 'avg_cfg', '-append');

fprintf('Done!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [idx] = find_matching_trials(data, cond_resp)

%get fit of actual and desired responses
tmp = cellfun(@(x) data == x, cond_resp, 'UniformOuput', false);

%get index of trials with at least one matching response
idx = any(cat(2, tmp{:}), 2);
