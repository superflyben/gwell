%Script to take user input and pre-set GWELL options then generate GWELL
%input and option input files and  execute gwell and return the results.
%Note that output can be returned as vectors (for single case scenario) or
%as matrices (for iteration mode).

function [d,t,p] = gwell_run(filename,params,NUSEC,NUPO,NUFEED,pipe,t_profile,feed)

%Assign constant input pararmeters
run_title = 'Automatically generated input file';
comment_1 = ' - For changes to this file, consult ''gwell_write.m'' -';
comment_2 = ' - Matlab interface developer: B. Larson of AltaRock Energy -';

%Assign variable input parameters
PTOP = params(1)*6895;  %Convert from psi to Pa
HTOP = params(2)*1000;  %Convert from kJ/kg to J/kg
QTOP = params(3);
XCTOP = params(4);
depth = params(5);
THCON = params(6);
RHOR = params(7);
HCAP = params(8);
TIME = params(9);

%NOTE: Conisder adding flag to warn when conductive heat losses are not
%accounted for b/c ((THCON/(RHOR*HCAP))*time)/radius^2) < 1

%-------------------------------DEFAULT OPTIONS------------------------
%Input options that are required by GWELL. Text refers to GWELL prompts
%1. Choose method of calculations
method = 1;
%Possible Computational Options
%1. Find downhole profiles for given wellhead conditions and given flow and
%enthalpy at feedzones.
%2. Find downhole profiles for required wellhead pressure and known
%properties at the feedzones
method_choice = 1;
%2. Read input from a file
read_file = 2;
%Name of input file (def=hola.dat) :
file_in = [filename '.dat'];
%Menu steps 3 & 4 are skipped
%5. Calculate the wellbore conditions
calculate = 5;
%Phase velocity method (Armand=0 or Orskizewski=1) ?
phase_velocity = 0;
%6. Write results to a file
results = 6;
%Name of output file (def=output.dat):
file_out = [filename '.out'];
%7. Sort calculated results for plotting (use output file)
sort_out = 7;
%99.    Stop execution
stop_exec = 99;

%Delete all existing files
delete('*.dat')
delete('*.inp')
delete('*.out')
delete('*.log')
%---------------------------GENERATE INPUT FILE---------------------------
%Create and open up input file for writing
fid = fopen(file_in,'w');

%Print out simulation parameters
fprintf(fid,'%s\n',run_title);
fprintf(fid,'%s\n',comment_1);
fprintf(fid,'%s\n',comment_2);
fprintf(fid,'%d\n',PTOP);
fprintf(fid,'%d\n',HTOP);
fprintf(fid,'%d\n',QTOP);
fprintf(fid,'%d\n',XCTOP);
fprintf(fid,'%d\n',depth);
fprintf(fid,'%d\n',THCON);
fprintf(fid,'%d\n',RHOR);
fprintf(fid,'%d\n',HCAP);
fprintf(fid,'%d\n',TIME);

fprintf(fid,'%d\n',NUSEC);
%Print out pipe section information
%(Remember that the decimal point counts towards field width)
for i=1:length(pipe(:,1))
    fprintf(fid,' %6.1f  %06.4f %2.1e   %5.1f  %5.1f\n',...
        pipe(i,1),pipe(i,2),pipe(i,3),pipe(i,4),pipe(i,5));
end

fprintf(fid,'%d\n',NUPO);
%Print out temperature profile
for i=1:length(t_profile(:,1))
    fprintf(fid,' %6.1f   %5.1f\n',t_profile(i,1),t_profile(i,2));
end

%Print out feed zone information (assume single zone at bottom of well such
%that GWELL calculates propoperties and none need be specified here)
fprintf(fid,'%d\n',NUFEED);
%Print out feed zone information if more than one feed zone
if NUFEED>1
    for i=1:length(feed(:,1))
        fprintf(fid,' %6.1f  %5.1f   %2.1e\n',...
            feed(i,1),feed(i,2),feed(i,3));
    end
end
fclose(fid);

%------------------------GENERATE OPTIONS FILE----------------------------
%Create and open up file for writing
file_option = [filename '.inp'];
fid = fopen(file_option,'w');
%Print out simulation options
fprintf(fid,'%d\n',method);
fprintf(fid,'%d\n',method_choice);
fprintf(fid,'%d\n',read_file);
fprintf(fid,'%s\n',file_in);
fprintf(fid,'%d\n',calculate);
fprintf(fid,'%d\n',phase_velocity);
fprintf(fid,'%d\n',results);
fprintf(fid,'%s\n',file_out);
fprintf(fid,'%d\n',sort_out);
fprintf(fid,'%s\n',file_out);
fprintf(fid,'%d\n',stop_exec);
fclose(fid);

%------------------------RUN GWELL & STORE OUTPUT-------------------------
%Execute gwell program with specified input file
gwell_mode=['hola.exe'];
command = [gwell_mode ' <' file_option];
dos(command);

%Read output pressure data into Matlab variable
fid = fopen('pvsz.dat');
data = textscan(fid,'%n%n');
%Store pressure and depth for plotting
%Convert pressure data from Pa to psi
p = data{1}(:)/6895;
%Convert depth data from meters to feet
d = data{2}(:)*100/2.54/12;
fclose(fid);

%Read output pressure data into Matlab variable
fid = fopen('tvsz.dat');
data = textscan(fid,'%n%n');
%Convert temperature from °C to °F and store for plotting
t = (data{1}(:)*9/5)+32;
fclose(fid);