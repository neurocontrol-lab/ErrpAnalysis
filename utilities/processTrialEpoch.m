function psd = processTrialEpoch(trial)

% Receives an MI trial time x channels and computes PSD features after 
% preprocessing on a running window for all channels. 
% It returns a matrix time x channels x frequency. 
% This code is optimized for understanding and certainly not for efficiency    

% Extract PSD for the whole trial
for ch=1:size(trial,2)
    psd(ch,:) = extractPSD(trial(:,ch),psdwin,psdovl, freqs, fs);
end