#pragma rtGlobals=1		// Use modern global access method.
#include <KBColorizeTraces>

// Random Quick pplotting routines to make graphs publishable
// Obviously you may need to edit axes titles based on your own data needs
//	qp -- for trEFM
//	qph -- for histograms
//	qpg -- for I-V curves
//	qppfm -- for PFM hysteresis loops
//	ap -- for AFM images to remove the borders and such. Note that this is often just easier in photoshop

Function qp()
// 	Nicely plots something according to the standard Ginger group format (thick axes, large labels, axes mirrored, ticks inside)
//	Click on graph, then click on command window and type this
//	If you are editing a bunch of graphs and want 
	string win = WinName(0,1)	// sets to the top graph since that's the one to muck with
	SetWindow $win
	
	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
	ModifyGraph lsize=3, mirror=1
	
	// Calls Make Traces Different with default colors
	if (exists("CommonColorsButtonProc"))	// you have to actually open MakeTraceDifferent first before Igor sees it exists
		SVAR empty								// creates an empty string to be called
		if (exists("empty"))
			empty = ""
		else
			Execute "string empty"
		endif
		Execute	"CommonColorsButtonProc(empty)"
	endif
	Legend
	// these next 3 lines are only for trEFM data
	Label Left "Frequency Shift (Hz)"
	Label bottom "Time (ms)"

end

Function qph()
//    For histograms
// 	Nicely plots something according to the standard Ginger group format (thick axes, large labels, axes mirrored, ticks inside)
//	Click on graph, then click on command window and type this
//	If you are editing a bunch of graphs and want 
	string win = WinName(0,1)	// sets to the top graph since that's the one to muck with
	SetWindow $win
	
	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
	ModifyGraph lsize=3, mirror=1
	ModifyGraph mode=6,lsize=6
	ModifyGraph tickUnit(bottom)=1
	
	// Calls Make Traces Different with default colors
	if (exists("CommonColorsButtonProc"))	// you have to actually open MakeTraceDifferent first before Igor sees it exists
		SVAR empty								// creates an empty string to be called
		if (exists("empty"))
			empty = ""
		else
			Execute "string empty"
		endif
		Execute	"CommonColorsButtonProc(empty)"
	endif
	Legend
	// these next 3 lines are only for trEFM data
	Label Left "Counts (a.u.)"
	Label bottom "Q"

end


Function qpg()
//for graphs

	string win = WinName(0,1)	// sets to the top graph since that's the one to muck with
	SetWindow $win
	
	ModifyGraph mode=0
	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
	ModifyGraph lsize=3, mirror=1

	Legend
	ModifyGraph zero=3,sep=10,zeroThick=0.5;DelayUpdate
	Label left "I\\Bd\\M (µA)";DelayUpdate
	Label bottom "V\\Bgs\\M (V)"


end

function qppfm()

	ModifyGraph tick=2,minor=1,fStyle=1,fSize=22,axThick=4
	ModifyGraph lsize=3, mirror=1
	ModifyGraph tickUnit=1,prescaleExp(left)=12;DelayUpdate
	Label left "Amplitude (pm)";DelayUpdate
	Label bottom "Voltage (V)"
	
	Legend

end


// AFM images
Function ap()

	ModifyGraph noLabel=2,axThick=0
	ColorScale/C/N=text0 heightPct=105
	ColorScale/C/N=text0 fsize=18
	ColorScale/C/N=text0/X=0.91/Y=3.81
	ColorScale/C/N=text0 lblMargin=0,tickLen=0.00,tickThick=0.00
	ColorScale/C/N=text0 width=20
	ColorScale/C/N=text0 frame=0.00
	
	ModifyGraph noLabel=2,axThick=0
	ModifyGraph margin=0
	ColorScale/C/N=text0/A=RC/X=5.00/Y=5.00/E
	ColorScale/C/N=text0/F=0
	ColorScale/C/N=text0/X=5.00/Y=1.50
End