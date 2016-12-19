function deconstruction( im )

%% SETTINGS
cfg.numRectangles = 5000;
cfg.sizeFactorRectangles = 5;
cfg.minSizeRectangles = 3;
cfg.dispFactor = 10;


%% Read file
if nargin == 0
    [tifFile tifFolder] = uigetfile('*', 'Select Image');
    im = imread(strcat(tifFolder, tifFile));
end

%% Initialization
figure; imshow(im); title('Original Image');

[imH imW dim] = size(im);

%% Create displacement field
dispField = zeros(imH, imW, 2);

for r = 1:cfg.numRectangles
    
    % size (half of it)
    vSize = round(cfg.minSizeRectangles + cfg.sizeFactorRectangles * abs(randn(1)));
    hSize = round(cfg.minSizeRectangles + cfg.sizeFactorRectangles * abs(randn(1)));
    
    % location
    x = round((imW-(hSize*2)-1) * rand(1)) + hSize+1;
    y = round((imH-(vSize*2)-1) * rand(1)) + vSize+1;
    
    % amount of displacement
    disp = round(cfg.dispFactor * randn(1));
    
    % direction of displacement
    if randn(1) > 0
        verticalDsiplacement = true;
    else
        verticalDsiplacement = false;
    end
    
    % add to the displacement field
    
    dispField(y-vSize:y+vSize, x-hSize:x+hSize, verticalDsiplacement+1 ) = disp;
end

%% Generate next frame
% figure; imagesc(dispField(:,:,1)); title('vertical displacements');
% figure; imagesc(dispField(:,:,2)); title('horizontal displacements');

imDouble = im2double(im);

nextFrame(:,:,1) = movepixels_2d(imDouble(:,:,1), dispField(:,:,2), dispField(:,:,1), 4);
nextFrame(:,:,2) = movepixels_2d(imDouble(:,:,2), dispField(:,:,2), dispField(:,:,1), 4);
nextFrame(:,:,3) = movepixels_2d(imDouble(:,:,3), dispField(:,:,2), dispField(:,:,1), 4);


%% SHOW RESULTS

figure; imshow(nextFrame);


end

