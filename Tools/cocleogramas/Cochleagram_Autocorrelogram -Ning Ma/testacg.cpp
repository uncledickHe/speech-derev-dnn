/*
 *=========================================================================
 * A program for computing autocorrelogram
 *-------------------------------------------------------------------------
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *-------------------------------------------------------------------------
 * A simple implementation of the autocorrelogram model used in:
 *   Ma, N., Green, P., Barker, J. and Coy, A. (2007) Exploiting correlogram
 *   structure for robust speech recognition with multiple speech sources. 
 *   Speech Communication, 49 (12): 874-891.
 *
 * Detailed description about the ACG model can be found in (Ma et al. 2007)
 * and at http://www.dcs.shef.ac.uk/~ning/resources/correlogram
 *
 * This is a primitive implementation and requires the "fftw3" package 
 * (http://www.fftw.org) to compute FFT. Compiled fftw3 libraries for Linux 
 * x86, Linux x86_64 and Cygwin are included. Change the Makefile accordingly.
 *
 * The ACG parameters defined in the AcgParam structure can be modified to suit 
 * your own use, e.g. employing more frequency channels
 *
 * Any bug reports or suggestions welcome.
 *
 * Ning Ma, University of Sheffield
 * n.ma@dcs.shef.ac.uk, 09 Aug 2007
 *=========================================================================
 */

#include <iostream>
#include <time.h>
#include "acgmodel.h"

using namespace std;

int main ( int argc, char** argv )
{
  if ( argc < 2 ) {
    cout << "Usage: " << argv[0] << " infile.wav [outfile.acg]" << endl;
    return 0;
  }

////////////////////////////////////////////////////////////////////////
  AcgParam param;
  param.lowCF = 50.0;    // lowest centre frequency in Hz
  param.highCF = 4000.0; // highest centre frequency in Hz
  param.nchans = 32;     // the number of gammatone filters
  param.winSize = 30;    // ACG window size in millisecond
  param.frmShift = 10;   // frame shift in ms
////////////////////////////////////////////////////////////////////////

  // Read wav data
  AudioWav wav;
  if (wav.read(argv[1]) < 1)
    return 0;
  cout << wav.size() << " samples loaded. Sampling rate = " << wav.fsHz() << endl;

  clock_t start = clock ();

  // Compute 3D correlogram
  AcgModel acg(param);
  acg.compute(wav.data(), wav.fsHz());

  cout << endl << "Autocorrelogram computed in " << (clock() - start)/(double)CLOCKS_PER_SEC << " seconds" << endl;

  // Output the correlogram
  if (argc > 2) {
    acg.output(argv[2]);
  }

  // Print out some information about the correlogram
  cout << "  maximum delay =\t" << acg.maxdelay() << endl;
  cout << "  number of channels =\t" << acg.nchans() << endl;
  cout << "  number of frames =\t" << acg.nframes() << endl;

  cout << "\nFrame\tChannel\tlag\tValue\n";
  // To access the lag 0 value in the 16th channel in the 11th frame
  cout << "11\t16\t0\t" << acg.get(10, 15, 0) << endl;
  // To access the lag 20 value of the 16th channel in the 11th frame
  cout << "11\t16\t20\t" << acg.get(10, 15, 20) << endl;
  // To access the lag 0 vaule of the 20th channel in the 36th frame
  cout << "36\t20\t0\t" << acg.get(35, 19, 0) << endl;

  return 0;
}


// end

