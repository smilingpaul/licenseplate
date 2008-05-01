% Takes a binary image and a scale factor and cleans the image
% up by removing areas that match the rules set by the parameters.
%
% All pixel sizes are sizen in a 1024*768 pixel image.


function cleanImg = BinImgCleanup(inputImage, scaleFactor)

  %showImages = true;
  showImages = false;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Parameters          %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % Components of this height or more are too high 
  tooHigh = round(100 * scaleFactor);

  % Components of this height or more are too low 
  tooLow = round(20 * scaleFactor);
 
  % Components of this width or more are too wide
  tooWide = round(350 * scaleFactor);

  % Components of this width or less are too narrow 
  tooNarrow = round(120 * scaleFactor);

  % Minimum density 1/parameter of the components
  % rectangle must be white

  minDensity = 3;

  


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Create connected components %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  [conComp,numConComp] = (bwlabel(inputImage,4));

  % Vector for tracking deleted components
  % 1 = deleted, 0 = not deleted
  compDeleted = zeros(1, numConComp);


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup based on sizes   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for i = 1:numConComp

    if not(compDeleted(i)) % Comp is not deleted 

      % Get Xs and Ys of current component
      [Ys,Xs] = find(conComp == i);

      % Calculate with height of component
      compHeight = max(Ys) - min(Ys);
      compWidth = max(Xs) - min(Xs);

      if compWidth >= tooWide || compWidth <= tooNarrow || ... % Width
         compHeight >= tooHigh || compHeight <= tooLow         % Height
           % Delete component
           DelComp(i); 
      end
  
    end % not deleted
  end % loop

  noBadSizes = conComp;



  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup based on ratio   %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for i = 1:numConComp

    if not(compDeleted(i)) % Comp is not deleted 

      % Get Xs and Ys of current component
      [Ys,Xs] = find(conComp == i);

      % Calculate with height of component
      compHeight = max(Ys) - min(Ys);
      compWidth = max(Xs) - min(Xs);

      % Calculate width/height-ratio of current component
      compRatio = compWidth/compHeight;

      if compHeight >= compWidth/2 || ... % Too square like
         compWidth >= compHeight*7        % Too flat
           % Delete component
           DelComp(i); 
      end
  
    end % not deleted
  end % loop

  noBadRatios = conComp;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Cleanup based on density %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for i = 1:numConComp

    if not(compDeleted(i)) % Comp is not deleted 

      % Get Xs and Ys of current component
      [Ys,Xs] = find(conComp == i);

      % Calculate with height of component
      compHeight = max(Ys) - min(Ys);
      compWidth = max(Xs) - min(Xs);
      compLength = length(Xs);

      if (compHeight*compWidth)/minDensity >= compLength 
           % Delete component
           DelComp(i); 
      end
  
    end % not deleted
  end % loop

  noBadDensities = conComp;





%{
for i = 1:numConComp

  % Get Xs and Ys of current component
  [Ys,Xs] = find(conComp == i);

  % Calculate with height of component
  compHeight = max(Ys)-min(Ys);
  compWidth = max(Xs)-min(Xs);
  compLength = length(Xs);

  % Calculate width/height-ratio of current component
  compRatio = compWidth/compHeight;

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

%}

  cleanImg = im2bw(conComp);

  if showImages
    figure(200);

    subplot(1,4,1);
    imshow(inputImage);
    title('Input image');

    subplot(1,4,2);
    imshow(noBadSizes);
    title('No bad sizes');

    subplot(1,4,3);
    imshow(noBadRatios);
    title('No bad ratios');

    subplot(1,4,4);
    imshow(noBadDensities);
    title('No bad densities');
    

  end % show images




  % Delete a component 
  function [] = DelComp(compNo)
    % Get Xs and Ys of current component
    [myYs,myXs] = find(conComp == compNo);

    for j = 1:length(myXs)
      conComp(myYs(j),myXs(j)) = 0;
    end

    % Mark component as deleted
    compDeleted(1,compNo) = 1;
    
  end


end % BinImgCleanup





