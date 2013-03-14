function rcic_export_images(datafile, img_dir, img_array)

%check, if directory exists
if ~exist(img_dir, 'dir'), mkdir(img_dir); end

%load image array
img = struct2cell(load(datafile, img_array));
img = img{1};

for c = 1 : length(img) %loop over image containers
    
    %get number of images
    nrI = size(img{c}.img, 3);
    
    for n = 1 : nrI %loop over images
        
        %write image as bmp and with stored name to stimdir
        imwrite(img{c}.img(:,:,n), fullfile(img_dir, img{c}.name{n}), 'bmp');
    end
end