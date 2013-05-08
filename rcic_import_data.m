function rcic_import_data(cfg)
% function rcic_import_data(cfg)
%
% The function imports data, but should be customized by user depending on
% output data format. Let's user choose which files to import.
%
% ex.call: rcic_import_data(cfg);
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
    
    %store file source
    data{f}.file = datafiles{f};
    
    %get header and data
    [data{f}.data, data{f}.header] = load_csv(datafiles{f}, cfg.delim);
    
    %update waitbar
    waitbar(f / length(fname), wbh);
end

%close waitbar
close(wbh);

fprintf('Done!\n');

%simple data check %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get number of trials for each dataset
tmp = cellfun(@(x) size(x.data, 1), data);

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [D, header] = load_csv(fname, delim)
% function [D, header] = load_csv(fname, delim)
%
% Function for importing csv-data with mixed data types (strings, numbers).

%open file
fid = fopen(fname, 'r');

%read first line
fl = textscan(fid, '%s', 1);

%get number of columns
nrC = length(strfind(fl{1}{1}, delim)) + 1;

%make format string
format = repmat('%s', 1, nrC);

%rescan header
header = textscan(fl{1}{1}, format, 'Delimiter', delim);
header = cat(2, header{:});

%read all data and concatenate to one cell array
D = textscan(fid, format, 'Delimiter', delim);
D = cat(2, D{:});

%close file after reading
fclose(fid);

%find numeric columns
idx = ~isnan(cellfun(@(x) str2double(x), D(1,:)));

%convert numeric columns
D(:, idx) = num2cell(cellfun(@(x) str2double(x), D(:, idx)));
