#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function IVaver(Idw, [n])

	// Assumes IV curve is symmetric and averages it out
	// n = cycles

	wave Idw // the current wave (Id wave)
	variable n
	
	variable j = 0
	variable k = numpnts(Idw) -1 
	
	variable temp = 0
	
	Make/N=(ceil( (k+1) / 2) )/O Idw_aver
	
	do
		temp = (Idw[j] + Idw[k]) / 2
		Idw_aver[j] = temp
	
		j += 1
		k -= 1
	while (j < numpnts(Idw) && j < k) 

end