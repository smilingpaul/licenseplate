% Read an image of a char an output a string representing the char.
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
% - char: a string representing the char in the charImg
function char = ReadCharFC (charImg, meanVectors, height, width)

 % resize image and make vector. TO-DO: OTHER RESIZE METHOD?
 resizedImg = imresize(charImg, [height width]);
 imgVector = reshape(resizedImg,height*width,1);
 
 % minimum distance and meanVector no.
 minEuclidDist = inf;
 bestMeanVector = 1;
 
 % iterate through meanVectors to find the most appropiate
 for i = 1:size(meanVectors,1)
   
   % calculate distance from imgVector to current meanVector
   euclidDist = sqrt(sum((imgVector-meanVectors(1))^2));
   
   % determine if the calculated distance is the minimum
   if euclidDist < minEuclidDist
     minEuclidDist = euclidDist;
     bestMeanVector = i;
   end
   
 end
 
 % output char corresponding to found meanVector
 char = '';

end