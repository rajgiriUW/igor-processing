#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//MAKEIMAGE(): will recreate trEFM chargingrate, frequencyshift, and Chi2 images using .ibw data
//stored in a folder. You can choose where to start and stop the fits by entering the times you want in units of milliseconds (i.e. 8.12 to 12 ms).


//AVER(): will average the raw frequency shifts of a single pixel and then display the averaged frequency shift trace that 
//was used to make a data point in the image. This is useful for understanding why a pixel in the image is noisy/bad.


Function MakeImage(Fitstart,Fitstop, numavgs,scanpoints,scanlines, [twoexp])

	Variable Fitstart, Fitstop, numavgs, scanpoints, scanlines, twoexp
	Wave readwavefreq
	Wave cycletime
	
	GetFileFolderInfo/Q/D
	NewPath/C/M="Please Select Folder"/O/Q/Z FolderPath, S_Path
	
	Fitstart =  round((fitstart * 1e-3) * (50000 / 1))
	print fitstart
	Fitstop = round((fitstop * 1e-3) * (50000 / 1))
	print fitstop
	
	
	
	Make/O/N = (scanpoints, scanlines) ChargingRate_user, FrequencyOffset_user, Chi2Image_user, ChargingRateK2_user
		Chi2Image_user=0
	
	Variable V_FitOptions, j = 0, m, i = 0, k
		
	Make/O/N = (Fitstop - Fitstart) ReadWaveFreqtemp, CycleTime
	
	k=0
	do
			CycleTime[k]=k * (1/50000) * 1  
			k += 1
		while (k < Fitstop-Fitstart)	
	
	do
		j=0
		if (i < 10)
			LoadWave/O/H/P=FolderPath "trEFM_000" + num2str(i) + ".ibw"
		elseif (i < 100)
			LoadWave/O/H/P=FolderPath "trEFM_00" + num2str(i) + ".ibw"
		else
			LoadWave/O/H/P=FolderPath "trEFM_0" + num2str(i) + ".ibw"
		endif
	
			do
				
				V_FitOptions = 4
				ReadWaveFreqTemp = 0
				k = 0
				m = j*800*numavgs
	
				Make/O/N = (Fitstop - Fitstart, numavgs) ReadwaveFreqAVG
				variable avgloopp = 0
				do
					Duplicate/O/R=[m+Fitstart, m+Fitstop] ReadwaveFreq, Temp1
					ReadWaveFreqAvg[][avgloopp] = Temp1[p] - 500
				
					avgloopp += 1
	
					m += 800
				while (avgloopp < numavgs)
				
				MatrixOp/O readwavefreqtemp = sumrows(readwavefreqavg) / numcols(ReadWaveFreqAvg)
				
	
				make/o/n=3 W_sigma
				Make/O/N=3 W_Coef
				// Constraints added to improve fitting routines
				Make/O/T/N=1 T_Constraints
				//T_Constraints[0] = {"K1>0","K2>(1/100000)", "K2<10"}
				
				if (ParamIsDefault(twoexp) )
					T_Constraints[0] = {"K2>(1/100000)", "K2<10"}
					curvefit/N=1/Q exp_XOffset, readwavefreqtemp  /x=CycleTime /C=T_Constraints
					FrequencyOffset_user[scanpoints-j-1][i]=W_Coef[1]
					ChargingRate_user[scanpoints-j-1][i]=1/(W_Coef[2])
					Chi2Image_user[scanpoints-j-1][i]=W_sigma[2]
				else
					T_Constraints[0] = {"K2>(1/100000)", "K2<10"}
					curvefit/N=1/Q exp_XOffset, readwavefreqtemp  /x=CycleTime /C=T_Constraints
					T_Constraints[0] = {"K1 < 0","K2 > 0","K2 < 10000","K3 < 0","K4 > 0","K4 < 10000"}
					Make/O/N=5 FitCoeff
					FitCoeff[0] = {W_Coef[0], W_Coef[1], W_Coef[2], W_Coef[1], W_Coef[2]*5}
					curvefit/N=1/Q dblexp_XOffset kwcWave=FitCoeff, readwavefreqtemp  /x=CycleTime /C=T_Constraints
					FrequencyOffset_user[scanpoints-j-1][i]=FitCoeff[1]
					ChargingRateK2_user[scanpoints-j-1][i]=1/FitCoeff[4]
					ChargingRate_user[scanpoints-j-1][i]=1/(FitCoeff[2])
					Chi2Image_user[scanpoints-j-1][i]=W_sigma[2]
		
				endif
				//curvefit/N=1/Q exp_XOffset, readwavefreqtemp /C=T_Constraints
	
				//display readwavefreqtemp
				//abort
				
				
				j+=1
			while (j < scanpoints)
	
		i+=1
	while(i<scanlines)

end

Function aver(pixel,nmavgs,scanpoints)			//Enter which pixel you want analyzed, the number averages per pixel, and how many scan points in a line

	Variable pixel, nmavgs, scanpoints
	Variable i,k
	Wave readwavefreq
	
	GetFileFolderInfo/Q									//Prompts user for file path
		if(V_flag<0)
			return -1										//Aborts if user canceled
		elseif(V_flag==0 && V_isFile==1)
			String filePath = S_Path						//Creates symbolic pathname for file location
		endif
	LoadWave/Q/N=ReadWaveFreq/O filePath
	
	i=(scanpoints - pixel)*nmavgs*800 -  nmavgs*800			//This calculates the starting point of the pixel in point-space
	
	Make/o/n= (800,nmavgs) Test2							//Make a matrix 800 points long (total time of each loop) and averages/point wide
	Make/o/n=800 Test3									//Make wave for later averaging Test2 into a 1-D wave.
	
		k=i+799											//End point is 799 points later than i (only when total time is 800 points)
		Variable avgloo=0									//Start averages at zero
		
				do
				
					Duplicate/O/R = [i,k] ReadwaveFreq, Test1		//Take data from ReadWaveFreq between points i and k
					test2[][avgloo] = Test1[p] - 500					//Subtract 500 from the frequency (scaling)
	
					avgloo += 1									//Step to next average
	
					i += 800										//Step i
					k += 800									//Step k
				while (avgloo < nmavgs)							//Do this routine until we reach the number of averages in one pixel
				
				MatrixOp/O Test3 = sumrows(test2) / numcols(test2)	//Average the columns in Test2 into a single column in Test3
	
	Make/O/N=800 TimeAnalysis						//When you fit data, the x-scaling will be in SECONDS, the axis is just set to look like milliseconds
	TimeAnalysis = x*20E-6
	
	
	DoWindow/F FreqShiftPlot
	If(V_flag == 0)
		Display Test3 vs TimeAnalysis
		ModifyGraph tick=2,mirror=1,fSize=16,standoff=0
		ModifyGraph width=360,height=288
		Label bottom "\\u#2Time (ms)"
		Label left "Frequency Shift (Hz)"
	//	ModifyGraph wbRGB=(40000,40000,40000),gbRGB=(52224,52224,52224)
		DoWindow/C FreqShiftPlot
	else
		DoUpdate/W=FreqShiftPlot
	endif

End

function averageline(pixels, numavgs)
	variable pixels
	variable numavgs
	wave ReadWaveFreq
	variable m = 0
	Make/O/N = 800 ReadwaveFreqAVG = 0

	variable avgloopp = 0
	do
		Duplicate/O/R=[m, m+799] ReadwaveFreq, Temp1
		ReadWaveFreqAvg[0,799] += Temp1[p]
			
		avgloopp += 1

		m += 800
	while (avgloopp < pixels*numavgs)
	
	ReadWaveFreqAvg[] /= (pixels*numavgs)
	ReadwaveFreqAvg[] -= 500
	setscale/I x, 0, 16e-3, readwavefreqavg

end
