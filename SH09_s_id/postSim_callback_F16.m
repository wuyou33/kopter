
%Get timeseries collection from sim output
[outFromSimCol] = FsClass.outFromSimFn(states, forces, inputs, accels);
clearvars states forces inputs accels

%Plot states
figure('Units', 'normalized', 'Position', [0.15 0.1 0.7 0.75])
set(gcf, 'Name', 'States simulation output')
titles = {'Vt, \alpha, \\beta', 'Angular rates', 'Euler angles', 'Translational positions'};

for p=1:4
  subPlotHandle = subplot(2, 2, p);
  if p == 1
    vars = {'vt', 'alpha', 'beta'};
  elseif p == 2
    vars = {'p', 'q', 'r'};
  elseif p == 3
    vars = {'phi', 'theta', 'psi'};
  elseif p == 2
    vars = {'xe', 'ye', 'h'};
  end
    
  y1 = plot(outFromSimCol.states.Time, outFromSimCol.states.(vars{1}), '-k', 'LineWidth', plotSet.LineWidth);
  if p == 1
    ylabel([outFromSimCol.states.vt.DataInfo.Units]);
    yyaxis right; %Go to right axis
    set(subPlotHandle, 'YColor', 'k');
  end
  hold on;

  y2 = plot(outFromSimCol.states.Time, outFromSimCol.states.(vars{2}), ':k', 'LineWidth', plotSet.LineWidth);
  y3 = plot(outFromSimCol.states.Time, outFromSimCol.states.(vars{3}), '--k', 'LineWidth', plotSet.LineWidth);
  
  ylabel([outFromSimCol.states.vars{3}.DataInfo.Units]);

  legend([y1 y2 y3], outFromSimCol.states.vars{1}.name, outFromSimCol.states.vars{2}.name, outFromSimCol.states.vars{3}.name, 'location','Best')
    
  title(tiles{p})
  xlabel('Time [seconds]');

  FsClass.SetAxisProp(subPlotHandle, plotSet)

end

