function [TimeStamp, TimeStampUnix, LowNoiseAccelerometerX, LowNoiseAccelerometerY, LowNoiseAccelerometerZ, GyroscopeX, GyroscopeY, GyroscopeZ, MagnetometerX, MagnetometerY, MagnetometerZ, signal_acc,signal_gyr,signal_mag] = importfileIMU(filename, dataLines)
%IMPORTFILE Import data from a text file
 % [TIMESTAMP, TIMESTAMPUNIX, LOWNOISEACCELEROMETERX,
 % LOWNOISEACCELEROMETERY, LOWNOISEACCELEROMETERZ, GYROSCOPEX,
 % GYROSCOPEY, GYROSCOPEZ, MAGNETOMETERX, MAGNETOMETERY, MAGNETOMETERZ]
 % = IMPORTFILE(FILENAME) reads data from text file FILENAME for the
%  default selection.  Returns the data as column vectors.
%
%  [TIMESTAMP, TIMESTAMPUNIX, LOWNOISEACCELEROMETERX,
%  LOWNOISEACCELEROMETERY, LOWNOISEACCELEROMETERZ, GYROSCOPEX,
%  GYROSCOPEY, GYROSCOPEZ, MAGNETOMETERX, MAGNETOMETERY, MAGNETOMETERZ]
%  = IMPORTFILE(FILE, DATALINES) reads data for the specified row
%  interval(s) of text file FILENAME. Specify DATALINES as a positive
%  scalar integer or a N-by-2 array of positive scalar integers for
%  dis-contiguous row intervals.
%
%  Example:
%  [TimeStamp, TimeStampUnix, LowNoiseAccelerometerX, LowNoiseAccelerometerY, LowNoiseAccelerometerZ, GyroscopeX, GyroscopeY, GyroscopeZ, MagnetometerX, MagnetometerY, MagnetometerZ] = importfile("C:\Users\BENCh - Eurobench\Documents\AI4HealthyAging\A53\github_repo_SHIMMER\checksynch1.dat", [4, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 03-Jul-2023 13:15:32

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [4, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 11);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["TimeStamp", "TimeStampUnix", "LowNoiseAccelerometerX", "LowNoiseAccelerometerY", "LowNoiseAccelerometerZ", "GyroscopeX", "GyroscopeY", "GyroscopeZ", "MagnetometerX", "MagnetometerY", "MagnetometerZ"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
tbl = readtable(filename, opts);

%% Convert to output type
TimeStamp = tbl.TimeStamp;
TimeStampUnix = tbl.TimeStampUnix;
LowNoiseAccelerometerX = tbl.LowNoiseAccelerometerX;
LowNoiseAccelerometerY = tbl.LowNoiseAccelerometerY;
LowNoiseAccelerometerZ = tbl.LowNoiseAccelerometerZ;
GyroscopeX = tbl.GyroscopeX;
GyroscopeY = tbl.GyroscopeY;
GyroscopeZ = tbl.GyroscopeZ;
MagnetometerX = tbl.MagnetometerX;
MagnetometerY = tbl.MagnetometerY;
MagnetometerZ = tbl.MagnetometerZ;
signal_acc = ([LowNoiseAccelerometerX';LowNoiseAccelerometerY';LowNoiseAccelerometerZ'])';
signal_gyr = ([GyroscopeX';GyroscopeY';GyroscopeZ'])';
signal_mag = ([MagnetometerX';MagnetometerY';MagnetometerZ'])';
end