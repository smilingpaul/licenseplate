% Takes a matrix of connected components and a scale factor ]0.0-1.0] 
% Returns best plate candidate

function plateCoords = GetBestCandidate(conComp, scaleFactor)

  % Number of components
  numConComp = max(max(conComp));


  % Lets find out which connected component in the image has the most
  % plate-like width/height ratio 504/120 is official size

  % optimalPlateRatio = 504/120; %

  % Ratio from image
  optimalPlateRatio = 182/37;
  % optimalPlateRatio = 182/42;


  % Loop through connected components. The component with the
  % best width/height-aspect is our numberplate

  % smallest diff between best components ratio and optimal plate ratio
  bestRatioDiff = inf;

  % The number of the component with the closest matchin aspect ratio
  bestRatioComponent = 0;


for i = 1:numConComp

  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);

  % Calculate with height of component
  compHeight = max(Ys)-min(Ys);
  compWidth = max(Xs)-min(Xs);
  compLength = length(Xs);

  % Calculate width/height-ratio of current component
  compRatio = compWidth/compHeight;

  % Very big components are bad
  %if compHeight < imHeight/4 && compWidth < imWidth/4

    % compLength
    % Calculate difference between current components ratio
    % and ratio of plate
    ratioDiff = abs(optimalPlateRatio-compRatio);

    % Maybe it should not HAVE to be a better ratio than the best
    % The ratio is not an exact science anyway. Maybe it should just be one parameter
    % But, remember that the one with the best ratio is picked as the best match currently

  if ratioDiff < bestRatioDiff && ... % Best ratio
       compLength >= (compHeight*compWidth)/2.0 && ... % High density
       compWidth >= 3*compHeight % Must be wide
       %compWidth <= scaleFactor*280 && compHeight >= scaleFactor*22

       %wi = max(Ys)-min(Ys)
       %he = max(Xs)-min(Xs)
       %length(Xs)
       %(compHeight*compWidth)/1)
       %compHeight >= scaleFactor*30 && compHeight <= scaleFactor*70 && ...
       %compWidth >= scaleFactor*100 && compWidth <= scaleFactor*250
      bestRatioDiff = ratioDiff;
      bestRatioComponent = i;
    end
  %end
end


if bestRatioDiff < inf
  % Get coords for best matching component
  [Ys,Xs] = find(conComp == bestRatioComponent);

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
