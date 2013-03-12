function rcic_import_data(cfg)
% function rcic_import_data(cfg)
%
% The function imports data, but should be customized by user depending on
% output data format. Let's user choose which files to import.
%
% Based on Dotsch, Wigboldus, Langner, & van Knippenberg (2008)
%
% Copyright: Oliver Langner, 2010, adapted by Ron Dotsch

%check configuration parameters and set defaults %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%data directory
if ~isfield(cfg, 'datadir'), cfg.datadir = pwd; end

%stimulus column
if ~isfield(cfg, 'stim_col'), cfg.stim_col = 'stimulusnumber2'; end

%delimiter for csv file
if ~isfield(cfg, 'delim'), cfg.delim = ','; end

%let user choose the files to import %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fname, cfg.datadir] = uigetfile(fullfile(cfg.datadir, '*.csv'), ...
    'Select csv files to import', 'MultiSelect', 'on');

%import files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Importing data files...');

%prepare container for datasets
data = cell(length(fname), 1);

%show waitbar
wbh = waitbar(0, 'Importing data');
drawnow;

for f = 1 : length(fname) %loop over data files
    
    %read csv file with header
    data{f} = dataset('File', fullfile(fpath, fname{f}), ...
        'delimiter', cfg.delim);
    
    %add file source
    data{f}.Properties.Description = fullfile(fpath, fname{f});
    
    %sort in order of stimulus sequence number
    data{f} = sortrows(data{f}, cfg.stim_col);
    
    %update waitbar
    waitbar(f / length(fname), wbh);
end

%close waitbar
close(wbh);

fprintf('Done!\n');

%simple data check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get number of trials for each dataset
tmp = cellfun(@length, data);

if ~(all(tmp == tmp(1)))
    fprintf('Not all datasets have the same number of trials!\n');
end

%save data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving data to %s...', fullfile(cfg.datadir, 'rcic_data.mat'));

%rename cfg to prevent overwriting
import_cfg = cfg;

%save data
save(fullfile(cfg.datadir, 'rcic_data.mat'), 'data', 'import_cfg');

fprintf('Done!\n');
