% 
function [charHitList, andHitList] = ReadCharAND (charImg, andImgs, imSize)

  % order of meanvectors must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  allChars = '0123456789ABCDEHJKLMNOPRSTUVXYZ';

  resizedChar = imresize(charImg, [imSize imSize]);
  %if figuresOn
  %  figure(72), subplot(1,2,1), imshow(resizedChar), title('resizedChar');
  %end
  
  ands = zeros(size(andImgs,3),1);

  % compare to 'andimgs'
  noOfAnds = zeros(size(allChars,1),1);
  for j = 1:length(allChars)
    conjunc = resizedChar & andImgs(:,:,j);
    noOfAnds(j) = length(find(conjunc));
  end

  charHitList = '';
  andHitList = zeros(1,length(allChars));
  
  % find char with max no. of ands. if one is a lone max: return it
  for j = 1:length(allChars)
    [maxAnds, bestCharIndex] = max(noOfAnds);
    charHitList = strcat(charHitList,allChars(bestCharIndex));
    andHitList(j) = 1/maxAnds;
    ands(bestCharIndex) = 0;
  end
  
  %if length(find(noOfAnds == maxAnds)) == 1
  %  plateString(i) = allChars(maxChar);      
  %end

end