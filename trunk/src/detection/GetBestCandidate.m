% Takes a matrix of connected components and a grayscale image 
% Returns best plate candidate based on frequency analysis and ratio

function plateCoords = GetBestCandidate(conComp, inputImage, scaleFactor)

  % Number of components
  numConComp = max(max(conComp));


  % Lets find out which connected component in the image has the most
  % plate-like width/height ratio 504/120 is official size

   optimalPlateRatio = 504/120; %
   optimalPlateness = 18; % Calculated from test sets

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


  compSignature = GetSignature(inputImage(min(Ys):max(Ys),min(Xs):max(Xs)),0);
  compPlateness = GetPlateness(compSignature)
 
  % Calculate width/height-ratio of current component
  compRatio = compWidth/compHeight;

  ratioDiff = abs(optimalPlateRatio-compRatio);
  platenessDiff = abs(optimalPlateness - compPlateness);

  % Maybe it should not HAVE to be a better ratio than the best
  % The ratio is not an exact science anyway. Maybe it should just be one parameter
  % But, remember that the one with the best ratio is picked as the best match currently

  %if ratioDiff < bestRatioDiff && ... % Best ratio
  if platenessDiff < bestPlatenessDiff && ... % Best ratio
     compPlateness > 10 && compPlateness < 26


      %bestRatioDiff = ratioDiff;
      %bestRatioComponent = i
      bestPlatenessDiff = platenessDiff;
      bestPlatenessComponent = i
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
