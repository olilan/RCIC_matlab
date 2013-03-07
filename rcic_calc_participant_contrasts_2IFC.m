function rcic_calc_participant_contrasts_2IFC(data_dir, varargin)
% function rcic_calc_participant_contrasts_2IFC(data_dir, ['all'])
%
% The function calculates the average weighting parameters for different
% repsonse keys or response key combinations. Assumes that when the original
% stimulus was not selected, the negative was selected.
%
% Copyright: Oliver Langner June 2010, adapted by Ron Dotsch

%basic settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%list of response keys to use per image
cond = {
    1
};

% array matching cond, which indicates which response key was complimentary to
% the response key in cond (i.e., indicated the negative/inverse) 
complement = {
    2
};

%description of m_par columns
m_par_descr = {
    'ci'
};

%get data files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ((~isempty(varargin)) && strcmp(varargin{1}, 'all'))
    
    %get names of all participant files
    fname = dir(fullfile(data_dir, 'rcdata*.mat'));
    fname = {fname.name};

else
    
    %let user choose the files to import
    [fname, data_dir] = uigetfile(fullfile(data_dir, '*.mat'),...
        'Please select data files...', 'MultiSelect', 'on');
    
    %make sure, fname is a cellstr
    if (ischar(fname)), fname = cellstr(fname); end
end

fprintf('Going to calculate contrast means for %d files.\n', length(fname));

%get contrast weights of stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%try to find stimulus file here
stim_dir = data_dir;
stim_file = 'rcic_stimuli.mat';

%check, if standard stimulus file is there
if ~exist(fullfile(stim_dir, stim_file), 'file')
    
    %let user choose stimulus file
    [stim_file, stim_dir] = uigetfile(...
        fullfile(data_dir, 'rcic_stimuli.mat'), 'Pick stimulus file!');
end
    
%load contrast weights
contrast = struct2array(load(fullfile(stim_dir, stim_file), 'contrast'));

%calculate mean contrast weights %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for f = 1 : length(fname) %loop over data files
    
    fprintf('Calculating mean parameters for file %s...', fname{f});
    
    %load data from participant file
    data = struct2array(load(fullfile(data_dir, fname{f}), 'data'));
    
    %container for mean parameters
    m_par = zeros(size(contrast, 1), length(cond));
    
    for c = 1 : length(cond) %loop over conditions
        
        %get index of trials matching condition
        idx = find_matching_trials(data.response_r, cond{c});
        
        %get index of trials matching complement
        idx_c = find_matching_trials(data.response_r, complement{c});
        
        %calculate mean parameters
        m_par(:, c) = mean([contrast(:, idx), -contrast(:, idx_c)], 2);
    end
    
    %save mean parameters to file
    save(fullfile(data_dir, fname{f}), 'm_par', 'm_par_descr', '-append');
    fprintf('Done!\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [idx] = find_matching_trials(data, resp)

%make container for logical vectors
lv = false(size(data, 1), length(resp));

for r = 1 : length(resp)
    
    %find entries matching response
    lv(:, r) = (data == resp(r));
end

%find all data entries matching any of the responses
idx = logical(sum(lv, 2));