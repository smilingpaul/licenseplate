% Takes a matrix of connected components and a grayscale image 
% Returns best plate candidate based on frequency analysis and ratio

function [plateCoords bestCandidateScore] = GetBestCandidate2(conComp, inputImage, scaleFactor)

  showImages = true;
  %showImages = false;


  % Number of components
  numConComp = max(max(conComp));

  % The optimal width/height aspect ratio of a plate
  optimalPlateRatio = 504/120; % Official plate ratio
  plateRatioWeight = 16;

  % optimal intensity difference
  optimalIntDiff = 180;
  intDiffWeight = 0.25;

  % Optimal longest white line
  optimalLongestWhiteLine = 90;

  % The optimal plateness-value 
  optimalPlateness = 17; % If smoothness = 0
  platenessWeight = 3;

  % Optimal percentage of pixels below mean intensity
  optimalIntDist = 45;

  % Optimal mean intensity
  optimalMeanInt = 130; %80
  meanIntWeight = 0.4;

  % Optimal density percentage of candidate-area in binary image
  optimalDensity = 0.9;
  densityWeight = 25;

  % Optimal percentage of pixels close to min intensity
  optimalCloseMin = 22;

  % Optimal percentage of pixels close to min intensity
  optimalCloseMax = 32;
 
  % Optimal length of average gradient
  optimalAvgGradient = 45;

  % Matrix to hold candidate values
  % Values are:
  % 1-4: maxX, minX, minY, maxY
  %   5: width/Height ratio diffe
  %   6: intensity diff diff
  %   7: longest white horizontal line (%) in candidate when converted to binary 
  %   8: plateness diff
  %   9: Intensity distribution diff
  %  10: Average intensity diff
  %  11: Density of candidate
  %  12: Percentage of pixels close to min intensity
  %  13: Percentage of pixels close to max intensity
  %  14: Average length of (top half?) gradients
  %  15: sum of scores
  candidates = zeros(numConComp,15);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Loop through candidates %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  for i = 1:numConComp
 
    % Get Xs and Ys of current component
    [yS,xS] = find(conComp == i);
    
    % Get the actual component image
    thisImage = inputImage(min(yS):max(yS),min(xS):max(xS));

    % Calculate width and height of component
    [compHeight, compWidth ] = size(thisImage);

    % Get signature
    compSignature = GetSignature(thisImage,0);

    % Calculate gradients for the component
    [FX,FY] = gradient(double(thisImage));



    % Insert coordinates into candidate matrix
    candidates(i,1:4) = [ min(yS) max(yS) min(xS) max(xS) ];

    % Insert ratio into candidate matrix
    %candidates(i,5) = plateRatioWeight * abs(optimalPlateRatio - (compWidth/compHeight));
    candidates(i,5) = 20.0 * abs(optimalPlateRatio - (compWidth/compHeight))^2;

    % Insert max difference into intensities in candidate matrix
    candidates(i,6) = intDiffWeight *  ... 
                      abs(optimalIntDiff - (max(max(thisImage)) - min(min(thisImage))));

    % Insert longest white line into candidates matrix
    candidates(i,7) = abs(optimalLongestWhiteLine - GetLongestLine(thisImage));

    % Insert plateness into candidate matrix
    candidates(i,8) = platenessWeight * ...
                      abs(optimalPlateness - GetPlateness(compSignature));

    % Insert percentage of pixels below mean intensity into candidates matrix
    candidates(i,9) = abs(optimalIntDist - GetDistribution(thisImage));

    % Insert average intensity into candidates matrix
    %candidates(i,10) = meanIntWeight * 1.09^abs(optimalMeanInt - mean(mean(thisImage)));
    candidates(i,10) = meanIntWeight * abs(optimalMeanInt - mean(mean(thisImage)));
    
    % Insert density of candidate into candidates matrix
    candidates(i,11) = densityWeight * ... 
                       abs(optimalDensity - (compWidth*compHeight)/length(xS));

    % Insert percentage of pixels in candidate with intensities
    % close to the minimumum intensity
    candidates(i,12) = abs(optimalCloseMin - ...
                       round(( length(find(thisImage <= min(min(thisImage)) + 40)) / ... 
                       (compWidth*compHeight)) * 100));

    % Insert percentage of pixels in candidate with intensities
    % close to the maximum intensity
    candidates(i,13) = abs(optimalCloseMax - ... 
                       round(( length(find(thisImage >= max(max(thisImage)) - 40)) / ... 
                       (compWidth*compHeight)) * 100));
    
    % Insert length of average gradient into candidates matrix
    candidates(i,14) = abs(optimalAvgGradient - mean(mean(sqrt(FY.^2 + FX.^2))));

    % Insert total score into candidates matrix
    % Highest score only counts a third of its value
    candidates(i,15) = sum(candidates(i,5:14)) - 0.75 * max(candidates(i,5:14));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Modifiers to total score %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % GOOD 10% off
    % Percentage of pixels close to max intensity is larger
    % than pixels close to min intensity
    %if (1.3 * candidates(i,12)) < candidates(i,13)  
    %  candidates(i,15) = 0.90 * candidates(i,15);
    %end

    % BAD
    % Aspect ratio way off
    %if candidates(i,5) <= 50
    %  candidates(i,15) = 1.05 * candidates(i,15);
    %end




  
  end %Loop


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Find acceptable candidate with lowest score %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  bestCandidateScore = inf;
  for i = 1:numConComp
    if candidates(i,15) < bestCandidateScore && ... % Lowest score
       candidates(i,15) <= 190 %&& ... % Better score than this
       %candidates(i,5) <= 60 %&& ... % Aspect ratio score less than this
       %candidates(i,8)  <= 45  && ... % Plateness score less than this
       %candidates(i,11) <= 40 && ... % Density less than this
       %candidates(i,13) <= 31 % candidates close to max less than this
      bestCandidateScore = candidates(i,15);
      plateCoords =  (1/scaleFactor) * [ candidates(i,3:4) candidates(i,1:2) ];
    end
  end  

  % We found no candidate
  if bestCandidateScore == inf
    plateCoords = [ 0 0 0 0];
    bestCandidateScore = 0;
  end
 
  %plateCoords



  %%%%%%%%%%%%%%%
  % Show images %
  %%%%%%%%%%%%%%%

  if showImages
    figure(856);

    % Reset all positions
    for i = 1:16
      subplot(4,4,i);
      imshow(zeros(1));
      title('');
    end  
    

    for i = 1:numConComp
      subplot(4,4,i);
      imshow(inputImage(candidates(i,1):candidates(i,2), ...
                        candidates(i,3):candidates(i,4)));

      title(int2str(candidates(i,5:15))); % All scores
      %title(int2str(candidates(i,10:15))); % mean int to score
      %title(int2str(candidates(i,12:15)));
    end

  end % ShowImages

end %function 
