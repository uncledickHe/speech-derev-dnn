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

#include <iostream>
#include <fstream>
#include <iomanip>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "auxiliary.h"

using namespace std;

// A simple routine to read data from .WAV files
int AudioWav::read(const char* fname, char endian)
{
  char szChunckID[5] = ""; //four bytes to hold chunck id "RIFF" etc
  short format_tag, channels, block_align, bits_per_sample;
  int byte_rate, chunck_size, count(0);

  ifstream in(fname, ios::in | ios::binary);
  if (!in) { 
    cerr << "Unable to open wave file: " << fname << endl; 
    return -1;
  }
  in.read(szChunckID, 4);
  if (strcmp(szChunckID, "RIFF")) { 
    cerr << "Not a RIFF (WAVE) file: found " << szChunckID << endl;
  }
  else {
    in.read((char*)&chunck_size, sizeof(int)); //read in 32bit size value
    in.read(szChunckID, 4); //read in 4 bytes "WAVE"
    if ( strcmp(szChunckID, "WAVE"))
      cerr << "RIFF file but not a wave file: found " << szChunckID << endl;
    else {
      in.read(szChunckID, 4); //read in 4 bytes "fmt ";
      in.read((char*)&chunck_size, sizeof(int));
      in.read((char*)&format_tag, sizeof(short));
      in.read((char*)&channels, sizeof(short));
      in.read((char*)&_fsHz, sizeof(int));
      in.read((char*)&byte_rate, sizeof(int));
      in.read((char*)&block_align, sizeof(short));
      in.read((char*)&bits_per_sample, sizeof(short)); //8 bit or 16 bit file?
      in.read(szChunckID, 4); //read in 4 bytes "data"
      in.read((char*)&chunck_size, sizeof(int)); //sound data in bytes
      int len = chunck_size / (bits_per_sample / 8);
      _data.clear();
      short sample;
      for (count=0; count<len; count++) {
        in.read((char*)&sample, sizeof(short));
        if (in.gcount() == sizeof(short)) {
          if (endian == 'b')
            swap_2bytes ( &sample );
          // Uncomment the following line if normalisation as in Matlab "wavread" is desired
          //sample /= 32768.0;
          _data.push_back(sample);
        }
        else {
          cerr << "Unable to read " << len << " samples: read " << count+1 << endl;
          break;
        }
      }
    }
  }
  in.close();
  return count;
}

void swap_2bytes(short* x)
{
   char* p = (char*)x;
   char c = *p; *p = *(p+1); *(p+1) = c;
}

void swap_4bytes(float* x)
{
   char* p = (char*)x;
   char c = *p; *p = *(p+3); *(p+3) = c;
   c = *(p+1); *(p+1) = *(p+2); *(p+2) = c;
}


// end

