function rcic_visualize_participant_images(cfg)
% function rcic_visualize_participant_images(cfg)
%
% The function takes the results from the function
% rcic_calc_participant_contrasts and visualizes the normalized
% average noise per condition superimposed on the base face used in the
% experiment.
% 
% ex.call: rcic_visualize_participant_images(cfg);
%
% ----------------------------------------------------------------------------
% Copyright (C) 2013, Oliver Langner and Ron Dotsch
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the Eclipse Public License as published by
% the Eclipse Foundation, version 1.0.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% Eclipse Public License for more details.
%
% You should have received a copy of the Eclipse Public License
% along with this program.  If not, see
% http://www.eclipse.org/legal/epl-v10.html
% ----------------------------------------------------------------------------

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
    'm_par', 'avg_cfg', 'datafiles', 'img', 'sinIdx', 'sinusoids');

%get number of conditions and participants
[~, nrC, nrP] = size(m_par);

%visualize reversed classification images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get condition labels
cLabel = cellfun(@(x) x{1}, avg_cfg.cond, 'UniformOutput', false);

%preallocate memory for CIs
CIs.img = zeros([size(img) nrP], 'uint8');
CIs.name = cell(nrP, 1);
CIs = repmat({CIs}, nrC, 1);

for p = 1 : nrP %loop over participant files
    for c = 1 : nrC %loop over conditions
        
        %get current column of parameters
        curr_par = m_par(:, c, p);
        
        %get weighted sinusoid mixture
        sinW = mean(sinusoids .* curr_par(sinIdx), 3);
        
        %scale noise constant to 0-1
        sinW = (sinW - min(sinW(:))) / (max(sinW(:)) - min(sinW(:)));
        
        %combine noise and image to CI, then normalize CI
        ci = (1 - cfg.nWeight) * img + cfg.nWeight * sinW;
        CIs{c}.img(:,:,p) = norm_gsimage_lm(ci, 128, 127);
        
        %get datafile name for CI naming
        [~, dataname, ~] = fileparts(datafiles{p});
        
        %make filename for image
        CIs{c}.name{p} = sprintf('CI_%s_%s.bmp', dataname, cLabel{c});
    end
end

%store data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rename cfg to avoid conflicts
vis_cfg = cfg;

%store data
save(fullfile(cfg.root, 'rcic_data.mat'), 'vis_cfg', 'CIs', '-append');

%write CIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get full path to CI_dir
CI_dir = fullfile(cfg.root, cfg.CI_dir);

%export CIs
rcic_export_images(fullfile(cfg.root, 'rcic_data.mat'), CI_dir, 'CIs');

%display plot of CIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (cfg.plot)
    
    %get number of rows and columns for subplot
    spR = round(sqrt(nrC));
    spC = ceil(nrC / spR);
    
    for p = 1 : nrP
        
        %make new figure window (span whole screen)
        figure('Name', datafiles{p});
        set(gcf, 'Position', get(0, 'Screensize'));
        
        for c = 1 : nrC
            
            %make subplot
            subplot(spR, spC, c);
            
            %draw image
            image(CIs{c}.img(:,:,p));
            axis image off;
            colormap(gray(256));
            title(cLabel{c});
        end
    end
end
