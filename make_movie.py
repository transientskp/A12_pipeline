import matplotlib
matplotlib.use('Agg')

import glob
import astropy.io.fits as fits
from astropy.time import Time 
import numpy as np
import matplotlib.pyplot as plt
import datetime as dt
import pickle
import pandas as pd
import os
import time


def get_lsts(image_list1):
    file_datetimes1 = [pd.to_datetime(os.path.basename(x)[:19])
                          for x in image_list1]

    times = Time(file_datetimes1)
    file_lst1 = [y.sidereal_time('apparent', 6.868889).deg for y in times]
    return file_lst1

def get_lst(image_name):
    return Time(pd.to_datetime(os.path.basename(image_name)[:19])).sidereal_time('apparent', 6.868889).deg

def rms(data):
    """Returns the RMS of the data about the median.
    Args:
        data: a numpy array
    """
    data -= np.median(data)
    return np.sqrt(np.power(data, 2).sum()/len(data))


def clip(data, sigma=3):
    """Remove all values above a threshold from the array.
    Uses iterative clipping at sigma value until nothing more is getting clipped.
    Args:
        data: a numpy array
    """
    raveled = data.ravel()
    median = np.median(raveled)
    std = np.std(raveled)
    newdata = raveled[np.abs(raveled-median) <= sigma*std]
    if len(newdata) and len(newdata) != len(raveled):
        return clip(newdata, sigma)
    else:
        return newdata

image_list = sorted(glob.glob("/data/2017081[1,2,3,4]/*.fits"))

print("Making LST list")
count = 0
lst_list = np.nan*np.zeros(len(image_list))

plt.figure(figsize=(8,8))
for i in image_list:
    lst_list[count]  = Time(pd.to_datetime(os.path.basename(i)[:19])).sidereal_time('apparent', 6.868889).deg
    count +=1

filenames = []

print("Picking images")
image_array = np.array(image_list,dtype=str)
for i in np.arange(360*2)/2.:
    try:
        filenames.append(image_array[(lst_list>=i) & (lst_list <= i+1)][0])
    except IndexError:
        print i

plt.rcParams['figure.facecolor'] = 'black'

cmap = matplotlib.cm.YlGnBu_r
cmap.set_bad('black',1.)
rms_array = np.nan*np.zeros(len(filenames))
lst_array = np.nan*np.zeros(len(filenames))

print("Making images")
img_num = 0 
for i in filenames:
    img, f=fits.getdata(i,header=True)

    img_rms = rms(clip(img[0,0,:,:][np.isfinite(img[0,0,:,:])] ))
    rms_array[img_num] = img_rms
    lst_array[img_num]  = Time(pd.to_datetime(os.path.basename(i)[:19])).sidereal_time('apparent', 6.868889).deg

    img_mean = np.nanmean(img)
    plt.figure(figsize=(20.48,20.48))
    plt.imshow(img[0,0,:,:], vmin = img_mean-1*img_rms, vmax=img_mean+10*img_rms  ,origin="lower",cmap=cmap)
    plt.yticks([])
    plt.xticks([])

    plt.gca().set_position([0.0, 0.0, 1, 1])
    plt.savefig("/home/kuiack/Data2Dome/"+str(img_num).zfill(4)+".png",)
    plt.close()
    print("Done", img_num)
    img_num +=1 
print("Making dataframe")
pd.DataFrame.from_dict({'filenames':filenames,'rms':rms_array,'lst':lst_array}).to_csv("timelapse_data.csv")