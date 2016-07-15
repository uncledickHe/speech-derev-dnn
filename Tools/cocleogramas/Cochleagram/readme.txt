******************************************************************************
****  Matlab Toolbox for Cochleagram Analysis and Synthesis   		  ****
****  (including ideal binary mask, or IBM, processing)                   ****
****                                                              	  ****
****  Written by DeLiang Wang, 2/2007 (at Oticon), and adapted by         ****
****  John Woodruff, 11/2008                          		          ****
****  Based on codes provided by Zhaozhang Jin and earlier versions in C  ****
******************************************************************************

The toolbox contains the following Matlab functions:

gammatone.m - Produce an array of filtered responses from a Gammatone 
	filterbank.

meddis.m - Produce auditory nerve response from output of a Gammatone 
	filterbank.

cochleagram.m - Produce a cochleagram from output of a Gammatone filterbank.

ibm.m - Produce an IBM processed mixture.

synthesis.m - Resynthesize a waveform signal from a mixture signal and 
	a binary mask.

cochplot.m - Display the image of a cochleagram with proper coordinate labels

erb2hz.m - Convert ERB-rate scale to normal frequency scale.

hz2erb.m - Convert normal frequency scale in hz to ERB-rate scale.

loudness.m - Compute loudness level in Phons on the basis of equal-loudness
	functions.


In addition,

f_af_bf_cf.mat - Contains parameter values of equal-loudness functions from BS3383,
"Normal equal-loudness level contours for pure tones under free-field listening conditions", table 1. 


Examples on how to use the toolbox:

* To genenarate and display a cochleagram without hair cell transduction, type the following:
      	gf = gammatone(Signal);        
	cg = cochleagram(gf);
	cochplot(cg);

* To genenarate and display a cochleagram with hair cell transduction, type the following:
      	gf = gammatone(inputSignal);        
	hc = meddis(gf);
	cg = cochleagram(hc);
	cochplot(cg);


Other comments:

- When using Matlab function 'wavread', the amplitudes are limited to the range [-1,+1], which are
much smaller than original integers coded in a wavefile. It is important, particularly for hair cell 
transduction, that the amplitudes are scaled up to the original range. With 16-bit precision, the scaling 
can be simply done by multiplying with power(2, 15), or Matlab function 'pow2(15)'.

- The Matlab version is several times slower than C/C++ version, which is downloadable
from http://www.cse.ohio-state.edu/pnl/software.html (follow "Voiced speech segregation").

- More detailed comments for each function are given in the M-file.

- For a tutorial introduction of the meaning of these functions see: D.L. Wang and G.J. Brown
(2006): "Fundamentals of computational auditory scene analysis," In D.L. Wang and G.J. Brown (eds.):
Computational Auditory Scene Analysis: Principles, Algorithms, and Applications (Chapter 1, pp. 1-44). 
Wiley/IEEE Press, Hoboken NJ (Website: www.casabook.org).
