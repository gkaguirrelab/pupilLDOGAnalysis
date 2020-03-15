function amp = addSinuoids(ampA,ampB,phaseA,phaseB)
    delta = phaseA - phaseB;
    amp = sqrt(ampA.^2+ampB.^2 + (2.*ampA.*ampB.*cos(delta)))./2;
end

