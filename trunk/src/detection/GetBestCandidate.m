% Takes a matrix of connected components and a grayscale image 
% Returns best plate candidate based on frequency analysis and ratio

function plateCoords = GetBestCandidate(conComp, inputImage, scaleFactor)

  % Number of components
  numConComp = max(max(conComp));


  % Lets find out which connected component in the image has the most
  % plate-like width/height ratio 504/120 is official size

   optimalPlateRatio = 504/120; %
   optimalPlateness = 17; % If smoothness = 0
   %optimalPlateness = 13; % If smoothness = 1

  % Ratio from image
  %optimalPlateRatio = 182/37;
  % optimalPlateRatio = 182/42;


  % Loop through connected components. The component with the
  % best width/height-aspect is our numberplate

  % smallest diff between best components ratio and optimal plate ratio
  bestRatioDiff = inf;
  bestPlatenessDiff = inf;

  % The number of the component with the closest matchin aspect ratio
  bestRatioComponent = 0;
  bestPlatenessComponent = 0;


for i = 1:numConComp

  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);

  % Calculate with height of component
  compHeight = max(Ys)-min(Ys);
  compWidth = max(Xs)-min(Xs);
  compLength = length(Xs);

  thisImage = inputImage(min(Ys):max(Ys),min(Xs):max(Xs));

  compSignature = GetSignature(thisImage,0);
  compPlateness = GetPlateness(compSignature);
  [compDistBelow, compDistAbove] = GetDistribution(thisImage);
  compWhiteLine = GetLongestLine(thisImage);
 
  compIntDiff = max(max(thisImage)) - min(min(thisImage));

  % Calculate width/height-ratio of current component
  compRatio = compWidth/compHeight;

  ratioDiff = abs(optimalPlateRatio-compRatio);
  platenessDiff = abs(optimalPlateness - compPlateness);

  % Maybe it should not HAVE to be a better ratio than the best
  % The ratio is not an exact science anyway. Maybe it should just be one parameter
  % But, remember that the one with the best ratio is picked as the best match currently

  % Candidates need a difference in intensities of at least this value
  % In one set min diff is 43 in the other it is 91
  if compIntDiff >= 43
    %if compDistAbove >= 50 && compDistAbove <= 80
    if compDistAbove >= 0 && compDistAbove <= 100
      if compWhiteLine >= 50 % Needs a white line of length 50%
        if platenessDiff < bestPlatenessDiff && ... % Best plateness
           compPlateness > 10 && compPlateness < 30 
 
            %bestRatioDiff = ratioDiff;
            %bestRatioComponent = i
            bestPlatenessDiff = platenessDiff;
            bestPlatenessComponent = i;
         end
      else
        [ 'A candidate has less than 50% white line' ]
        %figure(661), imshow(thisImage);
        %title([ 'No good white line' ]);
        %beep;
        %pause;
      end 
    else
      [ 'A candidate has less than 50% intensity above average' ]
    end 
  else
    [ 'A candidate has no good intensity diff' ]
    %beep
  end
end


%if bestRatioDiff < inf % A candidate was selected
if bestPlatenessDiff < inf % A candidate was selected
  % Get coords for best matching component
  %[Ys,Xs] = find(conComp == bestRatioComponent);
  [Ys,Xs] = find(conComp == bestPlatenessComponent);

  % Calculate coords
  minX = min(Xs);
  maxX = max(Xs);
  minY = min(Ys);
  maxY = max(Ys);

  plateCoords = (1/scaleFactor) * [ minX maxX minY maxY ];
else
  % No component was selected but we need to return something
  plateCoords = [ 0 0 0 0 ];
end


end % function 
