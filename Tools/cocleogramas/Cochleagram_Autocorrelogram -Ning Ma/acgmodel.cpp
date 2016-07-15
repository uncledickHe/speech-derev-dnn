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

#include <iostream>
#include <fstream>
#include "fftw3.h"
#include "acgmodel.h"

using namespace std;

void AcgModel::set_param(const AcgParam& param)
{
  if (_param.nchans != param.nchans) {
    _acg.resize(param.nchans);
    _cfs.resize(param.nchans);
  }
  _param = param;
}

// Write ACG data to binary file outfn with a 12 bytes header
// ACG data are saved as floats
void AcgModel::output(const char* outfn) const
{
  ofstream out ( outfn, ios::out | ios::binary );
  if ( !out ) { 
    cerr << "Cannot open file: " << outfn << endl; 
    return;
  }
  // Write a header
  AcgDataHeader hdr;
  hdr._maxDelay = maxdelay();
  hdr._numChans = nchans();
  hdr._numFrames = nframes();
  out.write((char*) &hdr, sizeof(hdr));

  // Write ACG data as float32
  for ( int t = 0; t < nframes(); t++ ) {
    for ( int c = 0; c < nchans(); c++ ) {
      for ( int d = 0; d < maxdelay(); d++ ) {
        float n = get(t, c, d);
        out.write((char*)&n, sizeof(float));
      }
    }
  }
  out.close(); 
}

// A simple correlogram model using gammatone filterbank
// Memory _ppData[c] for each channel c will be automatically reallocated!
void AcgModel::compute(const VectorF& signal, int sample_rate)
{
  // Parameter initialisation
  _sr = sample_rate;
  int frameshift_samples = (int) round(frmshift() * _sr / (Float)1000.0);
  _nframes = (int) ceil(signal.size() / (Float)frameshift_samples);
  int nsamples_padded = nframes() * frameshift_samples;
  int winsize_samples = (int) round(winsize() * _sr / (Float)1000.0);
  _maxdelay = (int) winsize_samples / 2;

  // Padding zeros to the signal
  VectorF signal_padded(signal);
  signal_padded.resize(nsamples_padded, 0.0);

  // ERB spacings
  Float lowErb = HzToErbRate(lowcf());
  Float highErb = HzToErbRate(highcf());
  Float spaceErb = 0.0;
  if (nchans() > 1)
    spaceErb = (highErb-lowErb) / (Float)(nchans() - 1);

  // Prepare the Halfcomplex-format FFT for computing ACG
  Float* fft_in = (Float*) fftw_malloc(sizeof(Float) * winsize_samples);
  Float* fft_out = (Float*) fftw_malloc(sizeof(Float) * winsize_samples);
  Float* invfft_out = fft_in;
  fftw_plan plan_forward = fftw_plan_r2r_1d(winsize_samples, fft_in, fft_out, FFTW_R2HC, FFTW_ESTIMATE);
  fftw_plan plan_backward = fftw_plan_r2r_1d(winsize_samples, fft_out, invfft_out, FFTW_HC2R, FFTW_ESTIMATE);

  // BM buffer for each channel
  VectorF bmbuffer(nsamples_padded + winsize_samples - frameshift_samples, 0.0);
  // Hann window
  VectorF window = window_hann(winsize_samples);
  for (int chan = 0; chan < nchans(); chan++) {
    // Gammatone filtering
    _cfs[chan] = ErbRateToHz(lowErb + chan * spaceErb);
    gammatone(_cfs[chan], &signal_padded[0], nsamples_padded, _sr, &bmbuffer[winsize_samples-frameshift_samples]);

    // Compute autocorrelation using FFT
    _acg[chan].clear();
    for (int frame = 0; frame < nframes(); frame++) {
      // Prepare for FFT input, apply Hann window
      for (int i = 0; i < winsize_samples; ++i) {
        fft_in[i] = bmbuffer[frame*frameshift_samples+i] * window[i];
      }
      // FFT
      fftw_execute(plan_forward);
      for (int i = 1; i < maxdelay(); i++) {  
        fft_out[i] = fft_out[i] * fft_out[i] + fft_out[winsize_samples-i] * fft_out[winsize_samples-i];
        fft_out[winsize_samples-i] = 0.0;
      }
      // Handle the two special cases in the halfcomplex-format array
      fft_out[0] *= fft_out[0];
      fft_out[maxdelay()] *= fft_out[maxdelay()];
      // Inverse FFT
      fftw_execute(plan_backward);

      // Normalisation
      for (int i = 0; i < maxdelay(); ++i) {
        if (invfft_out[i] <= 0.0)
          _acg[chan].push_back(0.0);
        else 
	  _acg[chan].push_back(sqrt(invfft_out[i] / (winsize_samples*(winsize_samples-i))));
      }
    }
  }

  fftw_destroy_plan(plan_forward);
  fftw_destroy_plan(plan_backward);
  fftw_free(fft_in);
  fftw_free(fft_out);
}

// Symmetric Hann window, the first and last zero-weighted 
// window samples are not included
VectorF AcgModel::window_hann(int winsize)
{
  int half;
  if (winsize % 2 == 0) 
    half = winsize / 2; //Even length window
  else 
    half = (winsize + 1) / 2; //Odd length window

  VectorF win(winsize);
  for (int i = 0; i < half; i++)
    win[i] = 0.5*(1-cos(2*M_PI*(i+1)/(winsize + 1)));
  for (int i = half; i < winsize; i++)
    win[i] = win[winsize-i-1];
  return win;
}

// Gammatone filter
void AcgModel::gammatone(Float centre_freq, const Float* indata, size_t datalen, int sample_rate, Float* outdata)
{
  Float a, tpt, tptbw, gain;
  Float p0r, p1r, p2r, p3r, p4r, p0i, p1i, p2i, p3i, p4i;
  Float a1, a2, a3, a4, a5, u0r, u0i;
  Float qcos, qsin, oldcs, coscf, sincf;

  /************************************************************
   * Initialising variables
   ************************************************************/
  tpt = 2 * M_PI / sample_rate;
  tptbw = tpt * erb ( centre_freq ) * BW_CORRECTION;
  a = exp ( -tptbw );

  // based on integral of impulse response
  gain = tptbw * tptbw * tptbw * tptbw / 3;

  // Update filter coefficiants
  a1 = 4.0*a; a2 = -6.0*a*a; a3 = 4.0*a*a*a; a4 = -a*a*a*a; a5 = a*a;
  p0r = 0.0; p1r = 0.0; p2r = 0.0; p3r = 0.0; p4r = 0.0;
  p0i = 0.0; p1i = 0.0; p2i = 0.0; p3i = 0.0; p4i = 0.0;
 
  coscf = cos( tpt * centre_freq );
  sincf = sin( tpt * centre_freq );
  qcos = 1; qsin = 0;
  for (size_t t = 0; t < datalen; t++) {
    // Filter part 1 & shift down to d.c.
    p0r = qcos * indata[t] + a1 * p1r + a2 * p2r + a3 * p3r + a4 * p4r;
    p0i = qsin * indata[t] + a1 * p1i + a2 * p2i + a3 * p3i + a4 * p4i;

    // Clip coefficients to stop them from becoming too close to zero
    if (fabs(p0r) < VERY_SMALL_NUMBER)
      p0r = 0.0F;
    if (fabs(p0i) < VERY_SMALL_NUMBER)
      p0i = 0.0F;

    // Filter part 2
    u0r = p0r + a1*p1r + a5*p2r;
    u0i = p0i + a1*p1i + a5*p2i;

    // Update filter results
    p4r = p3r; p3r = p2r; p2r = p1r; p1r = p0r;
    p4i = p3i; p3i = p2i; p2i = p1i; p1i = p0i;
  
    /************************************************************
     * Basilar membrane response
     * 1/ shift up in frequency first
     * 2/ take the real part only
     ************************************************************/
    Float f = (u0r * qcos + u0i * qsin) * gain;
    if (f < 0) // half-wave rectifying
      f = 0;
    outdata[t] = f;

    qcos = coscf * ( oldcs = qcos ) + sincf * qsin;
    qsin = coscf * qsin - sincf * oldcs;
  }
}

// end

