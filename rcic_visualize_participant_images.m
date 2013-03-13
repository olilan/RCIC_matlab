function rcic_visualize_participant_images(cfg)
% function rcic_visualize_participant_images(cfg)
%
% The function takes the results from the function
% rcic_calc_participant_contrasts and visualizes the normalized
% average noise per condition superimposed on the base face used in the
% experiment.
% 
% Copyright: Oliver Langner, September 2010, adapted by Ron Dotsch

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data directory
if ~isfield(cfg, 'datadir'), cfg.datadir = pwd; end

%data file
if ~isfield(cfg, 'rcicD'), cfg.rcicD = 'rcic_data.mat'; end

%stimulus file
if ~isfield(cfg, 'rcicS'), cfg.rcicS = 'rcic_stimuli.mat'; end

%noise weight
if ~isfield(cfg, 'nWeight'), cfg.nWeight = .5; end

%output directory for visualized images
if ~isfield(cfg, 'outdir')
    
    %get output directory
    cfg.outdir = uigetdir(pwd, 'Pick output directory');
    
    if (cfg.outdir == 0)
        fprintf('No output directory picked! Aborted...\n');
        return
    end
end

%should we also plot?
if ~isfield(cfg, 'plot'), cfg.plot = false; end

%load needed data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load behavioral data
load(fullfile(cfg.datadir, cfg.rcicD), 'm_par', 'avg_cfg', 'data');

%get number of participants
nrP = size(m_par, 3);

%retrieve data filenames for naming images
names = cellfun(@get_name, data, 'UniformOuput', false);

%load contrast weights from stimulus file
load(fullfile(cfg.datadir, cfg.rcicS), 'img', 'sinIdx', 'sinusoids');

%visualize reversed classification images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get number of images to be generated per participant = nr of conditions
nrC = size(m_par, 2);

for p = 1 : nrP %loop over participant files
    
    if (cfg.plot)
        
        %get number of rows and columns for subplot
        nrR = round(sqrt(nrC));
        nrC = ceil(nrC / nrR);
        
        %make new figure window (span whole screen)
        figure('Name', names{p});
        set(gcf, 'Position', get(0, 'Screensize'));
    end
    
    for c = 1 : nrC %loop over conditions
        
        %retrieve condition label
        cLabel = avg_cfg.cond{c}{1};
        
        fprintf('        %s...', cLabel);
        
        %get current column of parameters
        curr_par = m_par(:, c, p);
        
        %get weighted sinusoid mixture
        sinW = mean(sinusoids .* curr_par(sinIdx), 3);
        
        %{
            TODO Check, why we scale differently here.
        %}
        %scale noise constant to 0-1
        sinW = (sinW - min(sinW(:))) / (max(sinW(:)) - min(sinW(:)));
        
        %{
            TODO Check, if we should use a mask here, too.
        %}
        %combine noise and image, then normalize image
        stim = (1 - cfg.nWeight) * img + cfg.nWeight * sinW;
        stim = norm_gsimage_lm(stim, 128, 127);
        
        %make filename for image
        fname = sprintf('%s_%s.bmp', names{p}, cLabel);
        
        %save classification image as file
        imwrite(uint8(stim), fullfile(cfg.outdir, fname), 'bmp');
        fprintf('Done!\n');
        
        if (cfg.plot)
            
            %make subplot
            subplot(nrR, nrC, c);
            
            %draw image
            image(stim);
            axis image off;
            colormap(gray(256));
            title(cLabel);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [name] = get_name(data)

%split path and keep only filename
[~, name, ~] = fileparts(data.Properties.Description);
