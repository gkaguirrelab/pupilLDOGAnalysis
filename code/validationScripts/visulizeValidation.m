function summary = visulizeValidation(pathParams, varargin)

% A function for visualizing validations
%
% Syntax:
%   summaryTable = visulizeValidation(pathParams, validationNumber, whatToPlot)
%
% Description:
%   Creates a table showing the luminance and contrast values of the
%   validations. SPD plots showing measured and
%   predicted background and mirror on/off conditions can also be created
%   with this function.
%
% Inputs:
%   pathParams                    - String. Path to the directionObject.mat  
%
% Optional key/value pairs:
%   'validationNumber'            - Number or String. Which validation to
%                                   visualize. The key 'median' can be used
%                                   to get the pre/post validation median 
%                                   values. Default: 'median'
%
%   'whatToPlot'                  - String. Plot SPD on demand. Options are
%                                   bgOnOff: compares background and mirror 
%                                   on and off.
%                                   measuredVsPredictedBG: Compares
%                                   measured and predicted background.
%                                   measuredVsPredictedMirrorsOn: Compares
%                                   measured and predicred mirrors on cond.
%                                   measuredVsPredictedMirrorsOff: Compares
%                                   measured and predicted mirrors off
%                                   cond.
%                                   noSPD: Does not plot SPDs (Default)
%
%   'savePath'                    - String. Save the figures and tables to
%                                   this location. If 'NA', do not save.
%                                   Default: 'NA'
%
% Outputs:
%   summary                       - MATLAB Table. A table containing the
%                                   luminance and contrast values for all
%                                   directions.
%  

% Parse input 
p = inputParser; p.KeepUnmatched = true;

% Required
p.addRequired('pathParams');

% Optional params
p.addParameter('validationNumber', 'median');
p.addParameter('whatToPlot', 'noSPD', @isstr);
p.addParameter('savePath', 'NA', @isstr);

% parse
p.parse(pathParams, varargin{:})

% Load the directionObject if pathParams is specified, construct the paths
if isstruct(pathParams)
    % set common path params
    dropboxBaseDir = getpref('pupilLDOGAnalysis','dropboxBaseDir');
    pathParams.dataSourceDirRoot = fullfile(dropboxBaseDir,'LDOG_data');
    pathParams.dataOutputDirRoot = fullfile(dropboxBaseDir,'LDOG_processing');
    
    % Input path
    inputBaseDir = fullfile(pathParams.dataSourceDirRoot, ...
        'Experiments',...
        pathParams.Approach,...
        pathParams.Protocol,...
        'DirectionObjects',...
        pathParams.Subject,...
        pathParams.Session,...
        pathParams.Date);    
    
    % Output path
    outputBaseDir = fullfile(pathParams.dataOutputDirRoot, ...
        'Experiments',...
        pathParams.Approach,...
        pathParams.Protocol,...
        'ValidationSummary',...
        pathParams.Subject,...
        pathParams.Date,...
        pathParams.Session);

    % If the outputBaseDir does not exist, make it
    if ~exist(outputBaseDir)
        mkdir(outputBaseDir)
    end
    
    % load the input and create the final save path variable
    load(inputBaseDir)
    if strcmp(p.Results.savePath, 'NA')
        saveHere = outputBaseDir;
    else
        saveHere = p.Results.savePath;
    end
    
else
    % This is used if direct paths are specified instead of pathParams 
    load(pathParams)
    saveHere = p.Results.savePath;
end

% Putting all values in a table for better indexing
AllDirections = [];

% Check if we are dealing with the maxFlash protocol which includes a var
% named modDirection
if exist('modDirection','var')
    AllDirections.modDirection = modDirection;
else
    AllDirections.LightFluxDirection = LightFluxDirection;
    AllDirections.LminusSDirection = LminusSDirection;
    AllDirections.LplusSDirection = LplusSDirection;
    AllDirections.RodMelDirection = RodMelDirection;

% Get the labels
fn = fieldnames(AllDirections)';
fieldlength = length(fn);

% Initialize figures the figures
if ~strcmp(p.Results.whatToPlot, 'noSPD')
    prevalfig = figure;
    postvalfig = figure;
elseif strcmp(p.Results.whatToPlot, 'noSPD') 
    fprintf('Not plotting any SPDs')
else
    error("Unknown plotting method passed")
end

% Loop through directions and save the validation summary for each
% condition
summary = [];
for ii = 1:fieldlength
    % For single validation
    if isnumeric(p.Results.validationNumber)
        % Specify table values for luminance
        Type = ["BackgroundLuminance";"PositiveArmLuminance";"NegativeArmLuminance";"BackgroundMinusPositiveArmLuminance";"BackgroundMinusNegativeArmLuminance"];
        Value = [AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceActual(1) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceDesired(1);...
            AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceActual(2) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceDesired(2);...
            AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceActual(3) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceDesired(3);...
            AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceActual(4) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceDesired(4);...
            AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceActual(5) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).luminanceDesired(5)];  
        % Create the table
        summary.(fn{1,ii}).luminanceSummaryTable = table(Type, Value);
        
        % Specify table values for contrasts if not maxFlash
        if ~exist('modDirection','var')
            contrastType = [convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{1}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{2}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{3}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{4})];
            contrastValue = [AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastActual(1) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastDesired(1); AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastActual(2) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastDesired(2); AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastActual(3) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastDesired(3); AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastActual(4) AllDirections.(fn{1,ii}).describe.validation(p.Results.validationNumber).contrastDesired(4)];
            % Create the table
            summary.(fn{1,ii}).contrastSummaryTable = table(contrastType, contrastValue);
        end
        
    % For median validation values
    elseif strcmp(p.Results.validationNumber, 'median')
        % Get the pre and post val cells 
        precellGot = {AllDirections.(fn{1,ii}).describe.validation(1:5).luminanceActual};
        postcellGot = {AllDirections.(fn{1,ii}).describe.validation(6:10).luminanceActual};
        precellDesired = {AllDirections.(fn{1,ii}).describe.validation(1:5).luminanceDesired};
        postcellDesired = {AllDirections.(fn{1,ii}).describe.validation(6:10).luminanceDesired};
        
        % Get the same thing for the contrasts if not maxFlash
        if ~exist('modDirection','var')
            precellGotContrast = {AllDirections.(fn{1,ii}).describe.validation(1:5).contrastActual};
            postcellGotContrast = {AllDirections.(fn{1,ii}).describe.validation(6:10).contrastActual};
            precellDesiredContrast = {AllDirections.(fn{1,ii}).describe.validation(1:5).contrastDesired};
            postcellDesiredContrast = {AllDirections.(fn{1,ii}).describe.validation(6:10).contrastDesired};      
        end
        
        % Create luminance table values and the luminance table
        Type = ["medianBackgroundLuminance";"medianPositiveArmLuminance";"medianNegativeArmLuminance";"medianBackgroundMinusPositiveArmLuminance";"medianBackgroundMinusNegativeArmLuminance"];
        PreValidation_actual_vs_desired = [median(cellfun(@(v)v(1),precellGot)) median(cellfun(@(v)v(1),precellDesired));median(cellfun(@(v)v(2),precellGot)) median(cellfun(@(v)v(2),precellDesired));median(cellfun(@(v)v(3),precellGot)) median(cellfun(@(v)v(3),precellDesired));median(cellfun(@(v)v(4),precellGot)) median(cellfun(@(v)v(4),precellDesired));median(cellfun(@(v)v(5),precellGot)) median(cellfun(@(v)v(5),precellDesired))];
        PostValidation_actual_vs_desired = [median(cellfun(@(v)v(1),postcellGot)) median(cellfun(@(v)v(1),postcellDesired));median(cellfun(@(v)v(2),postcellGot)) median(cellfun(@(v)v(2),postcellDesired));median(cellfun(@(v)v(3),postcellGot)) median(cellfun(@(v)v(3),postcellDesired));median(cellfun(@(v)v(4),postcellGot)) median(cellfun(@(v)v(4),postcellDesired));median(cellfun(@(v)v(5),postcellGot)) median(cellfun(@(v)v(5),postcellDesired))];
        summary.(fn{1,ii}).luminanceSummaryTable = table(Type, PreValidation_actual_vs_desired, PostValidation_actual_vs_desired);
        % Create contrast table values and the contrast table
        contrastType = [convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{1}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{2}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{3}); convertCharsToStrings(AllDirections.(fn{1,ii}).describe.directionParams.photoreceptorClasses{4})];
        contrastPreVal_actual_vs_desired = [median(cellfun(@(v)v(1),precellGotContrast)) median(cellfun(@(v)v(1),precellDesiredContrast));median(cellfun(@(v)v(2),precellGotContrast)) median(cellfun(@(v)v(2),precellDesiredContrast));median(cellfun(@(v)v(3),precellGotContrast)) median(cellfun(@(v)v(3),precellDesiredContrast));median(cellfun(@(v)v(4),precellGotContrast)) median(cellfun(@(v)v(4),precellDesiredContrast))];
        contrastPostVal_actual_vs_desired = [median(cellfun(@(v)v(1),postcellGotContrast)) median(cellfun(@(v)v(1),postcellDesiredContrast));median(cellfun(@(v)v(2),postcellGotContrast)) median(cellfun(@(v)v(2),postcellDesiredContrast));median(cellfun(@(v)v(3),postcellGotContrast)) median(cellfun(@(v)v(3),postcellDesiredContrast));median(cellfun(@(v)v(4),postcellGotContrast)) median(cellfun(@(v)v(4),postcellDesiredContrast))];
        summary.(fn{1,ii}).contrastSummaryTable = table(contrastType, contrastPreVal_actual_vs_desired, contrastPostVal_actual_vs_desired);
    end
   
        % Mesured Background SPD values
        valBackgroundSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDbackground];
        preValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(1).measuredSPD + valBackgroundSPDAll(2).measuredSPD +valBackgroundSPDAll(3).measuredSPD +valBackgroundSPDAll(4).measuredSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDMeasuredAveraged = (valBackgroundSPDAll(6).measuredSPD + valBackgroundSPDAll(7).measuredSPD +valBackgroundSPDAll(8).measuredSPD +valBackgroundSPDAll(9).measuredSPD +valBackgroundSPDAll(10).measuredSPD) / 5;

        % Predicted Background SPD values 
        preValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(1).predictedSPD + valBackgroundSPDAll(2).predictedSPD +valBackgroundSPDAll(3).predictedSPD +valBackgroundSPDAll(4).predictedSPD +valBackgroundSPDAll(5).measuredSPD) / 5;
        postValBackgroundSPDPredictedAveraged = (valBackgroundSPDAll(6).predictedSPD + valBackgroundSPDAll(7).predictedSPD +valBackgroundSPDAll(8).predictedSPD +valBackgroundSPDAll(9).predictedSPD +valBackgroundSPDAll(10).measuredSPD) / 5;
        
        % Mesured Mirror on/off SPD conditions
        valArmSPDAll = [AllDirections.(fn{1,ii}).describe.validation.SPDcombined];
        preValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(1).measuredSPD + valArmSPDAll(3).measuredSPD +valArmSPDAll(5).measuredSPD +valArmSPDAll(7).measuredSPD +valArmSPDAll(9).measuredSPD) / 5;
        postValPositiveArmSPDMeasuredAveraged = (valArmSPDAll(11).measuredSPD + valArmSPDAll(13).measuredSPD +valArmSPDAll(15).measuredSPD +valArmSPDAll(17).measuredSPD +valArmSPDAll(19).measuredSPD) / 5;
        preValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(2).measuredSPD + valArmSPDAll(4).measuredSPD +valArmSPDAll(6).measuredSPD +valArmSPDAll(8).measuredSPD +valArmSPDAll(10).measuredSPD) / 5;
        postValNegativeArmSPDMeasuredAveraged = (valArmSPDAll(12).measuredSPD + valArmSPDAll(14).measuredSPD +valArmSPDAll(16).measuredSPD +valArmSPDAll(18).measuredSPD +valArmSPDAll(20).measuredSPD) / 5;

        % Predicted Mirror on/off SPD conditions
        preValPositiveArmSPDPredictedAveraged = (valArmSPDAll(1).predictedSPD + valArmSPDAll(3).predictedSPD +valArmSPDAll(5).predictedSPD +valArmSPDAll(7).predictedSPD +valArmSPDAll(9).predictedSPD) / 5;
        postValPositiveArmSPDPredictedAveraged = (valArmSPDAll(11).predictedSPD + valArmSPDAll(13).predictedSPD +valArmSPDAll(15).predictedSPD +valArmSPDAll(17).predictedSPD +valArmSPDAll(19).predictedSPD) / 5;
        preValNegativeArmSPDPredictedAveraged = (valArmSPDAll(2).predictedSPD + valArmSPDAll(4).predictedSPD +valArmSPDAll(6).predictedSPD +valArmSPDAll(8).predictedSPD +valArmSPDAll(10).predictedSPD) / 5;
        postValNegativeArmSPDPredictedAveraged = (valArmSPDAll(12).predictedSPD + valArmSPDAll(14).predictedSPD +valArmSPDAll(16).predictedSPD +valArmSPDAll(18).predictedSPD +valArmSPDAll(20).predictedSPD) / 5;
        
        % Get the wavelengths;
        wavelengths = AllDirections.(fn{1,ii}).calibration.describe.S(1):AllDirections.(fn{1,ii}).calibration.describe.S(2): AllDirections.(fn{1,ii}).calibration.describe.S(1) + AllDirections.(fn{1,ii}).calibration.describe.S(2)*AllDirections.(fn{1,ii}).calibration.describe.S(3) - AllDirections.(fn{1,ii}).calibration.describe.S(2);

        % Plot stuff for each direction
        if strcmp(p.Results.whatToPlot, 'bgOnOff')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation BG/on/off')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})   

            % visualize SPDs;
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation BG/on/off')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            legend('BG', 'AllOn', 'AllOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})  
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedBG')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, preValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, preValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})             

            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted BG')
            hold on;
            plot(wavelengths, postValBackgroundSPDMeasuredAveraged);
            plot(wavelengths, postValBackgroundSPDPredictedAveraged);
            legend('MeasuredBG', 'PredictedBG', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})           
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedMirrorsOn')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Mirrors On')
            hold on;
            plot(wavelengths, preValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, preValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})               
 
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted MirrorsOn')
            hold on;
            plot(wavelengths, postValPositiveArmSPDMeasuredAveraged);
            plot(wavelengths, postValPositiveArmSPDPredictedAveraged);
            legend('MeasuredOn', 'PredictedOn', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})   
        elseif strcmp(p.Results.whatToPlot, 'measuredVsPredictedMirrorsOff')
            set(0,'CurrentFigure',prevalfig)
            subplot(2,2,ii);
            suptitle('Pre-validation MesuredVsPredicted Mirrors Off')
            hold on;
            plot(wavelengths, preValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, preValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})               
 
            set(0,'CurrentFigure',postvalfig)
            subplot(2,2,ii);
            suptitle('Post-validation MesuredVsPredicted MirrorsOff')
            hold on;
            plot(wavelengths, postValNegativeArmSPDMeasuredAveraged);
            plot(wavelengths, postValNegativeArmSPDPredictedAveraged);
            legend('MeasuredOff', 'PredictedOff', 'Location', 'best');
            xlabel('Wavelength')
            ylabel('Power')
            title(fn{1,ii})   
        end

% Save some stuff if a path is specified
if ~strcmp(p.Results.savePath, 'NA')  
    savefig(prevalfig, fullfile(saveHere, strcat(p.Results.whatToPlot, 'preVal', '.fig')))
    savefig(prevalfig, fullfile(saveHere, strcat(p.Results.whatToPlot, 'postVal', '.fig')))
    save(fullfile(saveHere, 'summaryTable.mat'), 'summary')
end
end
end