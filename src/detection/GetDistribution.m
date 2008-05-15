% Takes a matrix and returns the percentage of pixels below the mean value
% and the percentage of pixels above. Results does not need to sum to
% 100% as pixels of the same intensity os the mean intensity are not counted.

function [ percBelow, percAbove ] = GetDistribution(inputImage)

  % Change matrix to vector
  inputImage = inputImage(:);

  % Calculate mean intensity
  meanIntensity = mean(inputImage);

  % Number of pixels above and below average
  pxlsAbove = 0;
  pxlsBelow = 0;

  % Count pixels
  for i = 1:length(inputImage)
    if inputImage(i) < meanIntensity
      pxlsBelow = pxlsBelow + 1; 
    elseif inputImage(i) > meanIntensity
      pxlsAbove = pxlsAbove + 1; 
    end
  end

  % Calculate percentages
  percAbove = pxlsAbove * (100/length(inputImage));
  percBelow = pxlsBelow * (100/length(inputImage));

end
