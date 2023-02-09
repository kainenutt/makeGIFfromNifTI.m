%% makeGIFfromNifTI creates animated GIFs from user-selected NiFtI (.nii) files
function  makeGIFfromNifTI

%-DESCRIPTION-------------------------------------------------------------------
% This function creates animated GIFs from input NifTI images. The input images 
% must have the .nii or .nii.gz file extension. This function accepts two-,
% three-, or four-dimensional images and will output an animated GIF containing
% each two-dimensional frame displayed with a time delay (in seconds) specified
% by the optional frameTime input parameter.
%
%-INPUTS------------------------------------------------------------------------
% 
% frameTime (optional, default = 0.1)
%       frameTime is an optional input parameter that controls the time
%       between each image frame in the output animated GIF. Recommended
%       values are between 0.02 and 0.8 seconds.
%
%-OUTPUTS-----------------------------------------------------------------------
% 
% This function will save the results to the same directory as the input
% files. The name will be identical to the input, except with a '.gif'
% extension instead of '.nii'.
%
%-AUTHOR-----------------------------------------------------------------------------
% Kainen L. Utt, PhD
% Biomedical MR Center, Malinckrodt Institute of Radiology
% Washington University School of Medicine in St. Louis, St. Louis, MO 63110, USA
% k.l.utt at wustl dot edu
%------------------------------------------------------------------------------------
    frameTime = NaN(1);
    [namein, pathin, ~] = uigetfile({  '*.nii','NIFTI image (*.nii)'}, 'Select one or several files (using +CTRL or +SHIFT)','MultiSelect', 'on');
    if isequal(namein,0) || isequal(pathin,0)
        disp('User pressed cancel')
    else
        if (iscell(namein))
            nFiles = size(namein,2);
        else
            nFiles = 1;
        end
        while isnan(frameTime)
            disp(' ')
            delayPrompt = 'Please enter the time, in seconds, to display each frame.\n     Valid inputs are numbers between 0.02 and 1.5.\n     Or press ENTER to accept default value of 0.1 seconds.';
            frameTime = input(delayPrompt);
            if isempty(frameTime)
                frameTime = 0.1;
            elseif (frameTime > 1.5) || (frameTime < 0)
                frameTime = NaN;
                fprintf('%s','Please select a valid frame time between 0.02 seconds and 1.5 seconds.')
                disp(' ')
            end
        end
        disp(' ')
        fprintf('%s','Input recorded. Proceeding to GIF creation.')
        disp(' ')
        
        for iFile = 1:nFiles
            if(nFiles>1)
                filenamein = namein{iFile};
            else
                filenamein = namein;
            end

            disp([' Input File:   ', fullfile(pathin, filenamein)])
            [~, name_s, ~]=fileparts(fullfile(pathin, filenamein));
            nout=[name_s '.gif'];
            pathout = pathin;
            
            disp(['Output File:   ', fullfile(pathout, nout)])
            fprintf(' Frame Time:   %.3f seconds', frameTime)
            disp(' ')
                       
            cname = fullfile(pathin, filenamein);

            imVolume = spm_vol(cname);
            imVoxels = spm_read_vols(imVolume);
            s=size(imVoxels);
            sDim = size(s,2);
            switch sDim
                case 2
                    nSlices     = 1;
                    nComponents = 1;
                    fprintf('\nSelected .nii file (%s) contains only one frame!\n',filenamein)
                    if iFile ~= nFiles
                        fprintf('Proceeding to next file: %s \n',namein{iFile+1})
                    else
                       disp('Please select a .nii file with at least three dimensions.')
                    end
                case 3
                    nSlices     = s(3);
                    nComponents = 1;
                case 4
                    nSlices     = s(3);
                    nComponents = s(4);
            end
            nFrames = nSlices*nComponents;
            outFrames  = zeros(s(2),s(1),1,nFrames);

            iFrame = 0;
            for iComponent = 1:nComponents
                for iSlice = 1:nSlices
                    iFrame = iFrame + 1;
                    outFrames(:,:,1,iFrame) = flipud(rot90(imVoxels(:,:,iSlice,iComponent),-1));
                end
            end
            if iFrame ~= nFrames
                fprintf('%s','Number of frames generated does not match expected number!')
                disp(' ')
            else
                outFrames = uint8(outFrames);
                imwrite(outFrames,[pathout nout],"gif",'DelayTime',frameTime,'LoopCount',inf,'Comment',filenamein);
            end
            if ~isfile([pathout nout])
                disp('Error in GIF saving.')
                disp(' ')
            else
                disp(' ')
                if iFile ~= nFiles
                    disp('Proceeding to next file... ')
                    disp(' ')
                else
                    disp(' ')
                    disp('All input files converted!')
                    clearvars;
                end
            end
        end
    end
end