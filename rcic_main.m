%Change and store this setting file for each experiment.

%% image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make config settings for image generation
gen_cfg = struct( ...
    'root', pwd, ...                %root directory
    'genImg', true, ...             %render images
    'bf', fullfile(pwd,'rafd_average.jpg'), ...   %base face image
    'blur', false, ...              %don't blur base face
    'symm', true, ...               %generate also inverse image
    'prefix', 'teststim', ...       %name prefix for images
    'nrS', 5, ...                   %number of stimuli
    'mask', [] ...                  %no masking of stimuli
    );

%uncomment next line and place needed seed, in case you need to recreate
%images from a known state of the random generator
%gen_cfg.seed = 123;

%generate stimuli
rcic_generate_stimuli(gen_cfg);

%% image generation from existing data file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make settings fro image generation
gen_from_file_cfg = struct( ...
    'root', pwd, ...                %root directory
    'rcicS', 'rcic_stimuli.mat' ... %name of rcic stimulus file
    );

%generate stimuli
rcic_generate_stimuli(gen_from_file_cfg);

%% import behavioral data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make config settings for importing data
import_cfg = struct( ...
    'datadir', pwd, ...             %path to data directory
    'stim_col', 'stimNr' ...        %column name of stimulus number column
    );

%import data to matlab and store in file rcic_data.mat
rcic_import_data(import_cfg);

%% calculate average contrast for participants %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make config settings for calculating averages
avg_cfg = struct( ...
    'datadir', pwd, ...             %path to data directory
    'resp_col', 'resp' ...          %name of response column in datasets
    );

%conditions to calculate averages for; each row is one average; first column
%is condition name, second and third are cell arrays of all responses
%defining one condition
avg_cfg.cond = { ...
    {'Condition1', {1,2}} ...
    {'Condition2', {3,4}} ...
    {'DiffCI', {1,2}, {3,4}}
};

%calculate average contrasts
rcic_calc_average_contrasts(avg_cfg);

%% generate visualizations of CIs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vis_cfg = struct( ...
    'datadir', pwd, ...             %path to data directory
    'plot', true ...                %do you want to see plots?
    );

%export CIs
rcic_visualize_participant_images(vis_cfg);
