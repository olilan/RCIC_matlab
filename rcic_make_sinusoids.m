function [sinusoids, sinIdx, cfg] = rcic_make_sinusoids(img_s, varargin)
% function [sinusoids, sinIdx, cfg] = rcic_make_sinusoids(img_s)
%
% The function generates a big array of sinusoids with different cycles,
% orientations and phases. Furhter, it generates a matrix of the same size
% with indexing number for each individual sinusoid pattern.
%
% ex.call: [sinusoids, sinIdx, sin_cfg] = rcic_make_sinusoids([512 512]);

%settings for sinusoid generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check, if we got configs
if ~isempty(varargin)
    cfg = varargin{1};
else
    cfg = struct();
end

%define defaults for configs
defaults = struct( ...
    'patches', [1 2 4 8 16], ...        %nr of patches in x- and y-direction
    'cycles', 2, ...                    %cycles of sinusoids per patch
    'ori', [0 30 60 90 120 150], ...    %sinusoid orientations
    'phases', [0 pi/2] ...              %sinusoid phases
    );

%set defaults not defined in cfg
cfg = join_configs(defaults, cfg);

%set type info, in case we support multiple noises
cfg.type = 'sinusoid';

%prepare data for sinusoids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%size of patches per patch-level
[junk{1}, junk{2}] = meshgrid(img_s, cfg.patches);
sinSize = junk{1} ./ junk{2};

%number of sinusoid images
nrSin = length(cfg.patches) * length(cfg.ori) * length(cfg.phases);

%preallocate memory for sinusoid and contrast indexing
sinusoids = zeros([img_s nrSin]);
sinIdx = zeros([img_s nrSin]);

%global counters
co = 1; %sinusoid layer counter
idx = 1; %contrast index counter

for p = 1 : length(cfg.patches) %loop over patches
    for o = 1 : length(cfg.ori) %loop over orientations
        for ph = 1 : length(cfg.phases) %loop over phases
            
            %make sinusoid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %create sinusoid
            s = gen_sinusoid(sinSize(p, :), cfg.cycles, cfg.ori(o), ...
                cfg.phases(ph), 1);
            
            %repeat sinusoid to fill image
            sinusoids(:, :, co) = repmat(s, cfg.patches(p));
            
            %create index matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for col = 1 : cfg.patches(p)
                for row = 1 : cfg.patches(p)
                    
                    %make vertical index
                    vert = sinSize(p,1) * (row-1) + 1 : sinSize(p,1) * row;
                    
                    %make horizontal index
                    horz = sinSize(p,2) * (col-1) + 1 : sinSize(p,2) * col;
                    
                    %insert absolute index for later contrast weighting
                    sinIdx(vert, horz, co) = idx;
                    
                    %increase index counter
                    idx = idx + 1;
                end
            end
            
            %increase sinusoid layer counter
            co = co + 1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [img] = gen_sinusoid(img_size, cyc, ang, ph, contrast)
% function [img] = gen_sinusoid(img_size, cyc, ang, ph)
%
% Generates an image containing a sinusoid. Needed factors are:
%
%     img_size     2 element vector containing height and width of resulting
%                  image
%     cyc          number of sinusoid cycles in the image
%     ang          angle of the sinusoid in degrees, 0 gives vertical, 90
%                  horizontal oriented sinusoids
%     ph           phase offset of the sinusoid
%
% ex.call.: [img] = gen_sinusoid([256 256], 3, 45, pi);

%make matrix containing vertical component
vert = repmat(linspace(0, cyc, img_size(1))', 1, img_size(2));

%make matrix containing horizontal component
horz = repmat(linspace(0, cyc, img_size(2)), img_size(1), 1);

%combine horizontal and vertical component and calculate sinusoid
img = (horz*cosd(ang) + vert*sind(ang)) * 2 * pi;
img = contrast * sin(img + ph);
