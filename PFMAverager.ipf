#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Raj - 9/2016; Phil's version was cluttered and inflexible

//AVERPFMLOOP(): Averages PFM Hysteresis loops and plots them (amplitude, phase1, phase2, and frequency).
//SAVEPFMLOOPS(): Saves .ibw's of the averaged amplitude, phase1, phase2, and frequency as well as a JPEG of the resulting stacked plot.

Function averPFMloop(loopname, [starttrace, ncycles])				//Enter the prefix for your PFM loops (i.e. "PFM20012") in quotes. It has to be in quotes since it's a string.

	String loopname
	variable starttrace // # of trace to start with. Each is separated by 100 points. 
	variable ncycles
	
	if (ParamIsDefault(starttrace))
		starttrace = 0
	endif
	
	Variable i,k
	String cycle = "Off"
	Wave Amp, Phas1, Phas2, Freq
	Wave BiasOn = $loopname + "BiasOn"
	
	variable len
	
	string Ampname, Phas1name, Phas2Name, FreqName

	if (ParamIsDefault (ncycles))
		ncycles = round(numpnts(BiasOn) / 100)//	- starttrace		//Calculates how many cycles of data there are
		len = 100
	else
		len =  numpnts(BiasOn) / ncycles
//		ncycles -= starttrace
	endif
	
	
	print "Number of cycles taken = ", ncycles		//For now this quantity is rounded because the PFM software seems to sometimes take 1 less point than it should, which results in, say, 9.99 cycles rather than 10.
	
	Duplicate/O/R=[0,len] BiasOn, $loopname + "Bias"
	Duplicate/O/R=[0,len] BiasOn, Bias

	Wave testwave

	variable lp = 0
	make/O/T cycles = {"Off", "On"}
	
	do

		cycle = cycles[lp]
		
	 	Wave Amp = $loopname + "Amp" + cycle
		Wave Phas1 = $loopname + "Phase" + cycle
		Wave Phas2 = $loopname + "Phas2" + cycle
		Wave Freq = $loopname + "Freq" + cycle
		
		averagewave(Amp, ncycles, st = starttrace)
		Ampname = loopname + "_AvAmp" + cycle
		Duplicate/O testwave, $Ampname
	
		averagewave(Phas1, ncycles, st = starttrace)
		Phas1Name = loopname + "_AvPhas1"+ cycle
		Duplicate/O testwave, $Phas1Name
	
		averagewave(Phas2, ncycles, st = starttrace)
		Phas2Name = loopname + "_AvPhas2" + cycle
		Duplicate/O testwave, $Phas2Name
	
		averagewave(Freq, ncycles, st = starttrace)
		FreqName = loopname + "_AvFreq" + cycle
		Duplicate/O testwave, $FreqName
	
		lp += 1
	
	while ( lp < numpnts(cycles) )
	
	string aname = loopname + "_AvAmp" + "Off"
	Duplicate/O $aname, AvAmp
	Duplicate/O Bias, BiasName
	string bname = loopname + "_Bias"
	Duplicate/O Bias, $bname
	
//Now the data is plotted into a window named PFMLoops. 

//	Display $AmpName vs Bias
//	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
//	ModifyGraph lsize=3, mirror=1
//	ModifyGraph tickUnit=1,prescaleExp(left)=12;DelayUpdate
//	Label left "Amplitude (pm)";DelayUpdate
//	Label bottom "Voltage (V)"
//	
//	Display $FreqName vs Bias
//	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
//	ModifyGraph lsize=3, mirror=1
//	ModifyGraph tickUnit=1,prescaleExp(left)=-3;DelayUpdate
//	Label left "Frequency (kHz)";DelayUpdate
//	Label bottom "Voltage (V)"

//	DoWindow PFMLoops
//	If(V_flag==0)
//		Display Ampconc vs Bias; AppendToGraph/R=L Freqconc vs Bias; AppendToGraph/L=B Phas1conc vs Bias; AppendToGraph/R=H Phas2conc vs Bias
//		ModifyGraph tick=2,mirror=1,minor=1,fSize=20,axThick=2,standoff=0;DelayUpdate
//		ModifyGraph axisEnab(left)={0,0.23},axisEnab(L)={0.25,0.48};DelayUpdate
//		ModifyGraph axisEnab(B)={0.5,0.73},axisEnab(H)={0.75,1},freePos(L)=0,freePos(B)=0;DelayUpdate
//		ModifyGraph freePos(H)=0
//		ModifyGraph width=432,height=576
//		ModifyGraph mode=0,lsize=2,rgb(Ampconc)=(0,0,0);DelayUpdate
//		ModifyGraph rgb(Phas1conc)=(0,0,52224),rgb(Phas2conc)=(29440,0,58880)
//		Label Bottom "Bias (V)"
//		Label Left "\u#2Amplitude (pm)"
//		Label L "\u#2Frequency (kHz)"
//		Label B "Phase 1 (°)"
//		Label H "Phase 2 (°)"
//		ModifyGraph lblPos(L)=200,lblPos(B)=200,lblPos(H)=200
//		DoWindow/N/C PFMLoops
//	else
//		DoUpdate/W=PFMLoops
//	endif
//	
End


//Save function. Just saves all the waves as .ibw's and the plot as a JPEG.

Function SavePFMLoops()

	Wave Bias, AmpConc, Phas1Conc, phas2Conc, freq1Conc

	DoWindow/F PFMLoops
	SavePICT/E=-6/B=288
	Save/C Bias,AmpConc,Phas1Conc,Phas2Conc,Freq1Conc

End

Function averagewave(inW, n, [st])
// Averages a wave over n cycles
//	st means "crop this many cycles from the front"

	Wave inW
	variable n
	variable st
	if (ParamIsDefault(st))
		st = 0
	endif
	
	variable len = numpnts(inW) / n//(n + st)	// +st to get right length
	
	Make/O/N=(len) testwave = 0
	
	variable lp = st
	Do
	
		Duplicate/O/R= [lp*len, (lp+1)*len-1] inW, tempwave
		
		if (lp == (n-1))	// last point is NaN so fix it by just setting to previous cycle's value
			tempwave[len-1] = inW[lp*len - 1]
		endif
		testwave = testwave[p] + tempwave[p]
		
			
		lp +=1
		
	While(lp < n)
	
	testwave /= (n - st)

end
