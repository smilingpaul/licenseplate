% Takes a grayscale image and performs a contrast stretch
% based on the window parameter.
% If winSize = 0 a contrast stretch will stretch to image to use all
% available intensities. If all intensities are in use there will be
% no difference between inputImage and outputImage.
% If winSize is > 0  

function outputImage = ContrastStretch(inputImage, winSize)




if winSize < 1 % Stretch full image

  %%%%%%%%%%%%%%%%
  % Full stretch %
  %%%%%%%%%%%%%%%%

  maxVal = max(max(inputImage));
  minVal = min(min(inputImage));

  % Does full stretch make sense on this image?
  if maxVal == 256 && minVal == 1
    outputImage = inputImage;
  else
    % Full stretch

    % Move all info down. Intensities below minCut are removed
    outputImage = uint8(inputImage-minVal);
    % Normalize
    outputImage =  double(outputImage) / double(max(max(outputImage)));
    % Stretch
    outputImage = uint8(255 * outputImage);

  end % full stretch
else

  %%%%%%%%%%%%%%%%%%
  % Window stretch %
  %%%%%%%%%%%%%%%%%%

  % Create histogram
  imHist = hist(double(inputImage(:)),256);

  % Highest value of summed window (a lot of information in window)
  bestWinVal = 1;
  % Start position of best window
  bestWinStart = 1;

  % Loop through intervals
  for x = 1:(256-window)
    thisWinVal = sum(imHist(x:x+window-1)); 
    if thisWinVal > bestWinVal
      bestWinVal = thisWinVal;
      bestWinStart = x;
    end
  end 

  minCut = bestWinStart;
  maxCut = bestWinStart + window - 1;

  % Sane min/max cut
  if maxCut > 255
    maxCut = 255;
  end
  if minCut < 0
    minCut = 0;
  end

  % Move all info down. Intensities below minCut are removed
  outputImage = uint8(inputImage-minCut);
  % Normalize
  outputImage =  double(outputImage) / double(max(max(outputImage)));
  % Stretch
  outputImage = uint8((255+maxCut) * outputImage);

end % window stretch



end % function 
