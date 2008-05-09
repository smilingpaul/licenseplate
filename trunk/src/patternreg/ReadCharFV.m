% Read an image of a char an output a string representing the three chars
% that the image most likely represents.
%
% Input:
% - charImg: image of a char
% - meanVectors: a matrix containing the meanVectors of all possible chars.
% the length of each meanVector must be height x width and the meanVectors
% matrix must be on form noOfVectors x height*width
% - height: the height that each char must be scaled to
% - width: the width that each char must be scaled to
%
% Output:
% - charsSorted: a string of sorted chars. charsSorted(1) is best guess.
function charsSorted = ReadCharFV (charImg, meanVectors, height, width)

  % order of meanvectors must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  chars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';

  % resize image and make vector. TO-DO: OTHER RESIZE METHOD?
  resizedImg = imresize(charImg, [height width]);
  imgVector = reshape(resizedImg,height*width,1);
  
  % calculate euclidian distances
  euclidDists = zeros(31,1);
  for i = 1:size(meanVectors,2)
    euclidDists(i) = sqrt(sum((imgVector-meanVectors(:,i)).^2));
  end
  
  % sort the chars by minimum euclid. distance: nearest first
  charsSorted = '';
  for i = 1:length(chars)
    [minDist, minIndex] = min(euclidDists);
    charsSorted = strcat(charsSorted,chars(minIndex));
    euclidDists(minIndex) = inf;
  end

end