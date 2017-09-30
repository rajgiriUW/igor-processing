#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Written by PC and JH 06/2015

//This program will automatically shift an image to match another by finding the X and Y offsets that make the correlation between\
//the two images a maximum. Simply enter the names of the two images, with the second image being the one you want
//to shift, and the number of pixels you want the program to search in the x and  y directions.

// Shifts Image 2
Function FindShift(Image1, Image2, xlength, ylength, [displaygraphs])
	
	Wave Image1, Image2
	Variable xlength, ylength
	variable DisplayGraphs
	
	Make/O/N=((xlength*2+1),(ylength*2+1)) pearsonwave							//Makes a matrix to store the pearson corellation coefficient values
	Variable i,j
	
	If (!ParamIsDefault(DisplayGraphs))
		DisplayShifts(PearsonWave)
	endif
	
	for(i = -ylength; i <= ylength; i += 1)											//This 'for loop' moves the second image around by essentially raster scanning it over the number of pixels you designate at the beginning
		for( j = -xlength; j <= xlength; j += 1)
				pearsonwave[j+xlength][i+ylength] =  Shift(Image1, Image2, j, i)	//Writes the Pearson coefficient to the Pearson matrix. Note that we are calling a second function, the actual shift and calculation function, in this step (see below).
		endfor
	endfor	
	ImageStats/Q pearsonwave												//Finds the maximum Pearson coefficient and prints the value and matrix location
	
	Variable/G FinalXOffset, FinalYOffset											//Defines the final X and Y offset based on the max Pearson coefficient
	FinalXOffset = V_maxRowLoc - XLength
	FinalYOffset = V_maxColLoc - YLength
	
	Shift(Image1, Image2, FinalXOffset, FinalYOffset)								//One final shift of image 2 into the optimal X and Y position
	
	If (!ParamIsDefault(DisplayGraphs))
		Wave M_OffsetImage
		DisplayMOffsetImage(M_OffsetImage)
	endif
	
	Print "Offset Image 2 by x =",FinalXOffset,",y =",FinalYOffset					//Prints the final X and Y Offset values to the cmd window
	
End

//The following function does the actual image shifting and Pearson correlation coefficient calculation.

Function Shift(Image1, Image2, XOffset,YOffset)									//The image names and X and YOffsets are fed to it automatically from the FindShift function									

	Wave Image1, Image2
	Variable XOffset, YOffset

	Imagetransform/IOFF={XOffset,YOffset,0} offsetimage Image2					//Offsets image 2 by XOffset and YOffset

	Wave M_offsetimage														//M_OffsetImage is the name of the resulting wave from the Imagetransform command

	Variable rows, cols

	rows = dimsize(image1, 0)													//Finds the number of rows and columns in the images being analyzed
	cols = dimsize(image1, 1)

	If(XOffset < 0 && YOffset >= 0)												//This chunk of code just figures out how to crop the images based on whether the X or Y offset is positive or negative or any possible combination of the two
		Duplicate/O/r=[0,cols+XOffset][YOffset,*] Image1 Image1Shrink
		Duplicate/O/r=[0,cols+XOffset][YOffset,*] M_offsetimage Image2Shrink
	elseif(XOffset < 0 && YOffset <= 0)
		Duplicate/O/r=[0,cols+XOffset][0,rows+YOffset] Image1 Image1Shrink
		Duplicate/O/r=[0,cols+XOffset][0,rows+YOffset] M_offsetimage Image2Shrink
	elseif(XOffset >= 0 && YOffset >= 0)
		Duplicate/O/r=[XOffset,*][YOffset,*] Image1 Image1Shrink
		Duplicate/O/r=[XOffset,*][YOffset,*] M_offsetimage Image2Shrink
	elseif(XOffset >= 0 && YOffset <= 0)
		Duplicate/O/r=[XOffset,*][0,rows+YOffset] Image1 Image1Shrink
		Duplicate/O/r=[XOffset,*][0,rows+YOffset] M_offsetimage Image2Shrink
	endif

	Variable i,j
	Variable rows_small, cols_small, length

	rows_small = dimsize(Image1Shrink,0)										//Finds the number of rows and columns in the cropped images
	cols_small = dimsize(Image1Shrink, 1)

	length = rows_small*cols_small											//Decides how long the 1-dimensional wave needs to be for doing a Pearson coefficient calculation

	Make/O/N=(length) Image1_1D												//Makes the 1D waves of the correct number points
	Make/O/N=(length) Image2_1D

	for(j = 0; j < cols_small; j += 1)												//This 'for loop' converts 2D waves into 1D waves by taking each subsequent column and putting it underneath the first column
		for(i = 0; i < rows_small; i += 1)
			Image1_1D[(rows_small)*j+i] = Image1Shrink[i][j]
		endfor
	endfor

	for(j = 0; j < cols_small; j += 1)												//Same thing but for the second cropped image
		for(i = 0; i < rows_small; i += 1)
			Image2_1D[(rows_small)*j+i] = Image2Shrink[i][j]
		endfor
	endfor
	
	variable pearsonr = statscorrelation(Image1_1D, Image2_1D)					//Calculates the Pearson correlation coefficient

	return pearsonr															//Returns the resulting Pearson value so that the FindShift function can then write it into the Pearson Matrix.
	
End

// Display Stuff
Function DisplayMOffsetImage(M_offsetimage)
	Wave M_offsetimage
	DoWindow/F M_OffsetImage0												//Creates or updates an image of the offset image
	If(V_flag ==  0)
		Newimage/F/K=1/N=M_offsetimage0 M_offsetimage
		DoWindow/C M_OffsetImage0
	Else
		DoUpdate/W=M_OffsetImage0
	Endif
end

Function DisplayShifts(PearsonWave)
	Wave PearsonWave
	
	DoWindow/F PearsonWave0												//Creates or updates an image with the Pearson coefficient matrix									
	If(V_flag ==  0)
		Newimage/F/K=1/N=PearsonWave0 PearsonWave
		DoWindow/C PearsonWave0
	Else
		DoUpdate/W=PearsonWave0
	Endif
	
	Wave Image1Shrink, Image2Shrink											
	
	DoWindow/F Image1Shrink0												//Creates or updates an image of the final cropped first image									
	If(V_flag ==  0)
		Newimage/F/K=1/N=Image1Shrink0 Image1Shrink
		DoWindow/C Image1Shrink0
	Else
		DoUpdate/W=Image1Shrink0
	Endif
	
	DoWindow/F Image2Shrink0												//Creates or updates an image of the final cropped second image									
	If(V_flag ==  0)
		Newimage/F/K=1/N=Image2Shrink0 Image2Shrink
		DoWindow/C Image2Shrink0
	Else
		DoUpdate/W=Image2Shrink0
	Endif
	
	Wave Image1_1D, Image2_1D
	
	DoWindow/F ScatterPlot0													//Creates or updates a scatter plot of the two images vs each other
	If(V_flag == 0)
		Display Image1_1D vs Image2_1D
		ModifyGraph mode=2,rgb=(0,43520,65280)
		ModifyGraph width=216,height=216
		DoWindow/C ScatterPlot0
	Else
		DoUpdate/W=ScatterPlot0
		ModifyGraph mode=2,rgb=(0,43520,65280)
	Endif
end

// GUI Stuff - Remember to add ShiftPanelInit() if you edit the panel
Window shiftpanel() : Panel
	ShiftPanelInit()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(1971,72,2271,290)
	ShowTools/A
	SetVariable setvar0,pos={7,33},size={79,16},title="Layer1"
	SetVariable setvar0,limits={0,inf,1},value= Layer1
	SetVariable setvar1,pos={8,79},size={79,16},title="Layer2"
	SetVariable setvar1,limits={0,inf,1},value= Layer2
	Button button0,pos={11,182},size={88,26},proc=ShiftProc,title="Shift"
	TitleBox title0,pos={132,132},size={50,20}
	SetVariable setvar2,pos={10,156},size={150,16},title="Apply to Which Layer"
	SetVariable setvar2,limits={0,inf,1},value= TargetLayer
	SetVariable setvar3,pos={7,14},size={280,16},title="Image 1: Reference"
	SetVariable setvar3,limits={-inf,inf,0},value= Path1
	SetVariable setvar4,pos={8,59},size={279,16},title="Image 2: Will Shift"
	SetVariable setvar4,limits={-inf,inf,0},value= Path2
	SetVariable setvar5,pos={9,127},size={118,16},title="Y-Search Pixels"
	SetVariable setvar5,limits={0,64,0},value= Ysearch
	SetVariable setvar6,pos={9,108},size={118,16},title="X-Search Pixels"
	SetVariable setvar6,limits={0,256,0},value= Xsearch
	SetVariable setvar7,pos={141,107},size={65,16},title="X-Offset",frame=0
	SetVariable setvar7,limits={0,256,0},value= FinalXOffset,noedit= 1
	SetVariable setvar8,pos={140,127},size={66,16},title="Y-Offset",frame=0
	SetVariable setvar8,limits={0,64,0},value= FinalYOffset,noedit= 1
	SetVariable setvar9,pos={201,194},size={76,16},disable=1,title=">  Working"
	SetVariable setvar9,frame=0,fStyle=1,limits={0,256,0}
	Button button1,pos={127,185},size={60,20},proc=RestoreButtonProc,title="Restore"
	SetVariable setvar07,pos={212,106},size={73,16},title="Manual X"
	SetVariable setvar07,limits={-256,256,0},value= ManualX
	SetVariable setvar08,pos={212,127},size={73,16},title="Manual Y"
	SetVariable setvar08,limits={-256,256,0},value= ManualY
	Button button2,pos={214,148},size={72,19},proc=ManualShiftButtonProc,title="Manual Shift"
EndMacro

Function ShiftPanelInit()
	Variable/G Layer1 = 0 
	Variable/G Layer2 = 0
	Variable/G TargetLayer = 1
	Variable/G Xsearch = 10 
	Variable/G Ysearch = 10
	Variable/G FinalXOffset = 0
	Variable/G FinalYoffset = 0
	Variable/G ManualX = 0
	Variable/G ManualY = 0
	
	String/G Path1
	String/G Path2

end

Function ShiftProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up

			SetDataFolder root:
			NVAR Layer1, Layer2, TargetLayer
			NVAR Xsearch, Ysearch, FinalXOffset, FinalYOffset
	
			SVAR Path1 = root:Path1
			SVAR Path2 = root:Path2
	
			// Check if part of an Asylum image stack or not
			if (dimsize($Path1, 3) != 0)
				Duplicate/O/R=[][][Layer1] $Path1, Image1
				Duplicate/O/R=[][][Layer2] $Path2, Image2
				Duplicate/O/R=[][][TargetLayer] $Path2, TargetShift
				Redimension/N=(-1,-1) TargetShift
			else
				Duplicate/O $Path1, Image1
				Duplicate/O $Path2, Image2
				Duplicate/O $Path2, TargetShift
			endif
			
			SetVariable setvar9 disable = 0
			DoUpdate
			
			FindShift(Image1, Image2, Xsearch, Ysearch)			

			SetVariable setvar9 disable = 1
			DoUpdate
		
			Imagetransform/IOFF={FinalXOffset,FinalYOffset,0} offsetimage TargetShift		
			Wave M_offsetimage
		
			Wave Target = $Path2
			Target[][][TargetLayer] = M_OffsetImage[p][q]
		
			// change 0's to NaNs
			variable r = dimsize(M_OffsetImage,0)
			variable c = dimsize(M_OffsetImage,1)

			if (FinalXOffset < 0)
				Target[r + FinalXOffset, r-1][][TargetLayer] = NaN
			else
				Target[0, FinalXOffset][][TargetLayer] = NaN
			endif
			
			if (FinalYOffset < 0)
				Target[][c + FinalYOffset, c-1][TargetLayer] = NaN
			else
				Target[][0, FinalYOffset][TargetLayer] = NaN
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RestoreButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			Wave TargetShift
			NVAR TargetLayer
			SVAR Path2
			
			Wave Target = $Path2
			Target[][][TargetLayer] = TargetShift[p][q]
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ManualShiftButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			NVAR Layer1 = root:Layer1
			NVAR Layer2 = root:Layer2
			NVAR TargetLayer = root:TargetLayer
			NVAR ManualX = root:ManualX
			NVAR ManualY = root:ManualY
		
			SVAR Path1 = root:Path1
			SVAR Path2 = root:Path2
	
			Duplicate/O/R=[][][Layer2] $Path2, Image2
			Duplicate/O/R=[][][TargetLayer] $Path2, TargetShift
			Redimension/N=(-1,-1) TargetShift
			
			Shift(Image2, TargetShift, ManualX, ManualY)
			Wave M_offsetimage
		
			Wave Target = $Path2
			Target[][][TargetLayer] = M_OffsetImage[p][q]
			
			variable r = dimsize(M_OffsetImage,0)
			variable c = dimsize(M_OffsetImage,1)
			
			// change 0's to NaNs
			if (manualX < 0)
				M_OffsetImage[r + manualX, r-1][] = NaN
			else
				M_OffsetImage[0, manualX][] = NaN
			endif
			
			if (manualY < 0)
				M_OffsetImage[][c + manualY, c-1] = NaN
			else
				M_OffsetImage[][0, manualY] = NaN
			endif
			
			Target[][][TargetLayer] = M_OffsetImage[p][q]
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

// Make a 2D into a 1-D Wave by columns, then rows

Function Make1D(inW)
	Wave inW
	
	variable r = dimsize(inW, 0)
	variable c = dimsize(inW, 1)
	
	Make/O/N=(r*c) outW
	
	variable i, j
	
	for (r = 0; r < dimsize(inW, 0); r += 1)
		for (c=0; c < dimsize(inW, 1); c += 1)
			outW[r * dimsize(inW,1) + c] = inW[r][c]
		endfor
	endfor	
	
end