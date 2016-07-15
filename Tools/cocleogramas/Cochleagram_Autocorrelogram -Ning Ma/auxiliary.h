/*
 *=========================================================================
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

#ifndef __AUXILIARY_H
#define __AUXILIARY_H

#include <vector>

typedef unsigned char        byte;
typedef double               Float;
typedef std::vector<int>     VectorInt;
typedef std::vector<Float>   VectorF;
typedef std::vector<VectorF> MatrixF;

class AudioWav { 
public:
  AudioWav() : _data(), _fsHz(0) {}
  const VectorF& data() const { return _data; }
  Float& operator[](int n) { return _data[n]; }
  const Float & operator[](int n) const { return _data[n]; }
  int size() const { return _data.size(); }
  void clear() { _data.clear(); }
  void push_back(Float f) { _data.push_back(f); }
  int fsHz() const { return _fsHz; }
  void setFsHz(int fsHz) { _fsHz = fsHz; }
  int read(const char* fname, char endian = 'l');

private:
  VectorF  _data;
  int      _fsHz; // sampling rate in Hz
};

void swap_2bytes(short* x);
void swap_4bytes(float* x);

#endif //__AUXILIARY_H

