#pragma rtGlobals=3		// Use modern global access method and strict wave access.

function loadcsv(image,[triggeroffset])
	// Image is an Igor path in the databrowser to the image in question
	// Image saves tFP in tab 1 (tab 0 is height), fixed tFP in tab 2, shift in tab3
	// triggeroffset is for bad triggering. Positive means shifted trigger to later time
	//	i.e. 0.43 instead of 0.4096 ms

	Wave Image
	variable triggeroffset
	string tfp_path, tfpfixed_path, shift_path
	
	string output_paths
	
	string message = "Select three processed files"
	string files = "CSVs (*.csv):.csv;"
	variable refNum	// dummy needed for Open command
	Open/D/R/F = files /M=message/MULT=1 refNum
	output_paths = S_FileName
	
	if (strlen(output_paths) == 0)
		Print "Cancelled"
		abort
	else
		variable numFiles = ItemsInList(output_paths, "\r")
		variable j
		for (j = 0; j < numFiles; j += 1)
			string path = StringFromList(j, output_paths, "\r")
			if (strsearch(path, "shift", inf, 3) != -1)
				LoadWave/M/G/N=shiftwave path
			elseif (strsearch(path, "fixed", inf, 3) != -1)
				LoadWave/M/G/N=tfp_fixedwave path
			elseif (strsearch(path, "tFP", inf, 3) != -1)
				LoadWave/M/G/N=tfpwave path
			else
				LoadWave/M/G path
			endif
		endfor
	
	endif
	
	wave tfpwave0
	if (!ParamIsDefault(triggeroffset))
		tfpwave0 += triggeroffset
	endif
	tfpwave0 = 1/tfpwave0

	wave tfp_fixedwave0
	if (!ParamIsDefault(triggeroffset))
		tfp_fixedwave0 += triggeroffset
	endif
	tfp_fixedwave0 = 1/tfp_fixedwave0
	
	CorrectImg(Image)
end

function correctImg(image)
	Wave image
	Wave tfpWave0 = root:Images:tfpWave0
	Wave ShiftWave0 = root:Images:ShiftWave0
	Wave tfp_fixedWave0 = root:Images:tfp_fixedWave0
		
	SetDataFolder root:Images
	image[][][1] = tfpWave0[p][q]
	image[][][3] = shiftWave0[p][q]
	image[][][2] = tfp_fixedWave0[p][q]
end