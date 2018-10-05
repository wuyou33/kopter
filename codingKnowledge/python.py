

#Axis labeling
xticksMajor = ax.get_xticks(minor = False)
xticksMinor = ax.get_xticks(minor = True)
yticksMinor = ax.get_yticks(minor = True)
[print(m) for m in xticksMajor]
print('-')
[print(m) for m in xticksMinor]
print('-')
# majorTicksNum = [float(m.get_text()) for m in majorTicks]

>>> np.where([[True, False], [True, True]],
...          [[1, 2], [3, 4]],
...          [[9, 8], [7, 6]])
array([[1, 8],
       [3, 4]])

# Find time stamp
time_fn.index([t for t in time_fn if abs(endTime-t)<0.02][0])


#Plotting
figure.suptitle('LNG', **plotSettings['figure_title'])
xticksMinorUser = []
counter = 0
for tick in xticksMajor[: len(xticksMajor)-2]:
	xticksMinorUserInBetween = np.linspace(tick, xticksMajor[counter+1], plotSettings['axes_ticks_n']['x_axis']+1, endpoint=False)
	[print(m) for m in xticksMinorUserInBetween]
	print('-')
	xticksMinorUser += xticksMinorUserInBetween
	counter += 1

[print(m) for m in xticksMinorUser]
xlistOfLabelsMinor = [str(m) for m in xticksMinor]
ylistOfLabelsMinor = [str(m) for m in yticksMinor]
ax.set_xticklabels(xlistOfLabelsMinor, minor=True)
ax.set_yticklabels(ylistOfLabelsMinor, minor=True)

# Lin algebra
a.shape

#I/O with files
file = open('folderResults.csv', 'w')

for ad in addressTuple_P2:
	print(ad)
	file.write(ad+'\n')

file.close()