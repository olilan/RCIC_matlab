function rcic_generate_stimuli(cfg)
% function rcic_generate_stimuli(cfg)
%
% The function generates noisy image following the Mangini and Biederman
% method. Will ask the user for base face images, then generates noisy
% stimuli for each base face image and stores them in a folder also chosen
% by the user. For each stimulus, two images are generated, ones with the
% sinusoid noise added, and once with the inverted sinusoid noise added.
%
% TODO Change description of cfg parameters
% Input:
%        nrS          number of stimuli to generate for each base face
%        blur         should we blur base face?
%        symm         when true, will generate negative images in addition to
%                     originals
%        seed         seed value used by random generator for making the
%                     random sinusoid contrasts
%        prefix       prefix for stimulus names
%
% example call: rcic_generate_stimuli([]);

%should we import settings and data from existing dataset? %%%%%%%%%%%%%%%%%%%

%first, check whether we got a root directory
if ~isfield(cfg, 'root'), cfg.root = pwd; end

%can we load settings from file?
if isfield(cfg, 'rcicS')
    
    fprintf('Loading settings and data from RCIC file %s...',...
        fullfile(cfg.root, cfg.rcicS));
    
    %load all data from file
    load(fullfile(cfg.root, cfg.rcicS));
    
    fprintf('Done!\');
end

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%random number generator seed
if ~isfield(cfg, 'seed')
    
    %init by current time
    rng('shuffle');
    
    %read current start state after init and store seed
    s = rng;
    cfg.seed = s.Seed;
end

%should we generate images?
if ~isfield(cfg, 'genImg'), cfg.genImg = true; end

%number of stimuli to generate
if cfg.genImg && ~isfield(cfg, 'nrS'), cfg.nrS = 5; end

%should we blur base face?
if ~isfield(cfg, 'blur'), cfg.blur = false; end

%should we generate also images with negative noise?
if ~isfield(cfg, 'symm'), cfg.symm = false; end

%prefix for stimulus names
if ~isfield(cfg, 'prefix'), cfg.prefix = 'rcicstim'; end

%noise weight
if ~isfield(cfg, 'nWeight'), cfg.nWeight = .5; end

%base face to use
if ~isfield(cfg, 'bf')
    
    %ask user for base face
    [bname, bpath] = uigetfile('*.jpg', 'Pick Base Face Image');
    
    if (bname == 0) %user picked no image
        fprintf('No base face picked!\n');
        return
    else
        %store full path to base face
        cfg.bf = fullfile(bpath, bname);
        
    end
end

%base face name
if ~isfield(cfg, 'bf_name')
    %store name stem
    [~, cfg.bf_name, ~] = fileparts(cfg.bf);
end

%mask for image
if ~isfield(cfg, 'mask')
    
    %ask user for base face
    [mname, mpath] = uigetfile('*.jpg', 'Pick Mask Image');
    
    if (mname == 0) %user picked no mask
        fprintf('No mask image picked!\n');
        return
    else
        cfg.mask = fullfile(mpath, mname);
    end
end

%target directory
if ~isfield(cfg, 'targdir')
    
    %get target directory
    cfg.targdir = uigetdir(pwd, 'Pick stimulus directory');
    
    if (cfg.targdir == 0)
        fprintf('No target directory picked!\n');
        return
    end
end

%some output before we start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
if cfg.genImg
    fprintf('\tImage file prefix: %s\n', cfg.prefix);
    fprintf('\tGenerating symmetric images: %s\n', bText{cfg.symm+1});
    fprintf('\tTarget directory for images: %s\n', cfg.targdir);
end

%ask user whether to start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%init reply variable
reply = '';

while ~ismember(reply, {'Y','N','YES','NO'})
    %ask user whether to proceed
    reply = upper(input('\nProceed with these settings? [Y/N]', 's'));
end

if ismember(reply, {'N','NO'})
    fprintf('Stimulus generation aborted!\n');
    return
end

%get base face image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Loading base face image %s...', cfg.bf);

%load base face
img = imread(cfg.bf, 'jpg');

if (size(img, 3) > 1) %color image?
    
    fprintf('grayscaling...');
    
    %make grayscale if necessary
    img = rgb2gray(img);
end

%change to double
img = double(img);

if (cfg.blur)
    
    fprint('blurring...');
    
    %make kernel for image blurring
    kernel = fspecial('gaussian', 10, 10);
    
    %blur base face
    img = imfilter(img, kernel);
end

fprintf('normalizing...');

%scale to range 0-1
img = (img - min(img(:))) / (max(img(:)) - min(img(:)));

fprintf('Done!\n');

%store image size
cfg.imgS = size(img);

%get mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Getting mask...');

if ~(cfg.mask) %mask set to False by user
    
    %mask is whole image
    mask = true(cfg.imgS);

elseif ischar(cfg.mask) %mask filename
    
    %load mask image
    mask = imread(cfg.mask, 'jpg');
    %???mask = mask > 30;

else
    %take mask directly from input
    mask = cfg.mask;
end

fprintf('Done!\n');

%get sinusoids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('sinusoids', 'var') || ~exist('sinIdx', 'var')
    
    fprintf('Generating sinusoids...');
    
    %generate sinusoids and indices
    [sinusoids, sinIdx] = rcic_make_sinusoids(cfg.imgS);
    
    fprintf('Done!\n');
end

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
save(fullfile(cfg.targdir, 'rcic_stimuli.mat'), 'contrast', 'sinIdx',...
    'sinusoids', 'img', 'mask', 'gen_cfg');

%generate noise stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (cfg.genImg)
    
    fprintf('Generating %d stimuli...', cfg.nrS);
    
    %make waitbar
    wbh = waitbar(0, 'Generating Stimuli');
    drawnow;
    
    for n = 1 : cfg.nrS %loop over number of trials
        
        %generate stimulus images with original and inverted noise
        [noisy, noisy_inv] = rcic_make_noisy_stimuli(img, contrast(:, n),...
            cfg.nWeight, sinusoids, sinIdx);
        
        %make filename for noisy image
        fname = sprintf('%s_%s_%d_%03d_0.bmp',...
            cfg.prefix, cfg.bf_name, cfg.seed, n);
        
        %normalize and write noisy image
        noisy = norm_gsimage_lm(noisy, 128, 127, mask);
        imwrite(uint8(noisy), fullfile(cfg.targdir, fname), 'bmp');
        
        if (cfg.symm) %we also want to save the inv version
            
            %make filename for noisy_inv image
            fname = sprintf('%s_%s_%d_%03d_1.bmp',...
                cfg.prefix, cfg.bf_name, cfg.seed, n);
            
            %normalize and write invert image
            noisy_inv = norm_gsimage_lm(noisy_inv, 128, 127, mask);
            imwrite(uint8(noisy_inv), fullfile(cfg.targdir, fname), 'bmp');
        end
        
        %update waitbar
        waitbar(n / cfg.nrS, wbh);
    end
    
    %close waitbar
    close(wbh);
    
    fprintf('Done!\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stim1, stim2] = rcic_make_noisy_stimuli(img, contrast,...
    nWeight, sinusoids, indices)
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
