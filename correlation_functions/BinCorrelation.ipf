#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function BinCorrelation(yaxisImg, xaxisImg, numBins)
	Wave yaxisImg, xaxisImg
	variable numBins
	
	string yn = "yAxisImg"
	string xn = "xAxisImg"
	
	Duplicate/O yaxisImg, $yn
	Duplicate/O xaxisImg, $xn
	
	variable y_r = dimsize(yaxisimg, 0)
	variable y_c = dimsize(yaxisimg, 1)
	
	variable x_r = dimsize(xaxisimg, 0)
	variable x_c = dimsize(xaxisimg, 1)
	
	KillWaves/Z XBins, XBins_idx, XAxisImg_Idx, YBinAvg, YBinSDev

	// Takes image stats. Divides from min to max bins in ~even amounts	
	ImageStats/Q xaxisimg

	variable startbin = V_min
	variable stopbin = V_max

	// Calculate Pearson's coefficient manually since we're traversing array and might have NaNs
	variable X_avg = V_avg
	
	ImageStats/Q yaxisimg
	variable Y_avg = V_avg
	print "V_min = ", V_min
	print "V_max = ", V_max
	
	variable PearNum = 0		// numerator (A-<A>)(B-<B>)
	variable PearDenomX = 0	// sum (A-<A>)^2
	variable PearDenomY = 0	// sum(B-<B>)^2

	// XBins is the X-Axis histogram
	// XBins_idx is a 1-D wave of the bin values
	// The +1 is needed because each bin spans n to n+1. 
	make/O/N=(numbins+1) XBins = 0	
	setscale/I x startbin, stopbin, XBins
	
	Make/O/N=(numbins+1) XBins_idx = DimOffset(XBins,0) + p*DimDelta(XBins,0)	
	
	// Then algorithm goes into X and assigns each pixel to a bin
	// For each bin...
	// 	Finds y-axisimag pixels for that bin, saves into a wave
	// 	Takes average/sdev of the Y-pixel values
	
	// 2-D matrix of bin locations
	//	Then, can use y_img (find values = specific bin) and add to a wave
	make/O/N=(x_r, x_c) xAxisImg_idx = NaN
	
	variable i, j
	for (i = 0; i < x_r; i+=1)

		for (j = 0; j < x_c; j+=1)
		
			// Finds which bin to assign to (XBins_idx contains the bin values in a wave)
			FindLevel/Q XBins_idx, XAxisImg[i][j]

			// for ensuring maximum values fall into the valid bin			
			if (floor(V_levelX) == numbins)
				
				V_levelX -= 1

			endif
					
			if (numType(V_LevelX) != 2)

				XBins[floor(V_levelX)] += 1				// increments appropriate bin
				
				
				if (numtype(YAxisImg[i][j]) != 2)
				
					PearNum += (XAxisImg[i][j] - X_avg) * (YAxisImg[i][j] - Y_avg)
					PearDenomX += (XAxisImg[i][j] - X_avg)^2
					PearDenomY += (YAxisImg[i][j] - Y_avg)^2
					
				endif

			endif
				
			XAxisImg_idx[i][j] = floor(V_levelX)		// sets bin location matrix to the bin INDEX, not value

		endfor
		
	endfor
	
	// Pearson Coefficient
	Print "Pearson Coefficient = ", PearNum / (sqrt(PearDenomX * PearDenomY))
	
	
	// Create a Wave for each Bin, add the YAxisImg value to each Wave
	//	This is called YBinsWaveX where X is a number
	i = 0
	j = 0
	
	string name
	for (i = 0; i <numbins; i+= 1)

		name = "YBinsWave" + num2str(i)
		KillWaves/Z $name
		Make/O/N=(XBins[i]) $name = 0
		
	endfor

	// Populates the YBin Waves
	for (i = 0; i < x_r; i+=1)

		for (j = 0; j < x_c; j+=1)
			
			if (numtype(XAxisImg_idx[i][j]) != 2)

				name = "YBinsWave" + num2str(XAxisImg_idx[i][j])
				FindValue/V=0/T=1e-18 $name		// find first entry to add YAxisImg value
				Wave w = $name		// weird Igor quirk, can't directly say $name[V_Value]
				w[V_value] = YAxisImg[i][j]
			
			endif

		endfor
		
	endfor
	
	Make/O/N=(numbins) YBinAvg, YBinSdev, YBinsize
	ImageStats yaxisimg
	variable imgsize = V_npnts
	print imgsize
	
	
	for (i = 0; i <numbins; i+= 1)
	
		name = "YBinsWave" + num2str(i)
		WaveStats/Q $name
		YBinAvg[i] = V_avg
		YBinSdev[i] = V_sdev
		YBinsize[i] = V_npnts 
	
	endfor
	
end

// Makes sets of ROI Masks to use in images based on above
Function MakeROIMasks(XAxisImg_Idx, numbins, [xscale, yscale])

	Wave XAxisImg_Idx
	variable numbins
	variable xscale, yscale
	
	variable r = dimsize(XAXisImg_idx,0)
	variable c= dimsize(XAxisImg_idx,1)
	
	variable i, j, k 
	string name
	for (i = 0; i <numbins; i+= 1)

		name = "ROIMask" + num2str(i)
		Make/O/N=(r,c) $name = 0	// better as NaN...
		
	endfor

	for (i = 0; i < numbins; i += 1)

		name = "ROIMask" + num2str(i)
		Wave w = $name

		for (j = 0; j < r; j+=1)

			for (k = 0; k < c; k+=1)

				if (XAxisImg_idx[j][k] == i)
					w[j][k] = 1
				endif

			endfor
			
		endfor
		
		NanMask($name)
		Wave ROIMask
		Duplicate/O ROIMask, $name
		
		if (!PAramIsDefault(xscale))
			Setscale/I x, 0, xscale, "m", $name
			Setscale/I y, 0, yscale, "m", $name
		endif
		
	endfor
	
end

// "Heat" map
function makeHistMap(numbins)
	variable numbins	// number of ROI Masks
	
	Make/O/N=(numbins, numbins) YHistImg		// histogram image
	Make/O/N=(numbins, numbins) YHistNormImg
	Make/O/N=(numbins) HistWave
	variable i
	string name
	
	name = "YBinsWave" + num2str(floor(numbins/2))
	Wave w = $name
	wavestats/Q w
	print "V_min = ", V_min
	print "V_max= ", V_max
	variable mn = V_min
	variable mx = V_max
	
	for (i = 0; i <numbins; i +=1)
	
		name = "YBinsWave" + num2str(i)
		Wave w = $name
		Wavestats/q w
		make/O/N=(V_npnts + 2) tempwave		// dummy adds a V_min and V_max to each slice
		tempwave[1, V_npnts] = w[p-1]
		tempwave[0] = mn//V_min
		tempwave[V_npnts+1] = mx//V_max
		Histogram/B=1 w, HistWave
		YHistimg[][i] = HistWave[p]

		// remove the "dummy" values from the counts
		YHistimg[0][i] -=1
		YHistImg[numbins-1][i] -= 1

		YHistNormImg[][i] = HistWave[p]
		
		// Scale from 0 to 1
		Duplicate/O/R=[][i] YHistimg, Tempwave
		WaveStats/Q TempWave
		YHistNormimg[][i] -= V_min
		YHistNormImg[][i] /= (V_max - V_min)
		
	endfor

end

// Include BinPanelInit()
Window BinCorrelationPanel() : Panel
	BinPanelInit()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(771,88,1061,266)
	ShowTools/A
	SetVariable setX,pos={17,13},size={227,16},title="X-Axis"
	SetVariable setX,limits={-inf,inf,0},value= XImage
	SetVariable setY,pos={17,55},size={225,16},title="Y-Axis"
	SetVariable setY,limits={-inf,inf,0},value= YImage
	Button BinCorrelate,pos={11,155},size={83,22},proc=BinCorrelationProc,title="Bin Correlation"
	SetVariable Layer,pos={16,34},size={93,16},title="Layer X"
	SetVariable Layer,limits={0,inf,1},value= XLayer
	SetVariable Layer1,pos={16,77},size={93,16},title="Layer Y"
	SetVariable Layer1,limits={0,inf,1},value= YLayer
	SetVariable NumBins,pos={103,156},size={93,16},title="# Bins"
	SetVariable NumBins,limits={0,inf,1},value= NumBins
	SetVariable CropLeft,pos={130,76},size={113,16},title="Crop Left Pixels"
	SetVariable CropLeft,limits={0,inf,0},value= LeftCrop
	SetVariable CropRight,pos={122,94},size={121,16},title="Crop Right Pixels"
	SetVariable CropRight,limits={0,inf,0},value= RightCrop
	SetVariable CropTop,pos={130,113},size={113,16},title="Crop Top Pixels"
	SetVariable CropTop,limits={0,inf,0},value= TopCrop
	SetVariable CropBot,pos={114,131},size={129,16},title="Crop Bottom Pixels"
	SetVariable CropBot,limits={0,inf,0},value= BotCrop
	CheckBox UseXMask,pos={14,111},size={91,14},proc=UseXARMaskc,title="Use AR XMask"
	CheckBox UseXMask,value= 1
	CheckBox UseYMask,pos={14,128},size={91,14},proc=UseYARMaskc,title="Use AR YMask"
	CheckBox UseYMask,value= 1
EndMacro

function BinPanelInit()
	SetDataFolder Root:
	Variable/G XLayer = 0
	Variable/G YLayer = 0
	Variable/G NumBins = 15
	
	Variable/G TopCrop = 0
	Variable/G BotCrop = 0
	Variable/G LeftCrop = 0
	Variable/G RightCrop = 0
	
	Variable/G MaskedX = 0
	Variable/G MaskedY = 0
	
	String/G XImage = "root:Images:XImage"
	String/G YImage = "root:Images:YImage"
end

Function BinCorrelationProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			setDataFolder root:
			NVAR XLayer, YLayer, NumBins
			SVAR XImage = root:XImage
			SVAR YImage = root:YImage
		
			NVAR TopCrop, LeftCrop, RightCrop, BotCrop
			NVAR MaskedX, MaskedY
			
			// Check if part of an Asylum image stack or not
			SetDataFolder root:Images
			if (dimsize($Ximage, 2) != 0)
				Duplicate/O/R=[][][XLayer] $XImage, Xim
			else
				Duplicate/O $XImage, Xim
			endif
			
			if (dimsize($Yimage, 2) != 0)
				Duplicate/O/R=[][][YLayer] $YImage, Yim
			else
				Duplicate/O $YImage, Yim
			endif
			
			variable r = dimsize(Xim, 1)
			variable c = dimsize(Xim, 0)
			
			Xim[0,LeftCrop][] = NaN
			Xim[][0,BotCrop] = NaN
			Xim[c-RightCrop-1, c-1][] = NaN
			Xim[][r-TopCrop-1, r-1] = NaN

			Yim[0,LeftCrop][] = NaN
			Yim[][0,BotCrop] = NaN
			Yim[c-RightCrop-1, c-1][] = NaN
			Yim[][r-TopCrop-1, r-1] = NaN
			
			
			
			if (MaskedX)
			// Note uses ClipBoard0; this is hard-coded
				wave maskIn = root:Images:Masks:ClipBoard0
				NaNMask(maskIn)
				Wave ROIMask				
				XIm[][] *= RoiMask
				
			endif
			
			if (MaskedY)
			// Note uses ClipBoard1; this is hard-coded
				wave maskIn = root:Images:Masks:ClipBoard1
				NaNMask(maskIn)
				Wave ROIMask				
				XIm[][] *= RoiMask
				
			endif
			
			BinCorrelation(Yim, Xim, NumBins)
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


// This uses the "Copy Mask" from AR menu and applies to the Young's Modulus image
// Uses CLIPBOARD0 !!!
Function UseXARMaskc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			NVAR maskedX = root:maskedX
			maskedX = checked
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

// This uses the "Copy Mask" from AR menu and applies to the ESM Modulus image
// Uses CLIPBOARD1 !!!
Function UseYARMaskc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			
			NVAR maskedY = root:maskedY
			maskedY = checked
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

function qpbin()

	Wave Ybinavg, YBinsdev, XBins, XBins_idx

	display YBinAvg vs XBins_idx
	ModifyGraph mode=3,marker=16;DelayUpdate
	ErrorBars/T=3/L=3/Y=8 YBinAvg Y,wave=(YBinSdev,YBinSdev)
	ModifyGraph mirror=1,fStyle=1,fSize=22,axThick=3,prescaleExp(left)=12;DelayUpdate
	ModifyGraph prescaleExp(bottom)=-3,font="Arial",axRGB(left)=(65280,0,0);DelayUpdate
	ModifyGraph tlblRGB(left)=(65280,0,0),alblRGB(left)=(65280,0,0);DelayUpdate
	Label left "ESM Amplitude (pm)";DelayUpdate
	Label bottom "AM-FM Frequency (kHz)"
	appendtograph/R XBins vs XBins_idx
	ModifyGraph mode(XBins)=7,lsize(XBins)=3,hbFill(XBins)=4;DelayUpdate
	ModifyGraph rgb(XBins)=(24576,24576,65280)
	ModifyGraph fStyle=1,fSize=22,axThick=3,font="Arial",axRGB(right)=(0,12800,52224);DelayUpdate
	ModifyGraph tlblRGB(right)=(0,12800,52224),alblRGB(right)=(0,12800,52224);DelayUpdate
	Label right "AM-FM Counts (a.u.)"

end

// for verifying that the correlation graph scatter plot and my version match up
// on 1/17/2017 this was verified successfull!
function dummychecker(numbins)

	variable numbins
	string yname = "YBinsWave"
	string xname = "XBinsWave"
	Wave XBins_idx
	
	variable i 
	for (i = 0; i < numbins; i += 1)
	
		yname = "YBinsWave" + num2str(i)
		xname = "XBinsWave" + num2str(i)
		wave w = $yname
		Make/O/N = (numpnts(w)) $xname = XBins_idx[i]
		wave q = $xname
		appendtograph w vs q
	
	endfor
	
end

function DisplayAvg()

	Wave YBinAvg
	Wave XBins
	Wave XBins_Idx
	
	display YBinAvg vs Xbins_idx
	appendtograph/R Xbins vs XBins_idx
	
	ModifyGraph mode(YBinAvg)=3,marker(YBinAvg)=16,msize(YBinAvg)=4,mode(XBins)=7;DelayUpdate
	ModifyGraph lsize(XBins)=3,hbFill(XBins)=5,rgb(XBins)=(0,12800,52224)
	ModifyGraph mirror(bottom)=1,fStyle=1,fSize=22,axThick(left)=3,axThick(bottom)=3;DelayUpdate
	ModifyGraph prescaleExp(left)=12,prescaleExp(bottom)=-3,font="Arial";DelayUpdate
	ModifyGraph axRGB(left)=(65280,0,0),axRGB(right)=(0,12800,52224);DelayUpdate
	ModifyGraph tlblRGB(left)=(65280,0,0),tlblRGB(right)=(0,12800,52224);DelayUpdate
	ModifyGraph alblRGB(left)=(65280,0,0),alblRGB(right)=(0,12800,52224);DelayUpdate
	Label left "Amplitude (pm)";DelayUpdate
	Label bottom "AM-FM Frequency (kHz)";DelayUpdate
	Label right "AM-FM Counts (a.u.)"
	
end