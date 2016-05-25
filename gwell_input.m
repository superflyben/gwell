%Script to create parameter array for input file writing based on mode of
%operation (single or iteration). This script handles variables which
%the user can itreate as well as the pipe geometery and the number of feed
%zones which are specified initially and held constant for the duration of
%the run.

function [params,varargout] = gwell_input(loop,iterate,varargin)

%------------------------------PIPE GEOMETRY------------------------------
if loop==1
    %Chose source of wellbore data
    filechoice = menu('Where should the wellbore data be read from',...
        'Matlab File',...
        'Excel File');
    if filechoice==1
        inputfile = uigetfile('*.mat','Chose the input file');
        load(inputfile);
    elseif filechoice==2
        %Get data from from Excel file
        inputfile = uigetfile('*.xls','Chose the input file');

        %Pipe geometry
        [pipe] = xlsread(inputfile,'pipe');
        h = waitbar(1/4,'Import Progress');
        pause(3);
        %     %Convert pipe dimensions from user input units to gwell units
        %     %units used for gwell input file:
        %     %Section length from feet to meters
        %     pipe(:,1) = pipe(:,1)*12*2.54/100;
        %     %Casing diameter in feet to radius in meters
        %     pipe(:,3) = pipe(:,3)/2*12*2.54/100;
        %     %Node length from feet to meters
        %     pipe(:,5) = pipe(:,5)*12*2.54/100;
        %     %Deviation from vertical to deviation from horizonal
        %     pipe(:,7) = 90-pipe(:,7);

        %Number of sections of pipe (each section is further subdivided into nodes)
        NUSEC = length(pipe(:,1));
        %Pipe geometry columns are:
        %   Column 1: Length of section (m) - multiple of node size
        %   Column 2: Section radius (m)
        %   Column 3: Pipe roughness (m) - Consult Street and Wylie (1979), p. 238
        %   Column 4: Node length (m)
        %   Column 5: Deviation  from horizontal (°)

        %Reservoir temperature profile:
        [t_profile] = xlsread(inputfile,'t_profile');
        waitbar(2/4,h);
        pause(3)
        %Number of temperature data points
        NUPO = length(t_profile(:,1));
        %   Column 1: Depth (m)
        %   Column 2: Temperature (°C)

        %Feed zones
        [feed] = xlsread(inputfile,'feed');
        waitbar(3/4,h);
        pause(3)
        %Extract # of feed zones
        if isempty(feed)==1
            NUFEED = 1;
        else
            NUFEED = 1 + length(feed(:,1));
        end
        waitbar(4/4,h);
        close(h);
        %Number and position of feed zones
        %   Column 1: Depth (m)
        %   Column 2: Flow Rate (kg/s)
        %   Column 3: Enthalpy CONSIDER ADDING BLOCK TO TAKE TEMPERATURE AND
        %   CONVERT TO ENTHALPY ASSUMING A SATURATED FLUID

        %Acquire real data for comparison with model results
        %NOTE, Consider using phase boundary in absence of real data.
        [well_data] = xlsread(inputfile,'well_data');
        pause(3)
        
        %Save data read from excel file to Matlab file
        filename = [varargin{1} '.mat'];
        save(filename,'pipe','NUSEC','t_profile','NUPO','feed','NUFEED','well_data')
    end
end

%------------------------------UNIVERSAL PARAMETERS-----------------------
%Create array of default values
%NOTE: Take default value for depth from pipe geometry read from Excel file
param_default = {                                                  %GWELL Input file line #
    ['PTOP: Wellhead pressure'],            17.8,   ['psi'];...     Line 4
    ['HTOP: Well head enthalpy'],           108,    ['kJ/kg'];...   Line 5
    ['QTOP: Well head flow rate '],         -10,    ['kg/s'];...    Line 6
    ['XCTOP: Mass fraction of NaCl or CO2'],0,      ['unitless'];...Line 7
    ['depth: Measured depth of well'],      3066,   ['m'];...       Line 8
    ['THCON: Thermal conductivity'],        0,      ['W/m C'];...   Line 9 assume avg. of cement and casing
    ['RHOR: Density'],                      2800,   ['kg/m3'];...   Line 10 assume avg. of cement and casing weighted by thickness
    ['HCAP: Heat Capacity'],                1000,   ['J/kg C'];...  Line 11
    ['TIME: Time since flow started'],      0,      ['s']};        %Line 12

%Store units for later use in creating strings
units = param_default(:,3);

if iterate==1
    %Single Case Mode
    %Create text strings for input prompts for non-varying parameters
    dlg_title = 'Specify GWELL Input parameters';
    num_lines = 1;
    for i=1:9
        prompt_constant{i}= [param_default{i,1} '(' units{i} ')'];
        def_constant{i} = num2str(param_default{i,2});
    end
    answer_constant = inputdlg(prompt_constant,dlg_title,num_lines,def_constant);

    %Parse user input
    for i=1:9
        params(i) = str2num(answer_constant{i});
    end

elseif iterate==2
    %Iteration Mode
    %Which variable should be iterated (NOTE: Consider using 'uicontrol' here)
    variable = menu('Which variable would you like to iterate',...
        param_default{1,1},...
        param_default{2,1},...
        param_default{3,1},...
        param_default{4,1},...
        param_default{5,1},...
        param_default{6,1},...
        param_default{7,1},...
        param_default{8,1},...
        param_default{9,1});

    %Enter range of values and number of increments for iterating variable
    dlg_title = param_default{variable,1};
    num_lines = 1;
    margin = 0.2;
    prompt_variable = {...
        ['Enter Lower Value (' units{variable} ')'],...
        ['Enter Upper Value (' units{variable} ')'],...
        ['Enter Number of Divisions']};
    def_variable = {...
        num2str((1-margin)*param_default{variable,2}),...
        num2str((1+margin)*param_default{variable,2}),...
        num2str('5')};
    answer_variable = inputdlg(prompt_variable,dlg_title,num_lines,def_variable);

    %Parse user input
    lower = str2num(answer_variable{1});
    upper = str2num(answer_variable{2});
    num_divisions = str2num(answer_variable{3});

    %Create text strings for input prompts for non-varying parameters
    dlg_title = 'Specify GWELL Input parameters';
    num_lines = 1;
    for i=1:9  %Index represents GWELL line number
        if i~=variable
            prompt_constant{i}= [param_default{i,1} '(' units{i} ')'];
            def_constant{i} = num2str(param_default{i,2});
        elseif i==variable
            prompt_constant{i}= 'Iterating Variable';
            def_constant{i} = 'This Field Disregarded';
        end
    end
    answer_constant = inputdlg(prompt_constant,dlg_title,num_lines,def_constant);

    %Parse user input
    for i=1:9
        if i~=variable
            params(i) = str2num(answer_constant{i});
        elseif i==variable
            params(i) = [NaN];
        end
    end
end

%----------------LOOP DEPENDENT ASSIGNMENT OF VARARGOUT--------------------
%Loop dependent assigmnet of varargout
if loop==1
    if iterate==1
        %Assign only pipe geometry
        varargout = {NUSEC,NUPO,NUFEED,pipe,t_profile,feed,well_data,units};
    elseif iterate==2
        %Assign iteration parameters and pipe geometry
        varargout = {variable,lower,upper,num_divisions,...
            NUSEC,NUPO,NUFEED,pipe,t_profile,feed,well_data,units};
    end
elseif loop>1 & iterate==2
    %Assign only iteration parameters
    varargout = {variable,lower,upper,num_divisions};
end