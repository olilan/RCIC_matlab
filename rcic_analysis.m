
% Reverse correlation analysis script by Ron Dotsch and Oliver Langner
%
% Based on Dotsch, Wigboldus, Langner, & van Knippenberg (2008)
%
% Copyright: Oliver Langner, 2010, adapted by Ron Dotsch (2011)

%% Settings

% Path and filename to files containing data (one participant per file) 
data_dir = '../Data';

% Number of stimuli used (only important if stimulus file doesn't exist)
nStimuli = 770;

% Base image used (only important if stimulus file doesn't exist)
base = 'rafd_average.jpg';

%% Import data (files saves files as .mat)
rcic_import_data(data_dir);

%% Create stimuli file if it doesn't exist (optional)
% Run this only if you did not create a stimulus file during stimulus
% generation.
rcic_create_stimuli_file(data_dir, nStimuli, base);

%% Do this for one stimulus per trial (1 Image Multiple Response Alternatives Forced Choice)
%Calculate mean parameters (contrasts) for each participant
rcic_calc_participant_contrasts(data_dir, 'all');

%% Do this for two stimuli per trial (2 Images Forced Choice)
% Calculate mean parameters (contrasts) for each participant
rcic_calc_participant_contrasts_2IFC(data_dir, 'all');

%% Visualize participant CI's 
rcic_visualize_participant_images(data_dir, 0);
 