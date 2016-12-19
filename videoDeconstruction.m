function videoDeconstruction( folder, resultsFolder )

%% SETTINGS
cfg.numParticles = 500;
cfg.sizeFactorRectangles = 25;
cfg.minSizeRectangles = 3;
cfg.dispFactor = 10;
cfg.inertiaFactor = 5;

%% READ DATA
if nargin == 0
    [folder] = uigetdir('*', 'Select Sequence folder');
end

    if folder == 0 
        return
    end

if nargin < 2
    [resultsFolder] = uigetdir('*', 'Select Results Folder');
end

    if resultsFolder == 0 
        return
    end

folder = strcat(folder, filesep);
% get dir information
dir_struct = dir(folder);

% get image names
fileNames = {dir_struct(~[dir_struct.isdir]).name}';

nImages = size(fileNames, 1);

% read the first image
imIN = imread( strcat(folder, cell2mat(fileNames(1))) );

[imH imW RGB] = size(imIN);


%% Initialization
figure; imshow(imIN(:,:,1:3)); title('First original frame');

%% Initialize particles 
for p = 1:cfg.numParticles
    
    % size (half of it)
    particle(p).vSize = round(cfg.minSizeRectangles + cfg.sizeFactorRectangles * abs(randn(1)));
    particle(p).hSize = round(cfg.minSizeRectangles + cfg.sizeFactorRectangles * abs(randn(1)));
    
    % location
    particle(p).x = round((imW-(particle(p).hSize*2)-1) * rand(1)) + particle(p).hSize+1;
    particle(p).y = round((imH-(particle(p).vSize*2)-1) * rand(1)) + particle(p).vSize+1;
    
    particle(p).inertiaX = cfg.inertiaFactor * abs(randn(1));
    particle(p).inertiaY = cfg.inertiaFactor * abs(randn(1));
    
    % amount of displacement
    particle(p).dispX = round(cfg.dispFactor * randn(1));
    particle(p).dispY = round(cfg.dispFactor * randn(1));
    
end


for i = 1:nImages
    
    fprintf('Generating frame %04d ......', i); tic;
    
    imIN = im2double( imread( strcat(folder, cell2mat(fileNames(1))) ) );
    
    % new displacement field
    dispField = zeros(imH, imW, 2);

    for p = 1:cfg.numParticles

        % add to the displacement field
        dispField(particle(p).y-particle(p).vSize:particle(p).y+particle(p).vSize, ...
                  particle(p).x-particle(p).hSize:particle(p).x+particle(p).hSize, 2 ) = particle(p).dispX;
              
        dispField(particle(p).y-particle(p).vSize:particle(p).y+particle(p).vSize, ...
                  particle(p).x-particle(p).hSize:particle(p).x+particle(p).hSize, 1 ) = particle(p).dispY;
              
        
        % update particle
        particle(p).x = round( particle(p).x + particle(p).inertiaX);
        particle(p).y = round( particle(p).y + particle(p).inertiaY);
        
        particle(p).dispX = round( particle(p).dispX + particle(p).inertiaX);
        particle(p).dispY = round( particle(p).dispY + particle(p).inertiaY);
            
        
        % check boundaries
        if particle(p).x - particle(p).hSize < 1 || particle(p).x + particle(p).hSize > imW ||...
           particle(p).y - particle(p).vSize < 1 || particle(p).y + particle(p).vSize > imH
       
            % if out of boundaries, reinitialize it somewhere random
            particle(p).x = round((imW-(particle(p).hSize*2)-1) * rand(1)) + particle(p).hSize+1;
            particle(p).y = round((imH-(particle(p).vSize*2)-1) * rand(1)) + particle(p).vSize+1;
            
            particle(p).dispX = round(cfg.dispFactor * randn(1));
            particle(p).dispY = round(cfg.dispFactor * randn(1));
        end
    end
    
    % deform image
    imOUT(:,:,1) = warpImage(imIN(:,:,1), dispField);
    imOUT(:,:,2) = warpImage(imIN(:,:,2), dispField);
    imOUT(:,:,3) = warpImage(imIN(:,:,3), dispField);
    
%     clf(figResults);
%     
%     imshow(imOUT);
    
    % save image
    name = sprintf('%s/frame%04d.png', resultsFolder, i);
    imwrite( imOUT, name );
    
    fprintf(' (%.3f SEC)\n', toc);
end


end

