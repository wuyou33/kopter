classdef FsClass
    
    properties
        %
    end

    methods (Static)

        function [] = setPlottingOptions()

            global plotSet

            plotSet.LineWidth = 1.5; %Line width, specified as a positive value in points.
            plotSet.axGridAlpha = 0.2; %Grid-line transparency, specified as a value in the range [0,1].
            plotSet.axFontSize = 14; %Font size for axis labels, specified as a scalar numeric value.
            plotSet.axLineWidth = 1.5; %Width of axes outline, tick marks, and grid lines, specified as a scalar value in point units.
            plotSet.MarkerSize = 30; %Marker size for scattered points, specified as a positive value in points.
            plotSet.TitleFontSizeMultiplier = 1.5; %Scale factor for title font size, specified as a numeric value greater than 0.
            %The axes applies this scale factor to the value of the FontSize property to determine the font size for the title.

        end

        function [outStruct] = loadSH09_lin(dirWork, loadInitial)

            % Move to folder with data
            cd(dirWork.linearDataSH09_folder);

            FL_data_sel = loadInitial.FL_data_sel;

            if FL_data_sel == 1
                fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_90.tab';
            elseif FL_data_sel == 2
                fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_147.tab';
            elseif FL_data_sel == 3
                fname = 'May2017RevAA_BE_0ft_15degC_2800kg_3.37m_151.tab';
            elseif FL_data_sel == 4
                fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_90.tab';
            elseif FL_data_sel == 5
                fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_147.tab';
            elseif FL_data_sel == 6
                fname = 'May2017RevAA_BE_0ft_15degC_2120kg_3.50m_151.tab';
            end

            n_state = 73;

            if FL_data_sel == 6
                A_start=33;
                B_start=1811;
                C_start=1910;
            else
                A_start=34;
                B_start=1812;
                C_start=1911;
            end


            fid = fopen(fname, 'r');
            fmt = '%f %f %f';

            dati_A = textscan(fid, fmt, 'headerlines', A_start);
            A_mat_from_FL = cell2mat(dati_A);
            fclose(fid);

            fid = fopen(fname, 'r');
            dati_B = textscan(fid, fmt, 'headerlines', B_start);
            B_mat_from_FL = cell2mat(dati_B);
            fclose(fid);

            fid = fopen(fname, 'r');
            dati_C = textscan(fid, fmt, 'headerlines', C_start);
            C_mat_from_FL = cell2mat(dati_C);
            fclose(fid);


            %% build A matrix from FL 

            size_A_mat_from_FL = size(A_mat_from_FL);

            A_mat_from_FL_1 = reshape(A_mat_from_FL',[size_A_mat_from_FL(1)*size_A_mat_from_FL(2),1]);

            A_mat_from_FL_1(isnan(A_mat_from_FL_1)) = [];

            A = reshape(A_mat_from_FL_1,[n_state,n_state]);
                

            %% build B matrix from FL 

            n_input = 4;

            size_B_mat_from_FL = size(B_mat_from_FL);

            B_mat_from_FL_1 = reshape(B_mat_from_FL',[size_B_mat_from_FL(1)*size_B_mat_from_FL(2),1]);

            B_mat_from_FL_1(isnan(B_mat_from_FL_1)) = [];

            B = reshape(B_mat_from_FL_1,[n_state,n_input]);

            %% build C matrix from FL

            n_output = 9;

            size_C_mat_from_FL = size(C_mat_from_FL);

            C_mat_from_FL_1 = reshape(C_mat_from_FL',[size_C_mat_from_FL(1)*size_C_mat_from_FL(2),1]);

            C_mat_from_FL_1(isnan(C_mat_from_FL_1)) = [];

            C = reshape(C_mat_from_FL_1,[n_output,n_state]);

            % check numbering of the desired output in the state vector

            x_all = (1:1:n_state)';
            state_index = C*x_all;

            delete_raw = find(state_index==0);
            C(delete_raw,:) = [];


            %% build D matrix from FL

            D = zeros(6,4);
            
            % Output data
            outStruct.A = A;
            outStruct.B = B;
            outStruct.C = C;
            outStruct.D = D;

        end

        function [initVals] = initF16Model(dirWork)

            cd([dirWork.main '/SIDPAC_V2.0/F16_NLS_V1.1'])

            f16_aero_setup_mod;
            f16_engine_setup_mod;
            global LUTvalues
            if exist('c')==0
              c=f16_massprop;
            end
            if ~exist('p0')
               p0=zeros(8,1);
               p0(1)=1;
            end
            %
            %  Use values defined in xinit and uinit
            %  as the initial parameter values for trimming.
            %
            [trm,xfree,xinit,ufree,uinit]=f16_trm_mod(p0,c);
            indx=find(xfree==1);
            indu=find(ufree==1);
            if ~isempty(indx)
              p0=xinit(indx);
            end
            if ~isempty(indu)
              p0=[p0;uinit(indu)];
            end
            np=length(p0);
            del=0.01*ones(np,1);
            if exist('tol')==0
              tol=1.0e-08;
            end
            if exist('ifd')==0
              ifd=1;
            end
            p=solve('f16_trm_mod',p0,c,del,tol,ifd);
            [trm,xfree,xinit,ufree,uinit]=f16_trm_mod(p,c);
            [x0,u0]=ic_ftrm(p,xfree,xinit,ufree,uinit); %Sets initial conditions based on trim results.

            %Outputs
            initVals.x0 = x0;
            initVals.u0 = u0;
            initVals.c = c;
            initVals.LUTvalues = LUTvalues;

            cd(dirWork.main)

            FsClass.struct2bus(initVals.LUTvalues, 'busLUTvalues')
        end

        % struct2bus(s, BusName)
        %
        % Converts the structure s to a Simulink Bus Object with name BusName
        function struct2bus(s, BusName)

            % Obtain the fieldnames of the structure
            sfields = fieldnames(s);

            % Loop through the structure
            for i = 1:length(sfields)
                
                % Create BusElement for each field
                elems(i) = Simulink.BusElement;
                elems(i).Name = sfields{i};
                elems(i).Dimensions = size(s.(sfields{i}));
                elems(i).DataType = class(s.(sfields{i}));
                elems(i).SampleTime = -1;
                elems(i).Complexity = 'real';
                elems(i).SamplingMode = 'Sample based';
                
            end

            % Create main fields of Bus Object and generate Bus Object in the base
            % workspace.
            BusObject = Simulink.Bus;
            BusObject.HeaderFile = '';
            BusObject.Description = sprintf('');
            BusObject.Elements = elems;
            assignin('base', BusName, BusObject);

        end

    end

end

%Functions to be called from FsClass
function [] = SetAxisProp(axesHandle, plotSet)

    set(axesHandle, 'GridAlpha', plotSet.axGridAlpha);
    set(axesHandle, 'FontSize', plotSet.axFontSize);
    set(axesHandle, 'LineWidth', plotSet.axLineWidth);
    set(axesHandle, 'TitleFontSizeMultiplier', plotSet.TitleFontSizeMultiplier);
    grid minor

end
