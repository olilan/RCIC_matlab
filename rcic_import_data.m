function rcic_import_data(start_dir)
% function rcic_import_data(start_dir)
%
% The function imports data, but should be customized by user depending on
% output data format. Let's user choose which files to import.
%
% Based on Dotsch, Wigboldus, Langner, & van Knippenberg (2008)
%
% Copyright: Oliver Langner, 2010, adapted by Ron Dotsch
% 

% Response keys used (string or numeric, should match class of response 
% column in data file)
keys = {44, 53};

%let user choose the files to import
[fname, path] = uigetfile(fullfile(start_dir, '*.csv'),...
    'Select csv files to import', 'MultiSelect', 'on');

fprintf('Going to import %d files.\n', length(fname));

for f = 1 : length(fname) %loop over picked files
    
    fprintf('Importing file %s...', fname{f});
    
    %{
        TODO remove the need of statistics toolbox
    %}
    %Read csv file with header
    data = dataset('File', fullfile(start_dir, fname{f}), 'delimiter', ','); 
    
    % Recode responses
    data.response_r = zeros(length(data.response), 1);
    
    %Sort in order of stimulus sequence number
    data = sortrows(data, {'stimulusnumber2'});
    
        for k = 1 : length(keys)
            
            if strcmp(class(data.response), 'double') 
                
                %Get index of trials matching key (numeric version)
                idx = data.response == keys{k};
            
            else
                
                %Get index of trials matching key (string version)
                idx = strcmp(data.response, keys{k});
            end
            
            %Recode found trials to number consistent with index in keys array
            data.response_r(idx) = k;
        end
    
    %Get rid of file ending for saving as mat file
    mname = fname{f}(1 : end - 4);
    
    %Save data in file
    save(fullfile(path, mname), 'data');
    fprintf('Saved!\n');
end