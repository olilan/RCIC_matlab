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

%structure with default settings
defaults = struct( ...
    'root', pwd, ...                %root directory
    'data_dir', 'data', ...         %directory containing data
    'delim', ',' ...                %data colum delimiter
    );

%set defaults not defined in cfg
cfg = join_configs(defaults, cfg);

%let user choose the files to import %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%show dialog for choosing data files
[fname, cfg.data_dir] = uigetfile({'*.csv','CSV Files'}, ...
    'Select data files to import', fullfile(cfg.root, cfg.data_dir), ...
    'MultiSelect', 'on');

%check, if cancelled
if isequal(fname, 0), error('No data files picked!'); end

%make sure, fname is cellarray
fname = cellstr(fname);

%keep record of full datafile paths
datafiles = cellfun(@(x) fullfile(cfg.data_dir, x), fname,...
    'UniformOutput', false);

%import files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Importing data files...');

%prepare container for datasets
data = cell(length(fname), 1);

%show waitbar
wbh = waitbar(0, 'Importing data');
drawnow;

for f = 1 : length(datafiles) %loop over data files
    
    %read csv file with header
    data{f} = dataset('File', datafiles{f}, 'delimiter', cfg.delim);
    
    %add file source
    data{f}.Properties.Description = datafiles{f};
    
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

fprintf('Adding data to rcic_data.mat...');

%rename cfg to prevent overwriting
import_cfg = cfg;

%save data
save(fullfile(cfg.root, 'rcic_data.mat'), ...
    'datafiles', 'data', 'import_cfg', '-append');

fprintf('Done!\n');
