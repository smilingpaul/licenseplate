% Function that reads all images in a folder of folders with images of
% chars (using mean vectors)
function [percentages] = ReadCharsFV (charFolder, vectorLength)

  % folders must be:
  % 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,H,J,K,L,M,N,O,P,R,S,T,U,V,X,Y,Z
  folderList = dir(charFolder);
  noOfFolders = length(folderList);
  percentages = zeros(1,31);

  % load meanVectors
  meanVectorsFile = load('/Users/epb/Documents/datalogi/3aar/bachelor/licenseplate/src/patternreg/sumImgs');
  %vectorName = ['meanVectors', int2str(vectorLength)];
  vectorName = ['sumImgs', int2str(vectorLength)];
  meanVectors = meanVectorsFile.(vectorName);
  
  charNo = 1;
  
  for i = 1:noOfFolders
    
    % loop through each folder that holds char images
    folderName = folderList(i).name;
    if ~isempty(regexp(folderName,'[A-Z0-9]')) && folderList(i).isdir
      ['Reading ' folderName 's']
      noOfImgsRead = 0;
      imgFolder = [charFolder folderList(i).name '/'];
      imgList = dir(imgFolder);
      noOfElems = length(imgList);
      noOfImgs = 0;
      
      % read char images in folder and register how many have been read
      for j = 1:noOfElems
        if folderName == imgList(j).name(1)
          noOfImgs = noOfImgs + 1;
          charImg = imread([charFolder folderName '/' imgList(j).name]);
          %[charHitList, euclidDist] = ReadCharFV(charImg,meanVectors,vectorLength);
          [charHitList, euclidDist] = ReadCharSUM(charImg,meanVectors,vectorLength);
          if folderName == charHitList(1)
            noOfImgsRead = noOfImgsRead + 1;
          end
        end
      end
      percentages(charNo) = 100*(noOfImgsRead/noOfImgs);
      charNo = charNo + 1;
    end
  end

end