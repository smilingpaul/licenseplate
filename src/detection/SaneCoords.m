% Runs sanity check on coords to make sure they are not outside a 1024/768 image

function saneCoords = SaneCoords(plateCoords)

  saneCoords = plateCoords;

  % Work on coordinates if nonzero
  if sum(abs(plateCoords)) > 0

    if plateCoords(1) < 1
      saneCoords(1) = 1;
    end

    if plateCoords(2) > 1024
      saneCoords(2) = 1024;
    end

    if plateCoords(3) < 1
      saneCoords(3) = 1;
    end

    if plateCoords(4) > 768
      saneCoords(4) = 768;
    end
  end


end
