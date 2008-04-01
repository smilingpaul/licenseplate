function plateCoords = DetectMain(inputImage)


  % Read image from file
  origImage = rgb2gray(imread(inputImage));

  % Finds candidates based on highest peak in histogram of image
  f1c = detect4(inputImage);
  
  % Finds candidates based on sameness
  f2c = detect5(inputImage);

  avgResult = (f1c + f2c) / 2;
 




  figure(300);
  imshow(origImage ./ 4);
  %image(origImage);
  hold on;

  plot(sum(f1c(1:2))/2, sum(f1c(3:4))/2,'rx');

  plot(sum(f2c(1:2))/2, sum(f2c(3:4))/2,'bo');

  hold off;

  plateCoords = avgResult;
  %plateCoords = [0 0 0 0];


  
end
