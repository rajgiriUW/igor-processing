#pragma rtGlobals=1		// Use modern global access method.

//************************************************************************************
/// Obadiah and Raj's Load Matrix functions
//************************************************************************************

// 	These files are frequently used to load text files as 2-D matrices in Igor
//	They are not at all fast, but they work
//	If a file has "USAGE" in it, it is a function you can call
//	Otherwise, it is just used by something else in the code and you probably don't need to access it directly

Function LoadMatrix(keyword)
//	Primary function that calls LoadText2Matrix below
//	USAGE:
//			LoadMatrix("SW_")
//		This will load all files from the folder (Igor will prompt you to choose a folder) containing "SW_" in their filename.
//		Note that on the Mac the keywod is case-sensitive. I don't think it is on the PC
	String keyword;
	//Variable columns;
	
	Newpath path;
	PathInfo path
	LoadText2Matrix("path", keyword);
	
End

Function LoadIBWMat(keyword)
//	Same as above only this works with IBW files

	string keyword
	Newpath path
	Pathinfo path
	LoadIBW2Matrix("path",keyword)
end

Function LoadText2Matrix(path, keyword)
//This function will load all the text files from a specified folder who's names contain the keyword. 
//The file will be loaded as a single matrix					
													
	String path, keyword;								
	String filename, ColumnBaseName, ColumnName, OutputName;
	Variable index, index2, length, ColumnIndex;
	

	NVAR isPIFM
	
	index = 0;
	index2=0;
	ColumnIndex = 0;
	ColumnBaseName = "C"
	Make/O/N=1 JWave
	
	Make/O TwaveJ0;
	Killwaves TwaveJ0;
	Make/O TwaveL0;
	Killwaves TwaveL0;
	
	do
		//filename = TextFile($path, index);				//Set the value of the string variable "filename" to the name of the ith text file in the target folder.
		filename = IndexedFile($path, index, ".txt") 
		if(strlen(filename) == 0)							//Check to see that the the file name is real (non zero), so that the function will quit when it runs out of files to search
		
			Print "********Search and Load Complete*********"
			Print "Files Searched:"
			Print index
			Print " "
			Print "Files loaded and Displayed"
			Print index2
			Print "*************************************************"
				
			break;
		endif
		
		OutputName = RemoveEnding(filename);					// Remove 4 characters from the end of the "filename" string
		OutputName = RemoveEnding(OutputName);
		OutputName = RemoveEnding(OutputName);
		OutputName = RemoveEnding(OutputName);
			
		if (strsearch(filename, keyword, 0) != -1)			//Search "filename" for the keyword, and continue if it is found anywhere in the string.
		
				LoadWave/M/O/N=$OutputName/G/L={0, 0, 0, 0, 0}/P=$path filename; //Load the file as a matrix with all columns
							
				// correction added to make displaying the sloth wave stuff a lot easier
				filename = OutputName + "0"
				if (dimsize($filename,1) == 2)
					reverse/DIM=1 $Filename
				endif
				
				if (isPIFM == 1)
					Matrixtranspose $Filename
					ImageRotate/V $Filename
					Duplicate/O M_RotatedImage, $Filename
				endif
				
			index2 = index2 + 1;							//Increment the loaded files counter
		endif
		
		ColumnIndex = 0;
		index = index + 1;							//Increment the searched files counter
		
	While(1)
	
	KillWaves/Z TwaveJ0;
	KillWaves/Z TwaveL0;
	KillWaves/Z TwaveJ1;
	KillWaves/Z TwaveL1;
End

Function LoadIBW2Matrix(path, keyword)
//This function will load all the text files from a specified folder who's names contain the keyword. 
//The file will be loaded as a single matrix					
													
	String path, keyword;								
	String filename, ColumnBaseName, ColumnName, OutputName;
	Variable index, index2, length, ColumnIndex;
	
	
	index = 0;
	index2=0;
	ColumnIndex = 0;
	ColumnBaseName = "C"
	Make/O/N=1 JWave
	
	Make/O TwaveJ0;
	Killwaves TwaveJ0;
	Make/O TwaveL0;
	Killwaves TwaveL0;
	
	do
		//filename = TextFile($path, index);				//Set the value of the string variable "filename" to the name of the ith text file in the target folder.
		filename = IndexedFile($path, index, ".ibw") 
		if(strlen(filename) == 0)							//Check to see that the the file name is real (non zero), so that the function will quit when it runs out of files to search
		
			Print "********Search and Load Complete*********"
			Print "Files Searched:"
			Print index
			Print " "
			Print "Files loaded and Displayed"
			Print index2
			Print "*************************************************"
				
			break;
		endif
		
		filename = RemoveEnding(filename);					// Remove 4 characters from the end of the "filename" string
		filename = RemoveEnding(filename);
		filename = RemoveEnding(filename);
		filename = RemoveEnding(filename);

		string uniquewavename			
		if (strsearch(filename, keyword, 0) != -1)			//Search "filename" for the keyword, and continue if it is found anywhere in the string.
		
				LoadWave/Q/H/N=ScopeWave/P=$path filename; //Load the file as a matrix with all columns
				UniqueWaveName = uniqueName(filename,1,0)
				if (WaveExists(ScopeWaveAvg) )
					Rename ScopeWaveAvg, $UniqueWaveName
				else
					Rename ScopeWaveAnalysis, $UniqueWaveName
				endif
				// correction added to make displaying the sloth wave stuff a lot easier
				if (dimsize($filename,1) == 2)
					reverse/DIM=1 $Filename
				endif
				
			index2 = index2 + 1;							//Incriment the loaded files counter
		endif
		
		ColumnIndex = 0;
		index = index + 1;							//Incriment the searched files counter
		
	While(1)
	
	KillWaves/Z TwaveJ0;
	KillWaves/Z TwaveL0;
	KillWaves/Z TwaveJ1;
	KillWaves/Z TwaveL1;
End

Function LoadIBW2Analyze(scanpoints)
//This function will load all the text files frm a specified folder who's names contain the keyword. 
//The file will be loaded as a single matrix					
	
	Variable scanpoints
	
	Newpath path;
	PathInfo path
						
	String path, keyword;								
	String filename, ColumnBaseName, ColumnName, OutputName;
	Variable index, index2, length, ColumnIndex;
	
	
	index = 0;
	index2=0;
	ColumnIndex = 0;
	ColumnBaseName = "C"
	Make/O/N=1 JWave
	
	Make/O TwaveJ0;
	Killwaves TwaveJ0;
	Make/O TwaveL0;
	Killwaves TwaveL0;
	
	do
		//filename = TextFile($path, index);				//Set the value of the string variable "filename" to the name of the ith text file in the target folder.
		filename = IndexedFile($path, index, ".ibw") 
		if(strlen(filename) == 0)							//Check to see that the the file name is real (non zero), so that the function will quit when it runs out of files to search
		
			Print "********Search and Load Complete*********"
			Print "Files Searched:"
			Print index
			Print " "
			Print "Files loaded and Displayed"
			Print index2
			Print "*************************************************"
				
			break;
		endif
		
		filename = RemoveEnding(filename);					// Remove 4 characters from the end of the "filename" string
		filename = RemoveEnding(filename);
		filename = RemoveEnding(filename);
		filename = RemoveEnding(filename);

		string uniquewavename			
		if (strsearch(filename, keyword, 0) != -1)			//Search "filename" for the keyword, and continue if it is found anywhere in the string.
		
				LoadWave/Q/H/N=ScopeWave/P=$path filename; //Load the file as a matrix with all columns
				UniqueWaveName = uniqueName(filename,1,0)
				if (WaveExists(ScopeWaveAvg) )
					Rename ScopeWaveAvg, $UniqueWaveName
				else
					Rename ScopeWaveAnalysis, $UniqueWaveName
				endif
				// correction added to make displaying the sloth wave stuff a lot easier
				if (dimsize($filename,1) == 2)
					reverse/DIM=1 $Filename
				endif
				
			index2 = index2 + 1;							//Incriment the loaded files counter
		endif
		
		ColumnIndex = 0;
		index = index + 1;							//Incriment the searched files counter
		
	While(1)
	
	KillWaves/Z TwaveJ0;
	KillWaves/Z TwaveL0;
	KillWaves/Z TwaveJ1;
	KillWaves/Z TwaveL1;
End


#pragma rtGlobals=1		// Use modern global access method.

//************************************************************************************
/// Obadiah's Import Text Files as Waves Functions
//************************************************************************************

// 	These files are primarily used to load in a column of say, standard trEFM files
//	Note that this file is not used nearly as often as "LoadMatrix" from the other .ipf file
//	If a file has "USAGE" in it, it is a function you can call
//	Otherwise, it is just used by something else in the code and you probably don't need to access it directly


Function RunLoadText(keyword, columns, [colindex, lnindex])
//	Primary function that calls the LoadText() function below
//	If in doubt, use the LoadMatrix function instead of this
//	USAGE:
//			RunLoadText("SW_",2)
	String keyword;
	variable columns
	variable colindex		// which column to start on
	variable lnindex
	If (ParamIsDefault(colindex))
		colindex = 0
	endif
	If (ParamIsDefault(lnindex))
		lnindex = 0
	endif
	NVAR numcolumns;
	
	Newpath path;
	LoadText("path", keyword, columns, columnindex = colindex, lineindex = lnindex);
	
End


Function LoadText(path, keyword, columns, [columnindex, lineindex])																			
// This function will load all the text files from a specified folder who's names contain the keyword. 
// the "columns" variable specifies the number  of clumns in the text file to load

	String path, keyword;
	Variable columns;			
	variable columnindex		
	variable lineindex			
	If (ParamIsDefault(columnindex))
		columnindex = 0
	endif
	If (ParamIsDefault(lineindex))
		lineindex = 0
	endif
	String filename, ColumnBaseName, ColumnName, OutputName;
	Variable index, index2, length
	NVAR numColumns
	NVAR startColumn
	NVAR StartLine
	
	SVAR isPIFM
	
	index = 0;
	index2=0;
	
	ColumnBaseName = "C"
	Make/O/N=1 JWave
	
	Make/O TwaveJ0;
	Killwaves TwaveJ0;
	Make/O TwaveL0;
	Killwaves TwaveL0;
	
	variable idx_column = ColumnIndex	// iterate through columns loop
	variable idx_numcolumns = 0
	
	do
//		filename = TextFile($path, index);				//Set the value of the string variable "filename" to the name of the ith text file in the target folder.
		filename = IndexedFile($path, index, ".txt");		// This command necessary to work on Macs AND PCs, the previous line only works on PCs.
		
		if(strlen(filename) == 0)							//Check to see that the the file name is real (non zero), so that the function will quit when it runs out of files to search
			filename = IndexedFile($path, index, ".csv");
			if(strlen(filename) == 0)						
				Print "********Search and Load Complete*********"
				Print "Files Searched:"
				Print index
				Print " "
				Print "Files loaded and Displayed"
				Print index2
				Print "*************************************************"
				break;
			endif
		endif
		
		OutputName = RemoveEnding(filename);					// Remove 4 characters from the end of the "filename" string, e.g. removes ".txt" from "raj.txt"
		OutputName = RemoveEnding(OutputName);
		OutputName = RemoveEnding(OutputName);
		OutputName = RemoveEnding(OutputName);
			
		if (strsearch(filename, keyword, 0) != -1)			//Search "filename" for the keyword, and continue if it is found anywhere in the string.
		
			Do
			
				ColumnName = OutputName + ColumnBaseName + num2str(ColumnIndex);
				LoadWave/O/N=$ColumnName/G/L={0, lineindex, 0, (ColumnIndex), Columns}/P=$path/K=1 filename; //Load the nth column of the text file as a wave, and assign it the name found in the ClumnName string
				idx_column += 1;
				idx_numcolumns += 1
				
				string nm = ColumnName + "0"
				Wave tm = $nm
				nm = ColumnName + "1"
				Wave ym = $nm
				setscale/i x, tm[0], tm[numpnts(ym)-1], ym
				
			while(idx_numColumns < numColumns)
			
		
			index2 = index2 + 1;							//Incriment the loaded files counter
		endif
		
		idx_column = ColumnIndex
		index = index + 1;							//Incriment the searched files counter
		
	While(1)
	
	KillWaves/Z TwaveJ0;
	KillWaves/Z TwaveL0;
	KillWaves/Z TwaveJ1;
	KillWaves/Z TwaveL1;
End


/////////////////////////
//// Panel stuff
/////////////////////////

// Add loadpanelinit() when fixing the panel
Window loadpanel() : Panel
	loadpanelinit()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(839,133,1121,266)
	ShowTools/A
	SetVariable Keyword,pos={9,10},size={113,16},title="Keyword"
	SetVariable Keyword,limits={-inf,inf,0},value= loadname
	Button LoadText,pos={9,33},size={53,20},proc=LoadTextButton,title="Text Files"
	Button LoadText,fColor=(61440,61440,61440)
	Button LoadMatrix,pos={90,32},size={63,20},proc=LoadTextMatrix,title="Text Matrix"
	Button LoadMatrix,fColor=(61440,61440,61440)
	Button LoadMatrix1,pos={163,34},size={63,20},proc=LoadIBWMatrix,title="IBW Matrix"
	Button LoadMatrix1,fColor=(61440,61440,61440)
	SetVariable columns,pos={5,60},size={78,16},title="Columns"
	SetVariable columns,limits={1,inf,1},value= NumColumns
	CheckBox PiFM,pos={152,59},size={42,14},proc=CheckPIFM,title="PiFM",value= 1
	SetVariable columns1,pos={7,82},size={76,16},title="Start Col"
	SetVariable columns1,limits={0,inf,1},value= StartColumn
	SetVariable Lines,pos={7,104},size={77,16},title="Start Line"
	SetVariable Lines,limits={0,inf,1},value= StartLine
EndMacro

function loadpanelinit()
	Variable/G NumColumns = 0 
	Variable/G StartColumn = 0
	Variable/G StartLine = 0
end

Function LoadTextButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR loadname = root:loadname
	NVAR numcolumns = root:numColumns
	Nvar StartColumn = root:StartColumn
	NVAR startLine = root:StartLine

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			RunLoadtext(loadname, numcolumns, colindex=startcolumn, lnindex = startline)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function LoadTextMatrix(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	SVAR loadname
	NVAR isPIFM

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(isPIFM)
				LoadMatrix(loadname)

			else
				LoadMatrix(loadname)
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function LoadIBWMatrix(ba) : ButtonControl
	STRUCT WMButtonAction &ba
	String/G loadname

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			LoadIBWMat(loadname)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function CheckPIFM(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	Variable/G isPIFM

	switch( cba.eventCode )
		case 2: // mouse up
			isPIFM = cba.checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
