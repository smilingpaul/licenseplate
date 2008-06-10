% 
function [charHitList, sumHitList] = ReadCharSUM (charImg, sumImgs, imSize)

  % order of meanvectors must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  allChars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';

  resizedChar = imresize(charImg, [imSize imSize]);
  %if figuresOn
  %  figure(72), subplot(1,2,1), imshow(resizedChar), title('resizedChar');
  %end

  sums = zeros(size(sumImgs,3),1);
  for j = 1:length(allChars)
    [y x] = find(resizedChar);    
    for k = 1:size(y,1)
      sums(j) = sums(j) + sumImgs(y(k),x(k),j);
    end
  end

  charHitList = '';
  sumHitList = zeros(1,length(allChars));
  
  
  for j = 1:length(allChars)
    [bestSum bestCharIndex] = max(sums);
    charHitList = strcat(charHitList,allChars(bestCharIndex));
    sumHitList(j) = 1/bestSum;
    sums(bestCharIndex) = 0;
  end

end