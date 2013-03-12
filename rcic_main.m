%Change and store this setting file for each experiment.

%% image generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make config settings for image generation
gen_cfg = struct( ...
    'genImg', True, ...             %render images
    'bf', 'rafd_average.jpg', ...   %base face image
    'blur', False, ...              %don't blur base face
    'symm', True, ...               %generate also inverse image
    'prefix', 'teststim', ...       %name prefix for images
    'nrS', 5, ...                   %number of stimuli
    'mask', [] ...                  %no masking of stimuli
    );

%uncomment next line and place needed seed, in case you need to recreate
%images from a known state of the random generator
%gen_cfg.seed = 123;

%generate stimuli
rcic_generate_stimuli(gen_cfg);

%% data analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make config settings for data analysis
avg_cfg = struct( ...
    'datadir', pwd, ...             %path to data directory
    'stim_col', {'stimNr'}, ...     %column name of stimulus number column
    
    );

%import data to matlab
rcic_import_data(avg_cfg);