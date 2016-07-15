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
 *
 * Ning Ma, University of Sheffield
 * n.ma@dcs.shef.ac.uk, 12 Jun 2007
 *=========================================================================
 */

#ifndef __ACG_MODEL_H
#define __ACG_MODEL_H

#include <cmath>
#include "auxiliary.h"

const double BW_CORRECTION = 1.019;     // 4th Order gammatone
const double VERY_SMALL_NUMBER = 1e-200;

struct AcgParam
{
  Float    lowCF;         // lowest centre frequency in Hz
  Float    highCF;        // highest centre frequency in Hz
  int      nchans;        // the number of gammatone filters
  int      winSize;       // ACG window size in millisecond
  int      frmShift;      // frame shift in ms
};

// A header for saving ACG data
struct AcgDataHeader
{
  int      _maxDelay;
  int      _numChans;
  int      _numFrames;
};

class AcgModel
{
protected:
  AcgParam  _param;        // ACG parameters
  int       _maxdelay;     // maximum autocorrelation delay
  int       _nframes;      // the number of frames
  MatrixF   _acg;          // 2-D array: (maxdelay x nframes) x nchans
  VectorF   _cfs;          // Centre frequencies for all channels
  int       _sr;           // Sampling rate

private:
  AcgModel() {}
  AcgModel(const AcgModel&) {}

public:
  AcgModel(AcgParam const& param) : _param(param), _maxdelay(0), _nframes(0), _acg(param.nchans), _cfs(param.nchans), _sr(0) {}

  void compute(const VectorF& signal, int sample_rate);

  // Get the ACG value at delay [0:maxdelay), channel [0:nchans-1] and frame [0:nframes-1].
  Float get(int frame, int chan, int delay) const { return _acg[chan][_maxdelay*frame+delay]; }

  const AcgParam& param() const { return _param; }

  void set_param(const AcgParam& param);

  int nframes() const { return _nframes; }

  int maxdelay() const { return _maxdelay; }

  int nchans() const { return _param.nchans; }

  int winsize() const { return _param.winSize; }

  int frmshift() const { return _param.frmShift; }

  Float lowcf() const { return _param.lowCF; }

  Float highcf() const { return _param.highCF; }

  // Get the centre frequency of channel c (starting from 0)
  Float cf(size_t c) const { return _cfs[c]; }

  // Get the sampling rate
  int sr() const { return _sr; }

  // Output ACG data to binary file outfn with a 12 bytes header
  void output (const char* outfn) const;

public:
   static Float erb(Float x) { return ( 24.7 * ( 0.00437 * x + 1.0 ) ); }

   static Float HzToErbRate(Float x) { return ( 21.4 * log10 ( 0.00437 * x + 1.0 ) ); }

   static Float ErbRateToHz(Float x) { return ( ( pow ( 10.0, ( x / 21.4 ) ) - 1.0 ) / 0.00437 ); }

   static VectorF window_hann(int winsize);

   static void gammatone(Float centre_freq, const Float* indata, size_t datalen, int sample_rate, Float* outdata);
};

#endif // __ACG_MODEL_H

