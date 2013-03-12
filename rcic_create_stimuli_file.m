function rcic_create_stimuli_file(nrS, blur, seed)
% function rcic_generate_stimuli(nrS, blur, seed)
%
% Run this only if you did not create a stimulus file during stimulus
% generation. The function only creates a stimulus file, but does not actually
% render or save the noisy stimuli.
%
% Input:
%        nrS          number of stimuli to generate for each base face
%        blur         should we blur base face?
%        seed         seed value used by random generator for making the
%                     random sinusoid contrasts
%
% example call: rcic_create_stimuli_file(100, 0, 100477);

%check seed input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Using seed: %i\n', seed);

%get sinusoids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%generate sinusoids and indices
[sinusoids, indices] = rcic_make_sinusoids([512 512]);

%get number of unique sinusoid parameters
nrInd = length(unique(indices));

%get base face image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make kernel for image blurring
kernel = fspecial('gaussian', 10, 10);

%ask user for base face
[bname, bpath] = uigetfile(...
    '*.jpg',...
    'Pick Base Face Image');

fprintf('Loading base face image...');

%load base face
bf = imread(fullfile(bpath, bname), 'jpg');

%make grayscale if necessary
if (size(bf, 3) > 1), bf = rgb2gray(bf); end

%change to double
bf = double(bf)

if (blur)
    %blur base face
    bf = imfilter(bf, kernel);
end

%scale to range 0-1
bf = (bf - min(bf(:))) / (max(bf(:)) - min(bf(:)));

fprintf('Done!\n');

%get mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ask user for base face
[mname, mpath] = uigetfile(...
    '*.jpg',...
    'Pick Mask Image');

if (mname == 0) %user picked no mask
    
    %mask is whole image
    mask = true(512);
    
else
    
    %load mask image
    mask = imread(fullfile(mpath, mname), 'jpg');
    %???
    mask = mask > 30;
end

%generate random contrasts for all stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generate random contrast weights...');

%start random stream
rstr = RandStream.create('mt19937ar', 'seed', seed);
RandStream.setDefaultStream(rstr);

%generate needed number of random contrast values (range -1 to 1); columns
%are trials, rows are sinusoid indices
contrast = (rand(nrInd, nrS) - .5) * 2;

fprintf('Done!\n');

%save stimulus data to file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get target directory
targdir = uigetdir(bpath, 'Pick stimulus directory');

% rename vars to match analysis
sinIdx = indices;
img = bf;

%save data
save(fullfile(targdir, 'rcic_stimuli.mat'), 'contrast', 'sinIdx',...
    'sinusoids', 'img', 'mask');
