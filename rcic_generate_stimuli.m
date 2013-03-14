function rcic_generate_stimuli(cfg)
% function rcic_generate_stimuli(cfg)
%
% The function generates noisy image following the Mangini and Biederman
% method. Will ask the user for base face images, then generates noisy
% stimuli for each base face image and stores them in a folder also chosen
% by the user. For each stimulus, two images are generated, ones with the
% sinusoid noise added, and once with the inverted sinusoid noise added.
%
% example call: rcic_generate_stimuli([]);

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%init random number generator with current time
rng_state = rng('shuffle');

%structure with default settings
defaults = struct( ...
    'root', pwd, ...                %root directory
    'seed', rng_state.Seed, ...     %seed value for random numbers
    'genImg', true, ...             %render images?
    'nrS', 5, ...                   %number of stimuli
    'blur', false, ...              %blue the base face?
    'symm', false, ...              %generate symmetric noise images?
    'prefix', 'rcicstim', ...       %noise image name prefix
    'nWeight', .5, ...              %noise weight
    'stim_dir', 'stim' ...          %directory for generated stimuli
    );

%set defaults not defined in cfg
cfg = join_configs(defaults, cfg);

%base face to use
if ~isfield(cfg, 'bf')
    
    %ask user for base face
    [fname, fpath] = uigetfile( ...
        {'*.jpg;*.tif;*.png;*.gif;*.bmp','Image Files'}, ...
        'Pick Base Face Image', cfg.root);
    
    %user picked no image
    if (fname == 0), error('No base face picked!\n'); end
    
    %store full path to base face
    cfg.bf = fullfile(fpath, fname);
end

%base face name stem
[~, cfg.bf_name, ~] = fileparts(cfg.bf);

%mask for image
if ~isfield(cfg, 'mask')
    
    %ask user for base face
    [fname, fpath] = uigetfile( ...
        {'*.jpg;*.tif;*.png;*.gif;*.bmp','Image Files'}, ...
        'Pick Mask Image', cfg.root);
    
    %user picked no mask
    if (fname == 0), error('No mask image picked!\n'); end
        
    %store full path to mask image
    cfg.mask = fullfile(fpath, fname);
end

%some output before we start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%construct full path to stim_dir
stim_dir = fullfile(cfg.root, cfg.stim_dir);

%for translating boolean to text output
bText = {'No', 'Yes'};

%print settings
fprintf('\nGenerating RCIC images with these settings:\n');
fprintf('\tRandom number seed: %d\n', cfg.seed);
fprintf('\tWeight of noise: %f\n', cfg.nWeight);
fprintf('\tBase face: %s\n', cfg.bf);
fprintf('\tBlurring base face: %s\n', bText{cfg.blur+1});
if ischar(cfg.mask), fprintf('\tMask image: %s\n', cfg.mask); end
fprintf('\tGenerating images: %s\n', bText{cfg.genImg+1});
fprintf('\tNumber of generated noise patterns: %d\n', cfg.nrS);

if (cfg.genImg)
    fprintf('\tImage file prefix: %s\n', cfg.prefix);
    fprintf('\tGenerating symmetric images: %s\n', bText{cfg.symm+1});
    fprintf('\tStimulus directory for images: %s\n', stim_dir);
end

%ask user whether to start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~askyesno('\nProceed with these settings? [Y/N] ')
    error('Stimulus generation aborted!');
end

%get base face image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Loading base face image %s...', cfg.bf);

%load base face
img = double(imread(cfg.bf));

if (ndims(img) > 2)
    %make grayscale if necessary
    img = rgb2gray(img);
end

if (cfg.blur)
    %blur base face with kernel
    img = imfilter(img, fspecial('gaussian', 10, 10));
    fprint('blurred...');
end

%scale to range 0-1
img = (img - min(img(:))) / range(img(:));
fprintf('normalized...');

fprintf('Done!\n');

%store image size
cfg.imgS = size(img);

%get mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Getting mask...');

if ischar(cfg.mask)
    %load mask image and make logical by threshold
    mask = imread(cfg.mask) > 30;
else
    %take mask directly from input
    mask = cfg.mask;
end

fprintf('Done!\n');

%get sinusoids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generating sinusoids...');

%generate sinusoids and indices
[sinusoids, sinIdx] = rcic_make_sinusoids(cfg.imgS);

fprintf('Done!\n');

%get number of unique sinusoid parameters
nrInd = length(unique(sinIdx));

%generate random contrasts for all stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generate random contrast weights...');

%init random stream
rng(cfg.seed)

%generate needed number of random contrast values (range -1 to 1);
%columns are trials, rows are sinusoid indices
contrast = (rand(nrInd, cfg.nrS) - .5) * 2;

fprintf('Done!\n');

%save stimulus data to file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rename config to avoid confusion
gen_cfg = cfg;

%save data
save(fullfile(cfg.root, 'rcic_data.mat'), 'contrast', 'sinIdx',...
    'sinusoids', 'img', 'mask', 'gen_cfg');

%generate noise stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generating %d stimuli...', cfg.nrS);

%preallocate memory for all images
stim.img = zeros([cfg.imgS cfg.nrS], 'uint8');
stim.name = cell(cfg.nrS, 1);
stim = repmat({stim}, 2, 1);

%make waitbar
wbh = waitbar(0, 'Generating Stimuli');
drawnow;

for n = 1 : cfg.nrS %loop over number of trials
    
    %generate stimulus images with original and inverted noise
    [noisy, noisy_inv] = rcic_make_noisy_stimuli(img, contrast(:, n),...
        cfg.nWeight, sinusoids, sinIdx);
    
    %normalize images and store
    stim{1}.img(:,:,n) = norm_gsimage_lm(noisy, 128, 127, mask);
    stim{2}.img(:,:,n) = norm_gsimage_lm(noisy_inv, 128, 127, mask);
    
    %generate and store filenames
    stim{1}.name{n} = sprintf('%s_%s_%d_%03d_0.bmp', ...
        cfg.prefix, cfg.bf_name, cfg.seed, n);
    stim{2}.name{n} = sprintf('%s_%s_%d_%03d_1.bmp', ...
        cfg.prefix, cfg.bf_name, cfg.seed, n);
    
    %update waitbar
    waitbar(n / cfg.nrS, wbh);
end

%save images to rcic_data file for later export %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%remove inverse image info, if not needed
if ~(cfg.symm), stim{2} = []; end

%add stimulus image to datafile
save(fullfile(cfg.root, 'rcic_data.mat'), 'stim', '-append');

%close waitbar
close(wbh);

fprintf('Done!\n');

%write images to disk %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (cfg.genImg) 
    %export noisy stim images
    rcic_export_images(fullfile(cfg.root, 'rcic_data.mat'), stim_dir, 'stim');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stim1, stim2] = rcic_make_noisy_stimuli(img, contrast, nWeight, ...
                                                  sinusoids, indices)
% function [stim1, stim2] = rcic_make_noisy_stimuli(img, contrast,...
%                                    nWeight, sinusoids, indices)
%
% The function takes a base face image and generates stimuli with overlayed
% sinusoid noise. "sinusoids" and "indices" were generated by the function
% rcic_anx_make_sinusoids.m. nWeight is the weighting of the noise in the
% final images.

%get weighted sinusoid mixture
sinW = mean(sinusoids .* contrast(indices), 3);

%scale noise constant from -.3/.3 to 0/1
sinW = (sinW + .3) / .6;

%combine noise and image
stim1 = (1 - nWeight) * img + nWeight * sinW;

%combine inverted noise and image
stim2 = (1 - nWeight) * img + nWeight * (1 - sinW);
