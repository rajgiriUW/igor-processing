#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//sets Mask's 1's to NaN
Function NaNMask(maskIn)
	Wave MaskIn
	
	variable r = dimsize(maskIn,0)
	variable c= dimsize(maskIn,1)

	Make/O/N=(r,c) roimask
	
	// sets M_roiMask to the input Mask
	// this routine gets arount the Asylum/Igor masked being UINT8
	//	which sets "NaN" to "255" by default instead of a true NaN
	for (r = 0; r < dimsize(maskIn, 0); r += 1)
	
		for(c = 0; c < dimsize(maskIn, 1); c += 1)
	
			roimask[r][c] = MaskIn[r][c]
	
			if (MaskIn[r][c] == 0)
	
				roiMask[r][c] = NaN
	
			endif
	
		endfor
	
	endfor
	
end

// Adds the ROI masks to the given image
//	Need to set color in this line explicitly:
//	eval={1,0,52280,0} ; in this case it's X, Red, Green, Blue character
function appendroimasks(subset)
	wave subset

	variable len = 0
	
	string name
	
	do
		name = "ROIMask" + num2str(subset[len])
		appendimage $name
	
		// {1, 65280,0,0}  = red
		ModifyImage $name explicit=1,eval={1,0,52280,0},eval={0,-1,-1,-1},eval={255,-1,-1,-1}
	
		len += 1
	
	while (len < numpnts(subset))


end