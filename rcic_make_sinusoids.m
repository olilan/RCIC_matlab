function [sinusoids, sinIdx] = rcic_make_sinusoids(img_s)
% function [sinusoids, sinIdx] = rcic_make_sinusoids(img_s)
%
% The function generates a big array of sinusoids with different cycles,
% orientations and phases. Furhter, it generates a matrix of the same size
% with indexing number for each individual sinusoid pattern.
%
% ex.call: [sinusoids, sinIdx] = rcic_make_sinusoids([512 512]);

%settings for sinusoid generation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%sinusoid cycles
cycles = [1 2 4 8 16]';

%sinusoid orientations
ori = [0 30 60 90 120 150]';

%sinusoid phases
phases = [0 pi/2]';

%size of sinusoids per cycle
[junk{1}, junk{2}] = meshgrid(img_s, cycles);
sinSize = junk{1} ./ junk{2};

%number of sinusoid images
nrSin = length(cycles) * length(ori) * length(phases);

%preallocate memory for sinusoid and contrast indexing
sinusoids = zeros(img_s(1), img_s(2), nrSin);
sinIdx = zeros(img_s(1), img_s(2), nrSin);

%global counters
co = 1; %sinusoid layer counter
idx = 1; %contrast index counter

for c = 1 : length(cycles) %loop over cycles
    for o = 1 : length(ori) %loop over orientations
        for p = 1 : length(phases) %loop over phases
            
            %make sinusoid %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %create sinusoid
            s = gen_sinusoid(sinSize(c, :), 2, ori(o), phases(p), 1);
            
            %repeat sinusoid to fill image
            sinusoids(:, :, co) = repmat(s, [cycles(c) cycles(c)]);
            
            %create index matrix %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            for col = 1 : cycles(c)
                for row = 1 : cycles(c)
                    
                    %make vertical index
                    vert = sinSize(c,1) * (row-1) + 1 : sinSize(c,1) * row;
                    
                    %make horizontal index
                    horz = sinSize(c,2) * (col-1) + 1 : sinSize(c,2) * col;
                    
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
