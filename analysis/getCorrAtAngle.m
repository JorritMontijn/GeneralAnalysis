function dblCorr = getCorrAtAngle(dblAngle,vecX,vecY,vecV)
	%getCorrAtAngle Correlation of vecV with location of X/Y projected unto a line with angle dblAngle
	%   dblCorr = getCorrAtAngle(dblAngle,vecX,vecY,vecV)
	
	%center x/y
	vecX=zscore(vecX(:));
	vecY=zscore(vecY(:));
	matXY=[vecX vecY]';
	%rotate reference vector
	matRot = [cos(dblAngle) sin(dblAngle);...
		-sin(dblAngle) cos(dblAngle)];
	vecRefVector=[1;0];
	vecRotRef = matRot * vecRefVector;
	
	%calc corr
	[vecProjectedLocation,matProjectedPoints] = getProjOnLine(matXY,vecRotRef);
	
	%calc correlation
	dblCorr = corr(vecProjectedLocation,vecV);
end

