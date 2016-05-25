%Script to plot reults generated in previous subroutines and label plots.

function [fig_handle] = gwell_plot(iterate,d,t,p,t_profile,well_data,varargin)

%------------------------------PLOTTING-----------------------------------
%Create figure and assign handle
fig_handle = figure;
%Set up axes and store axis handles
%Presure profile
h(1) = subplot(1,2,1);
set(h(1),'YDir','reverse','XAxisLocation','top','NextPlot','add');
xlabel('Pressure (psi)');
ylabel('Depth (ft)');
hold all

%Temperature profile
h(2) = subplot(1,2,2);
set(h(2),'YDir','reverse','XAxisLocation','top','NextPlot','add');
xlabel('Temperature (\circF)');
ylabel('Depth (ft)');
hold all

%Assign well data
d_data = well_data(:,1);
p_data = well_data(:,2);
t_data = well_data(:,3);

%Convert and assign formation temperature profile
t_formation = (t_profile(:,2)*9/5)+32;
d_formation = t_profile(:,1)*100/2.54/12;
% t_formation = t_profile(:,2);
% d_formation = t_profile(:,1);

%Calculate phase boundary (in °F) using pressure data (in psi)
if iscell(p)==1
    p_bound = p{1};
    d_bound = d{1};
else
    p_bound = p;
    d_bound = d;
end
for i=1:length(p_bound)
    t_bound(i) = (XSteamUS('Tsat_p',p_bound(i)));
end

%Plot model data
if iterate==1
    subplot(h(1)); plot(p,d);
    subplot(h(2)); plot(t,d);
elseif iterate==2
    for i=1:length(d)
        subplot(h(1)); plot(p{i},d{i});
        subplot(h(2)); plot(t{i},d{i});
    end
end
%Plot real data
subplot(h(1)); plot(p_data,d_data);
subplot(h(2)); plot(t_data,d_data);
%Plot Inital Data
subplot(h(2)); plot(t_formation,d_formation);
%Plot saturation temperature profile
subplot(h(2)); plot(t_bound,d_bound);

%Set up legend text
if iterate==1
    legend(h(1),'Model Data','Real Data')
    legend(h(2),'Model Data','Real Data','Initial','Phase Boundary')
elseif iterate==2
    variable = varargin{1};
    value = varargin{2};
    units = varargin{3};
    if variable==9
        %Convert seconds to days for legend
        value = value./3600;
        units{variable} = 'hours';
    end
    n = length(value);
    for i=1:n
        legend_text{i} = [num2str(value(i),'%3.1f') ' ' units{variable}];
    end;
    %Insert legend text
    legend_text{length(legend_text)+1} = 'Real Data';
    legend(h(1),legend_text)
    legend_text{length(legend_text)+1} = 'Initial';
    legend_text{length(legend_text)+1} = 'Phase Boundary';
    legend(h(2),legend_text)
end

%Set up any other desired labeling
%GET FEEDBACK ON WHAT THESE PARAMETERS SHOULD BE