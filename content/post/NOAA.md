---

title:       "From NOAA ISD Dataset to Panel Data"
subtitle:    ""
description: "China stations as an example"
date:        2021-06-15
author:      "Mengjie Xu"
toc:         true
image:       "https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/space-communications-satellite-earth-featured.jpeg"
tags:        ["NOAA", "Geo-Economics"]
categories:  ["Data" ]


---



## Motivation

The motivation to clean this dataset is from [Mukherjee et al. (2021, JFE)](https://www.sciencedirect.com/science/article/pii/S0304405X21000921). In this paper, the authors documented that one can get ahead-of-announcement estimation about the storage hubs for crude oil in the US from satellite images and trade on it. This will decrease the market reaction around the release of official figures because the oil storage information has been partially revealed during the traders' arbitrage before announcement due to traders' use of satellite images. To establish the causality between traders' satellite image use and the lower market reaction around official figure release, this paper adopted cloudiness in the storage sites as Instrument Variable because the satellite images will be more obscure and thus less useful when the weather is cloudy. It turns out that the lowered market reaction is indeed less prominent during cloudy weeks. 

In this article, I tried to construct a high-frequency cloudiness variable following the Mukherjee paper.



## Data Source

The original data source is [National Oceanic and Atmospheric Administration](https://www.ncdc.noaa.gov/isd) and I downloaded the Integrated Surface Database (ISD) dataset from its [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/).



### Brief Introduction to ISD dataset

> The Integrated Surface Database (ISD) consists of global hourly and synoptic observations compiled from numerous sources into a single common ASCII format and common data model.
>
> <br>
>
> The database includes over 35,000 stations worldwide, with some having data as far back as 1901, though the data show a substantial increase in volume in the 1940s and again in the early 1970s. Currently, there are over 14,000 "active" stations updated daily in the database. 
>
> <center><img src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/Integrated-Surface-Database-Stations-Over-Time-Chart.jpeg"/><br>Station Number</center>



### Subsample Used In This Article

- Period: 2000 - 2020
- Station Range: 2168 Stations located in China (Range from 50136 to 59951)
- Freqency: Every 3 hours



### Original Data Structure

- The folders are named by year

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.18.12.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 1: NOAA Folder List</div>
  </center>

- For each year, there is individual file for each station

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.24.28.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 2: NOAA ISD File List</div>
  </center>

- For each file in a given year, the naming format is "Station ID-NCDC WBAN Number-Year"

- For each file (with a relative station id and year), there are 12 columns

  <center>
      <img style="border-radius: 0.3125em;
      box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
      src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-16%20%E4%B8%8B%E5%8D%881.39.34.png" width=800 height=500>
      <br>
      <div style="color:orange; border-bottom: 1px solid #d9d9d9;
      display: inline-block;
      color: #999;
      padding: 2px;">Figure 3: Sample ISD File</div>
  </center>
  
  
- Variable Definitions

  > Integrated Surface Data - Lite 
  > <br>Format Documentation
  > <br><br>
  > <br>June 20, 2006
  > <br>
  > <br>Introduction
  > <br><br>The ISD-Lite data contain a fixed-width formatted subset of the complete Integrated Surface Data (ISD) for a select number of observational elements.  The data are typically stored in a single file corresponding to the ISD data, i.e. one file per station per year.  For more information on the ISD-Lite format, consult the ISD-Lite technical document.
  > <br><br>Data Format
  > <br><br>Field 1: Pos 1-4, Length 4: Observation Year
  > <br>Year of observation, rounded to nearest whole hour
  > <br><br>Field 2: Pos 6-7, Length 2: Observation Month
  > <br>Month of observation, rounded to nearest whole hour
  > <br><br>Field 3: Pos 9-11, Length 2: Observation Day
  > <br>Day of observation, rounded to nearest whole hour
  > <br><br>Field 4: Pos 12-13, Length 2: Observation Hour
  > <br>Hour of observation, rounded to nearest whole hour
  > <br><br>Field 5: Pos 14-19, Length 6:  Air Temperature
  > <br>The temperature of the air
  > <br>UNITS:  Degrees Celsius
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 6: Pos 20-24, Length 6: Dew Point Temperature
  > <br>The temperature to which a given parcel of air must be cooled at constant pressure and water vapor content in order for saturation to occur.
  > <br>UNITS: Degrees Celsius
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 7: Pos 26-31, Length 6: Sea Level Pressure
  > <br>The air pressure relative to Mean Sea Level (MSL).
  > <br>UNITS:  Hectopascals
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 8: Pos 32-37, Length 6: Wind Direction
  > <br>The angle, measured in a clockwise direction, between true north and the direction from which the wind is blowing.
  > <br>UNITS: Angular Degrees
  > <br>SCALING FACTOR: 1
  > <br>MISSING VALUE: -9999
  > <br>*NOTE:  Wind direction for calm winds is coded as 0.
  > <br><br>
  > <br>Field 9: Pos 38-43, Length 6: Wind Speed Rate
  > <br>The rate of horizontal travel of air past a fixed point.
  > <br>UNITS: meters per second
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br><br>Field 10: Pos 44-49, Length 6: Sky Condition Total Coverage Code
  > <br>The code that denotes the fraction of the total celestial dome covered by clouds or other obscuring phenomena.
  > <br>MISSING VALUE: -9999
  > <br>DOMAIN:
  > <br>0: None, SKC or CLR
  > <br>1: One okta - 1/10 or less but not zero
  > <br>2: Two oktas - 2/10 - 3/10, or FEW
  > <br>3: Three oktas - 4/10
  > <br>4: Four oktas - 5/10, or SCT
  > <br>5: Five oktas - 6/10
  > <br>6: Six oktas - 7/10 - 8/10
  > <br>7: Seven oktas - 9/10 or more but not 10/10, or BKN
  > <br>8: Eight oktas - 10/10, or OVC
  > <br>9: Sky obscured, or cloud amount cannot be estimated
  > <br>10: Partial obscuration
  > <br>11: Thin scattered
  > <br>12: Scattered
  > <br>13: Dark scattered
  > <br>14: Thin broken
  > <br>15: Broken
  > <br>16: Dark broken
  > <br>17: Thin overcast
  > <br>18: Overcast
  > <br>19: Dark overcast
  > <br><br>Field 11: Pos 50-55, Length 6: Liquid Precipitation Depth Dimension - One Hour Duration
  > <br>The depth of liquid precipitation that is measured over a one hour accumulation period.
  > <br>UNITS: millimeters
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br>*NOTE*:  Trace precipitation is coded as -1
  > <br><br>Field 12: Pos 56-61, Length 6: Liquid Precipitation Depth Dimension - Six Hour Duration
  > <br>The depth of liquid precipitation that is measured over a six hour accumulation period.
  > <br>UNITS: millimeters
  > <br>SCALING FACTOR: 10
  > <br>MISSING VALUE: -9999
  > <br>*NOTE*:  Trace precipitation is coded as -1



## Processing Data

### Step 1: Extract Data From FTP Server

Suppose we already have a pre-specified station list and need to extract data files only for those stations from the [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/).

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-17%20%E4%B8%8B%E5%8D%881.10.31.png" width=800 height=500>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 4: Prespecified Station List/Linktable</div>
</center>

To complete this work, you need to

- Find out the file names in the [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/) for each station respectively
  - For example,  data in year 2019 for station 58015 has name `580150-99999-2019.gz`
  - We could infer the names in [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/) contains three parts
    - Station ID (5 digits) followed by a "0"
    - NCDC WBAN Number (typically `99999` for Chinese stations)
    - Record year
- Filter out the data files in the [FTP server](ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/) which belongs to the pre-specified station id list
- Copy the selected data files to your local folder

```python
from shutil import copyfile
from sys import exit
import pandas as pd
import os
from tqdm import tqdm
import csv

# import pre-specified station id list
stations = pd.read_csv('linktable.csv', header = 0)

# find out all the FTP server data file names for the stations you need
def getchinalist(year):
	china_list = ["%s0-99999-%s.gz"%(i, year) for i in stations['station'][1:]]
	file_list = os.listdir("/Volumes/isd-lite/%s/"%year)
	return([china_list, file_list])

# Copy the files from FTP server to your local folder
def copy(year, file):
	source = "/Volumes/isd-lite/%s/%s"%(year, file)
	target = "/Users/mengjiexu/Dropbox/NOAA/isd%s/%s"%(year, file)
	copyfile(source, target)

# Open a csv file to record the data you've copied
with open('chinastations.csv', 'a') as f:
	g = csv.writer(f)
	# Iterate through the year from 1950 to 1999
	for year in range(1950, 2000):
		[china_list, file_list] = getchinalist(year)
		for file in tqdm(file_list):
			if file in china_list:			
				g.writerow([year, file])
				if not os.path.exists("/../NOAA/isd%s/"%year):
					os.makedirs("/../NOAA/isd%s/"%year)
				copy(year, file)
```



### Step 2: Prepare Data

As the number of ISD files is too big, it will create too many redundent `dta` files when writing those datasets into `Stata`. Here I wrote all the ISD files recording data for the same first two-digit station ids in a same year into a new file, named by the first two-digit of station ids and store it into the folder "china_isd_lite_" + the respect year. This procedure is implemented in `Python`. All the following steps are implemented in `Stata`.

```python
import os
import csv

dir = "/.../Data/"
# save address for isd files

headline = ['year','mon','day','hour','air_temperature','dew_point_temperature',
            'sea_level_pressure','wind_direction','wind_speed','cloud_cover',
            'precipitation_depth_one_hour','precipitation_depth_six_hour','station']
# headline

def transisd2csv(year):
    g = os.walk(dir + "china_isd_lite_%s"%year)
    # iterate all isd files of a given year
    isExists = os.path.exists(dir + "Aggregate%s/" % year)
    if not isExists:
        os.makedirs(dir + "Aggregate%s/" % year)
    # If thre is no folder named by "Aggregate" + year, then create one
    for path, dir_list, file_list in g:
        for file_name in file_list:
            if file_name!=".DS_Store":
                station = file_name.split("-")[0]
                # Extract station id from each isd file name
                csvFile = open(dir + "Aggregate%s/r%s.csv" % (year, station[:2]), "a", newline='', encoding='utf-8')
                # For each year, create a csv file named by the first two digit of station id
                writer = csv.writer(csvFile)
                writer.writerow(headline)
                # Write headline row
                f = open(dir + "china_isd_lite_%s/" % year + file_name, "r")
                # iterate each isd file
                for line in f:
                  	# Read each row for each ISD file
                    csvRow = line.split()
                    # For each row, split the text by space and get a list
                    csvRow.append(station)
                    # Add the station id in each row
                    writer.writerow(csvRow)
                    # Write each row into the previously created csv file named by the first two digit of station id


for year in range(2000,2021):
    transisd2csv(year)
    print("Year %s completed"%year)
```

After this procedure, we should get folders for each year named by "Aggregate" + year.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-17%20%E4%B8%8B%E5%8D%881.00.59.png" width=800 height=400>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 5: Preparing Data - 1</div>
</center>


In each folder, there should be a list of csv files named by the first two digits of station id.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-17%20%E4%B8%8B%E5%8D%881.03.55.png" width=800 height=300>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 6: Preparing Data - 2</div>
</center>



### Step 3: Write All ISD data in a Given Year Into A Same dta file

```stata
forvalues i = 2000/2020{
	* Iterate year
	
	local add= "/.../Data/Aggregate"+"`i'/"
	cd "`add'"
	* Change work dictionary to the Aggregate folder of the specified year

	local ff : dir . files "*.csv"
	foreach f of local ff {
		clear
		dis "`f'"
		local filename = substr("`f'",1,ustrrpos("`f'",".")-1)
		if "`filename'"!=""{
			dis "`filename'" 
			import delimited "`f'", delimiter(comma) varnames(1)
			save "`filename'", replace emptyok
		}
	}
	* Transfer the pre-cleaned csv files into the respect dta files

	use r45,replace
	local ff : dir . files "*.dta"
	foreach f of local ff {
		append using `f'
	}
	* Merge all dta files in a given year
	
	local saveadd="/.../Data/Aggregate2000-2020/chinaclimate"+"`i'"
	dis "`saveadd'"
	
	save "`saveadd'", replace emptyok
	* Save the dta which contains all the isd data rows in a given year, named as "chinaclimate" + year
}
```

This step produces a series of dta files named as "chinaclimate" + year, which contains all isd data rows in a given year.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/%E6%88%AA%E5%B1%8F2021-06-17%20%E4%B8%8B%E5%8D%881.25.42.png" width=800 height=500>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 7: ISD Data By Year</div>
</center>



### Step 4: Import Linktable in Order to Map Station Id into Province

The linktable is exactly the same as the station list we used in step 1. Suppose you name the imported linktable as `linktable.dta`



### Step 5: Iterate Pre-cleaned Csv Files and Average Each Variable in Each Year

```stata
forvalues i = 2000/2020{
	use chinaclimate`i'
	* Iterate dta file obatined in Step 2 for each year
	
	drop if year=="year"
	* Delete redundant headlines
	
	replace station=substr(station, 1, 5)
	* Keep the first five digits of station id to accommodate the id format in linktable
	
	sort station
	merge station using linktable
	keep if _merge==3
	drop _merge
	* Merge with linktable to get the respect province for each station

	rename precipitation_depth_one_hour precipitation_one_hour
	rename precipitation_depth_six_hour precipitation_six_hour

	sort year mon day station hour
	local vars air_temperature-precipitation_six_hour
	destring `vars',replace

	global vars air_temperature dew_point_temperature sea_level_pressure wind_direction wind_speed cloud_cover precipitation_one_hour precipitation_six_hour

	foreach v of global vars{
		replace `v'=. if `v'==-9999
		* For each variable, tag the observation as mising if it equals to -9999
		
		by year mon day station: egen dayave_`v'=mean(`v')
		* Get daily average for each station on each observation date
		
		drop `v'
		* Only keep averaged variables
	}

	drop hour
	duplicates drop year mon day station,force
	* Keep one unique observation for each station on each observation day
	
	foreach v of global vars{
		bys year province: egen yearave_`v'=mean(dayave_`v')
		* Get year-level average for each province in each year
		drop dayave_`v'
		* Only keep year-level variables
	}

	keep year province clouday yearave*
	duplicates drop year province,force
	* Keep one unique observation for each station in each observation year
	
	save yearclimate`i'
	* Save province-year average data in dta named by the respective year
}
```



### Step 6: Append All Province-Year Level Average Dta Files

```stata
clear
set obs 0
save yearclimate2000-2020, emptyok
local ff : dir . files "*.dta"
	foreach f of local ff {
		local tag = (substr("`f'",1,11)=="yearclimate")
			dis `tag'
			if `tag'==1{
				append using `f'
			}
	}
	* Identify all dta files with names starting by "yearclimate" and append them all
	
save yearclimate2000-2020, replace
* Save the year-province level panel data into dta file named by "yearclimate2000-2020"
```



## Sample Outcome

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/noaa.png" width=800 height=550>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 8: Sample Outcome: Province-Year Panel Data</div>
</center>

## References

Mukherjee, Abhiroop, George Panayotov, and Janghoon Shon. 2021. “Eye in the Sky: Private Satellites and Government Macro Data.” Journal of Financial Economics, March. [- PDF -](https://doi.org/10.1016/j.jfineco.2021.03.002)

