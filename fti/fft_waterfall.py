################################################################################
#
# program: waterfall_FFT.py
# author: Tom Irvine
# version: 1.6
# date: July 24, 2014
# description:  Waterfall FFT of a signal.
#               The file must have two columns: time(sec) & amplitude
#
################################################################################

from __future__ import print_function


from tompy import read_two_columns,signal_stats
from tompy import enter_float
from tompy import enter_int
from tompy import GetInteger2

import matplotlib.pyplot as plt

from numpy import array,zeros,log
from sys import stdin

from scipy.fftpack import fft

################################################################################

print (" The input file must have two columns: time(sec) & amplitude")

a,b,num =read_two_columns()

sr,dt,mean,sd,rms,skew,kurtosis,dur=signal_stats(a,b,num)



print ("\n samples = %d " % num)

print ("\n  start = %8.4g sec  end = %8.4g sec" % (a[0],a[num-1])) 
print ("    dur = %8.4g sec \n" % dur) 


print (' Select analysis duration ')
print ('  1=whole time history ')
print ('  2=segment')

ires = GetInteger2()

if(ires==1):

    tmi=a[0]
    tme=a[len(a)-1]
    aa=a
    bb=b

else:

    print (' Enter analysis start time (sec) ')
    tmi=enter_float()

    if tmi<a[0]:
        tmi=a[0]

    print (' Enter analysis end time (sec) ')
    tme=enter_float()
    
    aa=[]
    bb=[]

    k=0
    for i in range(0,num):
        if(a[i]>=tmi and a[i]<=tme):
            aa.append(a[i])
            bb.append(b[i])             
            k=k+1
                
    aa=array(aa)
    bb=array(bb)      
    
    num=k


dtmin=1e+50
dtmax=0

for i in range(1, num-1):
    if (aa[i]-aa[i-1])<dtmin:
        dtmin=aa[i]-aa[i-1];
    if (aa[i]-aa[i-1])>dtmax:
        dtmax=aa[i]-aa[i-1];

print ("  dtmin = %8.4g sec" % dtmin)
print ("     dt = %8.4g sec" % dt)
print ("  dtmax = %8.4g sec \n" % dtmax)

print ("  srmax = %8.4g samples/sec" % float(1/dtmin))
print ("     sr = %8.4g samples/sec" % sr)
print ("  srmin = %8.4g samples/sec" % float(1/dtmax))

aa=array(aa)
bb=array(bb)

bb-=sum(bb)/len(bb)  # demean

################################################################################


n=len(bb)

ss=zeros(n)
seg=zeros(n,'f')
i_seg=zeros(n)

NC=0
for i in range (0,1000):
    nmp = 2**i
    if(nmp <= n ):
        ss[i] = 2**i
        seg[i] =float(n)/float(ss[i])
        i_seg[i] = int(seg[i])
        NC=NC+1
    else:
        break

print (' ')
print (' Number of    df    ')
print (' Segments    (Hz)   dof')
   
for i in range (1,NC+1):
    j=NC+1-i
    if j>0:
        if( i_seg[j]>0 ):
            tseg=dt*ss[j]
            ddf=1./tseg
            print ('%8d  %6.3f  %d' %(i_seg[j],ddf,2*i_seg[j]))
    if(i==12):
        break

ijk=0
while ijk==0:
    print(' ')
    print(' Choose the Number of Segments:  ')
    s=stdin.readline()
    NW = int(s)
    for j in range (0,len(i_seg)):   
        if NW==i_seg[j]:
            ijk=1
            break

# check

mmm = 2**int(log(float(n)/float(NW))/log(2))

df=1/(mmm*dt)

md2=mmm/2

################################################################################
print (" ")
print (' Enter minimum output frequency (Hz) ')
minf=enter_float()

print (' Enter maxmimum output frequency (Hz) ')
maxf=enter_float()

################################################################################

print (" ")
print (' Select Overlap ')
print (' 1=none  2=50% ')
io=enter_int()

print (" ")

freq=zeros(md2,'f')

for i in range (0,int(md2)): 
    freq[i]=i*df
    if freq[i]>maxf:
        break;

mk=i

t1=tmi+(dt*mmm)

if io==1:
    time_a=zeros(NW,'f')
    time_a[0]=t1
    
    for i in range(1,NW):
        time_a[i]=time_a[i-1]+dt*mmm
    
else:
    NW=2*NW-1
    time_a=zeros(NW,'f')
    time_a[0]=t1     
    dt=dt/2
    for i in range(1,NW):
        time_a[i]=time_a[i-1]+dt*mmm
  
################################################################################
#
#   waterfall_FFT_core
#
  
freq_p=[]

for k in range(0,int(mk)):
                          
    if freq[k]>=minf and freq[k]<=maxf:
        freq_p.append(freq[k])

freq_p=array(freq_p)
        
nfreq=len(freq_p)
        
last_freq=nfreq-1        
        
mk=nfreq
        
###############################################################################
        
LF=len(freq)     
    
print('\n NW=%d  LF=%d   mk=%d   \n' %(NW,LF,mk))    
        
store=zeros((NW,LF),'f')
store_p=zeros((NW,mk),'f')    
    
        
jk=0
        
#        print(' mmm=%d  NW=%d  len(bb)=%d   ' %(mmm,NW,len(bb)))
    
for ij in range(0,int(NW)):

    sa=zeros(mmm,'f')
            

    if io==1:   
        for k in range(0,int(mmm)):
#                    print (" %d %d %d" %(mmm,len(b),jk)                    
            sa[k]=bb[jk]
            jk=jk+1
            
    else:
        for k in range(0,int(mmm)):
            sa[k]=bb[jk]
            jk=jk+1
            
        jk=jk-mmm/2
        

    Y= fft(sa,mmm)
        
    j=0
            
#        print(' mk=%d ' %mk)            
            
    for k in range(0,LF):
            
#           ym= 2.*abs(Y[k])/mmm        
            
        if k==0:
            store[ij][k] = abs(Y[0])/mmm           
        else:    
            store[ij][k] =2.*abs(Y[k])/mmm    
            
        if freq[k]>maxf:
            break
            
        if freq[k]>=minf and freq[k]<=maxf and j<mk:
#                    print('j=%d k=%d LF=%d ij=%d' %(j,k,LF,ij))
            store_p[ij][j]=store[ij][k]
#                    print('%8.4g %8.4g' %(freq[k],store_p[ij][j]))
                
            last_freq=j    
            j=j+1
                
mk=last_freq+1
      
################################################################################
#
#   waterfall_FFT_plots         
#
#  waterfall(freq_p,time_a,store_p);   
#  

fig = plt.figure(1)

plt.plot(aa,bb, linewidth=1.0,color='b')       
plt.grid(True)
plt.xlabel('Time (sec)')
plt.title('Input Time History')

from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from matplotlib.colors import colorConverter

fig = plt.figure(2)
ax = fig.gca(projection='3d')

cc = lambda arg: colorConverter.to_rgba(arg, alpha=0.6)

verts = []

ys = zeros(mk,'f')

zs=zeros(mk,'f')

maxz=0;

for i in range(0,NW):
    for j in range(0,mk):
        zs[j] = store_p[i][j]
        
        if zs[j]>maxz:
            maxz=zs[j]
        
    for j in range(0,mk):        
        ys[j]=time_a[i]
        
    verts.append(list(zip(freq_p, ys, zs)))

ax.add_collection3d(Poly3DCollection(verts, facecolors = 'r'))

ax.view_init(elev=45, azim=-100)

ax.set_xlabel('Frequency (Hz)')
ax.set_ylabel('Time (sec)')
ax.set_zlabel('Magnitude')


ax.set_xlim3d(minf, maxf)
ax.set_ylim3d(aa[0], aa[len(aa)-1])
ax.set_zlim3d(0, maxz)

################################################################################

from matplotlib import cm  
from numpy import meshgrid  
       
fig=plt.figure(3)

X,Y = meshgrid(freq_p,time_a)

ax = fig.gca(projection='3d')
        
surf = ax.plot_surface(X, Y, store_p, rstride=1, cstride=1, cmap=cm.jet,
            linewidth=0, antialiased=False)

ax.set_xlim3d(minf, maxf)

ax.set_zlim3d(0, maxz)

ax.view_init(elev=45, azim=-100)

ax.set_xlabel('Frequency (Hz)')
ax.set_ylabel('Time (sec)')
ax.set_zlabel('Magnitude')


################################################################################

plt.close(4)
fig=plt.figure(4)

X,Y = meshgrid(freq_p,time_a)

ax = fig.gca(projection='3d')
        
surf = ax.plot_surface(X, Y, store_p, rstride=1, cstride=1, cmap=cm.jet,
    linewidth=0, antialiased=False)

#        ax.set_xlim3d(minf, maxf)
      


ax.set_zlim3d(0, maxz)
        
ax.set_zticks((0, maxz))
ax.set_zticklabels((' ',' '))                  

ax.view_init(elev=89.9, azim=-90.1)

ax.set_xlabel('Frequency (Hz)')
ax.set_ylabel('Time (sec)')

################################################################################

print ('View Plots')
print ('Manually resize 3D plots. ')
print ('Change view azimuth and elevation as desired.') 
print (' ')
print ('Then save image. ')
print (' ')
print ('Call *.png image into image editor to crop.')

plt.show() 