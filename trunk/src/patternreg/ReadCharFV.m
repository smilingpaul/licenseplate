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
% - char1-3: three strings representing the char in the charImg. char1 is
% the best guess etc.
function [char1, char2, char3] = ReadCharFV (charImg, meanVectors, height, width)

  % order of meanvectors must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  chars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';

  % resize image and make vector. TO-DO: OTHER RESIZE METHOD?
  resizedImg = imresize(charImg, [height width]);
  imgVector = reshape(resizedImg,height*width,1);
 
  % minimum distance and meanVector no.
  minEuclidDist1 = inf;
  minEuclidDist2 = inf;
  minEuclidDist3 = inf;
  bestMeanVector1 = 1;
  bestMeanVector2 = 1;
  bestMeanVector3 = 1;
 
  % iterate through meanVectors to find the most appropiate
  for i = 1:size(meanVectors,1)
   
    % calculate distance from imgVector to current meanVector
    euclidDist = sqrt(sum((imgVector-meanVectors(:,i)).^2));
   
    % determine if the calculated distance is the one of the minimum
    if euclidDist < minEuclidDist1
      minEuclidDist3 = minEuclidDist2;
      bestMeanVector3 = bestMeanVector2;
      minEuclidDist2 = minEuclidDist1;
      bestMeanVector2 = bestMeanVector1;
      minEuclidDist1 = euclidDist;
      bestMeanVector1 = i;
    elseif euclidDist < minEuclidDist2
      minEuclidDist3 = minEuclidDist2;
      bestMeanVector3 = bestMeanVector2;
      minEuclidDist2 = euclidDist;
      bestMeanVector2 = i;
    elseif euclidDist < minEuclidDist3
      minEuclidDist3 = euclidDist;
      bestMeanVector3 = i;
    end
   
  end
 
  % output chars corresponding to found meanVectors
  char1 = chars(bestMeanVector1);
  char2 = chars(bestMeanVector2);
  char3 = chars(bestMeanVector3);

end