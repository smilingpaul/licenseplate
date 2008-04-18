function plateCoords = DetectMain(inputImage)


  % Read image from file
  origImage = rgb2gray(imread(inputImage));

  % High contrast
  f1c = detect4(inputImage);
  
  % Finds candidates based on sameness
  f2c = detect5(inputImage);

  % Finds candidates based on avg filter 
  f3c = detect6(inputImage);

  % Average result
  avgRes = (f1c + f2c + f3c) / 3;
 




  figure(300);
  imshow(origImage ./ 4);
  hold on;

  plot(sum(f1c(1:2))/2, sum(f1c(3:4))/2,'ro');

  plot(sum(f2c(1:2))/2, sum(f2c(3:4))/2,'bo');

  plot(sum(f3c(1:2))/2, sum(f3c(3:4))/2,'go');

  % Average
  plot(sum(avgRes(1:2))/2, sum(avgRes(3:4))/2,'rx');

  hold off;


  figure(301);
  subplot(1,3,1);
  if sum(f1c) > 0
    sig = GetSignature(origImage(f1c(3):f1c(4),f1c(1):f1c(2)), 2);
    plot(sig);
    %title(['red ' int2str(pness)]);
  else
    plot(zeros(1));
  end
  title('red');
  

  subplot(1,3,2);
  if sum(f2c) > 0
    sig = GetSignature(origImage(f2c(3):f2c(4),f2c(1):f2c(2)), 2);
    plot(sig);
    %title(['blue ' int2str(pness)]);
  else
    plot(zeros(1));
  end
  title('blue');

  subplot(1,3,3);
  if sum(f3c) > 0
    sig = GetSignature(origImage(f3c(3):f3c(4),f3c(1):f3c(2)), 2);
    plot(sig);
    title(['green ' int2str(GetPlateness(sig))]);
  else
    plot(zeros(1));
    title('green');
  end


  plateCoords = avgRes;
  %plateCoords = [0 0 0 0];


  
end
