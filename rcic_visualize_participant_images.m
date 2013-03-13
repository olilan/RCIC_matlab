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

%structure with default settings
defaults = struct( ...
    'root', pwd, ...            %root directory
    'nWeight', .5, ...          %weight of sinusoids in CIs
    'CI_dir', 'CIs', ...        %directory for CI export
    'plot', false ...           %want to see plots also?
    );

%set defaults not defined in cfg
cfg = join_configs(defaults, cfg);

%load needed data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load needed data
load(fullfile(cfg.root, 'rcic_data.mat'), ...
    'm_par', 'avg_cfg', 'data', 'img', 'sinIdx', 'sinusoids');

%get number of conditions and participants
[~, nrC, nrP] = size(m_par);

%retrieve data filenames for naming classification images
names = cellfun(@get_name, data, 'UniformOutput', false);

%visualize reversed classification images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get full path to CI_dir
CI_dir = fullfile(cfg.root, cfg.CI_dir);

%check, if CI_dir exists
if ~exist(CI_dir, 'dir'), mkdir(CI_dir); end

for p = 1 : nrP %loop over participant files
    
    if (cfg.plot)
        
        %get number of rows and columns for subplot
        spR = round(sqrt(nrC));
        spC = ceil(nrC / spR);
        
        %make new figure window (span whole screen)
        figure('Name', names{p});
        set(gcf, 'Position', get(0, 'Screensize'));
    end
    
    for c = 1 : nrC %loop over conditions
        
        %retrieve condition label
        cLabel = avg_cfg.cond{c}{1};
        
        %get current column of parameters
        curr_par = m_par(:, c, p);
        
        %get weighted sinusoid mixture
        sinW = mean(sinusoids .* curr_par(sinIdx), 3);
        
        %scale noise constant to 0-1
        sinW = (sinW - min(sinW(:))) / range(sinW(:));
        
        %combine noise and image to CI, then normalize CI
        CI = (1 - cfg.nWeight) * img + cfg.nWeight * sinW;
        CI = norm_gsimage_lm(CI, 128, 127);
        
        %make filename for image
        fname = sprintf('CI_%s_%s.bmp', names{p}, cLabel);
        
        %save classification image as file
        imwrite(uint8(CI), fullfile(CI_dir, fname), 'bmp');
        
        if (cfg.plot)
            %make subplot
            subplot(spR, spC, c);
            
            %draw image
            image(CI);
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
