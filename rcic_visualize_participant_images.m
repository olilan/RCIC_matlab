function rcic_visualize_participant_images(data_dir, plotflag, varargin)
% function rcic_visualize_participant_images(data_dir, plotflag, ['all'])
%
% The function takes the results from the function
% rcic_calc_participant_contrasts and visualizes the normalized
% average noise per condition superimposed on the base face used in the
% experiment.
% 
% Copyright: Oliver Langner, September 2010, adapted by Ron Dotsch

%basic settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%noise weight in rcic image
nWeight = .5;

%get data files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ((~isempty(varargin)) && strcmp(varargin{1}, 'all'))
    
    %get names of all participant files
    fname = dir(fullfile(data_dir, 'rcdata*.mat'));
    fname = {fname.name};

else
    
    %let user choose the files to import
    [fname, data_dir] = uigetfile(fullfile(data_dir, 'rcdata*.mat'),...
        'Pick data files!', 'MultiSelect', 'on');
    
    %make sure, fname is a cellstr
    if (ischar(fname)), fname = cellstr(fname); end
end

%get image info of stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%try to find stimulus file here
stim_dir = data_dir;
stim_file = 'rcic_stimuli.mat';

%check, if standard stimulus file is there
if ~exist(fullfile(stim_dir, stim_file), 'file')
    
    %let user choose stimulus file
    [stim_file, stim_dir] = uigetfile(...
        fullfile(data_dir, 'rcic_stimuli.mat'), 'Pick stimulus file!');
    
    %check, if we got a char
    if (ischar(stim_file)), stim_file = cellstr(stim_file); end
end

%load image of base face, sinusoid indices and sinusoids
img = struct2array(load(fullfile(stim_dir, stim_file), 'img'));
sinIdx = struct2array(load(fullfile(stim_dir, stim_file), 'sinIdx'));
sinusoids = struct2array(load(fullfile(stim_dir, stim_file), 'sinusoids'));

%visualize reversed classification images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f = 1 : length(fname) %loop over participant files
    
    fprintf('Generating classification images for file %s...\n', fname{f});
    
    %load mean parameter data
    m_par = struct2array(load(fullfile(data_dir, fname{f}), 'm_par'));
    m_par_descr = struct2array(load(fullfile(data_dir, fname{f}),...
        'm_par_descr'));
    
    %get number of images
    nrI = size(m_par, 2);
    
    if (plotflag)
        
        %get number of rows and columns for subplot
        nrR = round(sqrt(nrI));
        nrC = ceil(nrI / nrR);
        
        %make new figure window
        figure('Name', fname{f});
        set(gcf, 'Position', get(0, 'Screensize'));
    end
    
    for s = 1 : nrI %loop over images
        
        fprintf('        %s...', m_par_descr{s});
        
        %get current column of parameters
        curr_par = m_par(:, s);
        
        %get weighted sinusoid mixture
        sinW = mean(sinusoids .* curr_par(sinIdx), 3);
        
        %scale noise constant to 0-1
        sinW = (sinW - min(sinW(:))) / (max(sinW(:)) - min(sinW(:)));
        
        %combine noise and image, then normalize image
        stim1 = (1 - nWeight) * img + nWeight * sinW;
        stim1 = norm_gsimage_lm(stim1, 128, 127);
        
        %make filename for image
        ci_name = sprintf('%s_%s.bmp',...
            strtok(fname{f}, '.'),...
            m_par_descr{s});
        
        %save classification image as file
        imwrite(uint8(stim1), ci_name, 'bmp');
        fprintf('Done!\n');
        
        if (plotflag)
            
            %make subplot
            subplot(nrR, nrC, s);
            
            %draw image
            image(stim1);
            axis image off;
            colormap(gray(256));
            title(m_par_descr{s});
        end
    end
end