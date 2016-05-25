%Function to route operations for GWELL input file generation, program
%execution and results plotting

function gwell

%GWELL subroutines
%   GWELL:          Flow routing subroutine
%   GWELL_INPUT:    Create parameter input array with user input
%   GWELL_RUN:      Write input files, run program and store the results
%   GWELL_PLOT:     Take stored results and plot profiles

%Set working directory
%NOTE: all necessary matlab files live in a separate foloder on the Matlab
%search path, but the executable *must* be in the working directory for
%gwell to run.
work_dir = ('R:\Projects\Newberry\Modeling\55-29 injection');
% work_dir = uigetdir;
cd(work_dir);

%Assign filenamee. All files for the run will use this name with the
%following extensions
%   .DAT    GWELL input file.
%   .INP    GWELL options required to run the executable
%   .OUT    Results from GWELL run.
filename = ['injection_55_29'];

%Set loop counter
loop = 1;
while loop~=0
    %Ask if iteration is desired
    iterate = menu('Would you like to run single case or iterate?',...
        'Single Case',...
        'Iteration');
    pause(3)

    %----------------------------CALL INPUT SUBROUTINE---------------------
    %(including brackets and increments for iterating variable)
    if loop==1
        %Need to create pipe geometry variables first time through
        if iterate==1
            %Return pipe geometry and parameter array
            [params,NUSEC,NUPO,NUFEED,pipe,t_profile,feed,well_data,units]...
                = gwell_input(loop,iterate,filename);
        elseif iterate==2
            %Return pipe geometry, parameter arrary and iterative parameters
            [params,variable,lower,upper,num_divisions,...
                NUSEC,NUPO,NUFEED,pipe,t_profile,feed,well_data,units]...
                = gwell_input(loop,iterate,filename);
        end        
    elseif loop>1
        %Pipe geometry variables already created
        if iterate==1
            %Return parameter array
            [params] = gwell_input(loop,iterate);
        elseif iterate==2
            %Return parameter array and iterative parameters
            [params,variable,lower,upper,num_divisions]...
                = gwell_input(loop,iterate);
        end
    end

    %------------------------CALL GWELL EXECUTION SUBROUTINE---------------
    if iterate==1
        %Execute single case
        %Go to subroutine to generate input files and run program
        [d,t,p] = gwell_run(filename,params,...
            NUSEC,NUPO,NUFEED,pipe,t_profile,feed);
    elseif iterate==2
        %Iterate through multiple scenarios
        increment = (upper-lower)/num_divisions;
        %Iterate through input file generation and program execution
        for i=0:num_divisions
            %Calculate value for iterating variable
            params(variable) = lower + (i*increment);
            %Go to subroutine to generate input file
            [d,t,p] = gwell_run(filename,params,...
                NUSEC,NUPO,NUFEED,pipe,t_profile,feed);
            %Store iterating variable value and new profiles in storage matrix
            value(i+1) = params(variable);
            D{i+1} = d;
            T{i+1} = t;
            P{i+1} = p;
        end
    end

    %-------------------------CALL PLOTTING SUBROUTINE---------------------
    %Go to subroutine to plot results
    if iterate==1
        [fig_handle] = gwell_plot(iterate,d,t,p,t_profile,well_data);
    elseif iterate==2
        [fig_handle] = gwell_plot(iterate,D,T,P,t_profile,well_data,variable,value,units);
    end

    %Loop handling
    rerun = menu('Run Again?',...
        'Run again with same wellbore geometry',...
        'Exit the program');
    if rerun==1
        %Increment loop counter
        loop = loop + 1;
        %Close the current figure window
        close(fig_handle);
    else
        %Set loop value to termination
        loop = 0;
    end
end