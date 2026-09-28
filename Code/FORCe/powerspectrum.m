function p=powerspectrum( data, Fs )
    %
    % powerspectrum
    %
    %  Return the legacy single-sided FFT magnitude spectrum (not PSD).
    %
    % Inputs:
    %
    %  data - signal of dimmensions 1 x N (N = no. samples).
    %  Fs   - sampling rate (Hz)
    %
    % Output:
    %
    %  p    - two rows: FFT-bin frequencies and doubled magnitudes.
    %
    % Author: Ian Daly, 2013
    %
    % License:
    %
    % This program is free software; you can redistribute it and/or modify it under
    % the terms of the GNU General Public License as published by the Free Software
    % Foundation; either version 2 of the License, or (at your option) any later
    % version.
    %
    % This program is distributed in the hope that it will be useful, but WITHOUT
    % ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    % FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License along with
    % this program; if not, write to the Free Software Foundation, Inc., 59 Temple
    % Place - Suite 330, Boston, MA  02111-1307, USA.
    %
    %*********************************************************

    % Update by Satyam: accept either vector orientation and label the actual FFT bins.
    % Retain the legacy doubled magnitude values and omitted Nyquist bin.
    % This is an amplitude spectrum, not PSD; changing units requires threshold review.
    validateattributes(data,{'numeric'},{'vector','real','finite','nonempty'});
    validateattributes(Fs,{'numeric'},{'scalar','real','finite','positive'});
    data = data(:);
    L = numel(data);
    assert(L>=2,'FORCe:ShortSpectrum','At least two samples are required');
    NFFT = 2^nextpow2(L);
    Y = fft(data,NFFT)/L;
    f = (0:NFFT/2-1)*Fs/NFFT;
    magnitude = 2*abs(Y(1:NFFT/2));
    p = [f; magnitude'];
end
