% Takes an image and smoothness parameter, returns signature
% Sig. vector vil be 2*smoothness shorter than width of input image

function signature = GetSignature(image, smoothness)

%figure, imshow(image);



%%%%%%%%%%%%%%%%%%%%%
% Sum rows in image %
%%%%%%%%%%%%%%%%%%%%%

rawSig = zeros(1, size(image,2));
for x = 1:size(image,1)
  rawSig = rawSig + double(image(x,:));
end


%%%%%%%%%%%%%%%%%%%%%%
% Smoothen signature %
%%%%%%%%%%%%%%%%%%%%%%

% Num of left and right pixels to consider
width = smoothness;

smoothSig = zeros(1, length(rawSig)-2*width);
for x = 1:length(smoothSig)
  smoothSig(x) = sum(rawSig(x:x+2*width))/(2*width+1);
end 

% Sig to return
signature = smoothSig;

end
