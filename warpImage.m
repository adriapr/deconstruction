function imWarped = warpImage( im, field )

resamp = makeresampler('cubic','fill');

[imH, imW] = size(im);
[TX,TY] = meshgrid(1:imW,1:imH);

tmap(:,:,1) = TY + double(field(:,:,2));
tmap(:,:,2) = TX + double(field(:,:,1));

imWarped = tformarray(double(im),[],resamp,[1 2],[1 2],[],tmap,0);

end

