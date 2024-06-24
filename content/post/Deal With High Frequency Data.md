---

title:       "Extract High-frequency Data via PC SAS"
subtitle:    ""
description: "Request trade and quotes data from WRDS-TAQ database for intra-day event study"
date:        2021-12-03
author:      "Mengjie Xu"
toc:         true
image:       "https://www.mckinsey.com/~/media/mckinsey/business%20functions/mckinsey%20analytics/our%20insights/confronting%20the%20risks%20of%20artificial%20intelligence/confonting-the-risks-of-ai-1536x1536-200.jpg"
tags:        ["TAQ", "SAS", "High Frequency", "WRDS"]
categories:  ["Data" ]


---

## I. Motivation

High-frequency traders (HFTs) are market participants that are characterized by the high speed (typically in milliseconds level) with which they react to incoming news, the low inventory on their books, and the large number of trades they execute (SEC, 2010). According to Breckenfelder (2019, WP), The high-frequency trading industry grew rapidly since its inception in the mid-2000s and has represented about 50% of trading in US equity markets by 2017 (down from a 2009 peak, when it topped 60%). 

In academia, there is a decade-long debate regarding whether HFTs benefit or harm market quality. Some argues that HFTs increase price discovery by systematically correcting the in-attention of human traders and inducing the public information to be incorporated into the stock prices more promptly (e.g., Chordia and Miao, 2020 JAE; Bhattacharya et al., 2020 RAS). Others believe that the predatory behaviour of HFTs, which dampens other market participants' information acquisition incentives, must have harmed market effieciency (e.g., Ahmed et al., 2020 JAR; Lee and Watts, 2021 TAR).

Either way, there are two things that can be assured.

1. HFTs have played a big part in today's capital market.
2. To cope with today's high-frequency capital market,  scholars need to grapple with high-frequency trading data (typically in second-level before 2014 and millisecond level after 2014) to unravel the latest market micro-structure.

In this blogpost, I will introduce how to extract second/millisecond-level trade and quotes data from the WRDS-TAQ database. Such data is typically used for intra-day event studies (e.g., Rogers et al., 2016 RAS; Rogers et al., 2017 JAR). For people who are familar with the WRDS data structure, you can directly access the SAS code via [this link ](https://mengjiexu.com/post/deal-with-high-frequency-data/#vi-sas-code).

## II. Project Description

### Project Purpose

I got time stamps for firm-related events and want to get all the trade and quotes records 15 miniutes before and after the event time. Like any other event studies, the events happened in different days. 

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/rvsample.png" width=800 height=600>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 1: Intra-day Event Time</div>
</center>

### Challenges

Due to the huge size of the everyday market order flows, WRDS-TAQ database saves the daily trade and quotes data separately for each day. That means if the events in our sample happened in 2000 unique trading days, we have to query 2000 different trade datasets and another 2000 different quote datasets in the WRDS-TAQ database. 

To help the readers get an intuition about the size of the trade and quotes data, I extracted the trade records during two trading hours on December 5th, 2014. It appears that 13,197,152 trades were executed in that just two trading hours, not to mention the even (sometimes much more) bigger quote records.

```SAS
NOTE: There were 13197152 observations read from the data set TAQ.CT_20141205.
      WHERE ((time>=' 9:30:00'T and time<='10:30:00'T) or (time>='15:00:00'T 
      and time<='16:00:59'T));
```

## III. Data Source: WRDS-TAQ database

Daily TAQ (Trade and Quote) provides users with access to all trades and quotes for all issues traded on NYSE, Nasdaq and the regional exchanges for the previous trading day. It’s a comprehensive history of daily activity from NYSE markets and the U.S. Consolidated Tape covering all U.S. Equities instruments (including all CTA and UTP participating markets). One can find more details about the WRDS-TAQ database in [WRDS-TAQ User Guide](https://wrds-www.wharton.upenn.edu/documents/774/Daily_TAQ_Client_Spec_v2.2a.pdf). For those who are familiar with the TAQ database, you can jump via [this link](https://mengjiexu.com/post/deal-with-high-frequency-data/#road-map).

### Markets Covered

The Daily TAQ database covers:

- All CTA Participating Markets – Tapes A, B and C
- NYSE
- Nasdaq (OTC)
- All Regionals Exchanges

### Dataset Description

- Daily TAQ Trades File (Daily @ 9:00 PM EST; History: 24 Apr 2002 – present.) A Daily TAQ Trade file is available as a separate file in WRDS which contains all trades reported to the consolidated tape at the same day. Each trade identifies the time, exchange, security, volume, price, salecondition, the exchange where the order is executed, etc. 

- Daily TAQ Quotes File (Daily @ 2:00 am EST; History: 11 Apr 2002 – present.) A Daily TAQ Quote file is available as a separate file in WRDS which contains all quotes reported to the consolidated tape at the same day. Each quote identifies the time, exchange, security, bid/offer volumes, bid/offer prices, NBBO indicator, etc. 

### Library and table names in WRDS

- Until December 2014, the WRDS trade and quotes data is mainly in second-level (the millisecond level data is technically available in WRDS since 2002 but many institutions don't subscribe the  before-2015 millisecond level data). WRDS-TAQ database saves the second-level data with table format like

  - TAQ.CT_20130305 for second-level trade record,

    <center>
        <img style="border-radius: 0.3125em;
        box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
        src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/ctsample.png" width=800 height=500>
        <br>
        <div style="color:orange; border-bottom: 1px solid #d9d9d9;
        display: inline-block;
        color: #999;
        padding: 2px;">Figure 1: Second-level TAQ Trades Sample Data (TAQ.CT_20130305)</div>
    </center>

  - and TAQ.CQ_20130305 for second-level quote record.

    <center>
        <img style="border-radius: 0.3125em;
        box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
        src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/cqsample.png" width=800 height=500>
        <br>
        <div style="color:orange; border-bottom: 1px solid #d9d9d9;
        display: inline-block;
        color: #999;
        padding: 2px;">Figure 2: Second-level TAQ Quotes Sample Data (TAQ.CQ_20130305)</div>
    </center>

- Since 2015, the millisecond-level trade and quotes data has been prevailed. To distinguish the millisecond-level data from the second-level data, WRDS-TAQ database saves the millisecond-level data with format like

  - TAQMSEC.CTM_20150305 for millisecond-level trade record,

    <center>
        <img style="border-radius: 0.3125em;
        box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
        src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/ctmsample.png" width=800 height=400>
        <br>
        <div style="color:orange; border-bottom: 1px solid #d9d9d9;
        display: inline-block;
        color: #999;
        padding: 2px;">Figure 3: Millisecond-level TAQ Trades Sample Data (TAQMSEC.CTM_20150305)</div>
    </center>

  - TAQMSEC.CQM_20150305 for millisecond-level quote record

    <center>
        <img style="border-radius: 0.3125em;
        box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
        src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/cqmsample.png" width=800 height=450>
        <br>
        <div style="color:orange; border-bottom: 1px solid #d9d9d9;
        display: inline-block;
        color: #999;
        padding: 2px;">Figure 4: Millisecond-level TAQ Quotes Sample Data (TAQMSEC.CQM_20150305)</div>
    </center>

- Compared with second-level data, the millisecond-level dataset provides more abundent information in at least ways:

  - The time precision is improved from second-level (07:25:39) to millisecond-level (07:25:39.105) 
  - Each order is assigned with an tracking-ID, which lends significant convenience for identifying the subsequent activities (e.g., whether the order is cancelled later) after the order is placed. 

## IV. Road Map

### Step 0. Connect to WRDS server via PC SAS

In this blog post, I connect the WRDS server via the PC SAS because it helps to monitor the output from the server and finetune the codes more efficiently. One can also find how to access the WRDS server via SSH and submit the batched job in my previous blog post [Exploit WRDS Cloud via Python](https://mengjiexu.com/post/connect-to-wrds-via-python/). 

```sas
%let wrds = wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;
run;
```

### Step 1. Import the events into SAS work library

First, you need to import your event sample into the SAS work library. Here I use a small sample named as "requestsample.csv". It contains 999 unique events from 18 distinct days.

Code

```sas
libname home 'C:\Users\xu-m\Documents\wrdsas\';
libname outdir 'C:\Users\xu-m\Documents\wrdsas\taqoutput';

proc import datafile="requestsample.csv""
    out=rvsample
    dbms=csv
    replace;
run;
```

Output

```sas
NOTE: The data set WORK.RVSAMPLE has 999 observations and 18 variables.
NOTE: DATA statement used (Total process time):
      real time           0.04 seconds
      cpu time            0.04 seconds

999 rows created in WORK.RVSAMPLE from requestsample.csv.

NOTE: WORK.RVSAMPLE data set was successfully created.
NOTE: The data set WORK.RVSAMPLE has 999 observations and 18 variables.
NOTE: PROCEDURE IMPORT used (Total process time):
      real time           0.13 seconds
      cpu time            0.12 seconds

```

### Step 2. Put all the unique dates into a Macro variable

Let's name the macro variable as **datesValsM**. This step prepares for the later loop procedure.

```sas
671  rsubmit;
NOTE: Remote submit to WRDS commencing.
296  proc upload data=rvsample out=rvsample;
297  run;

NOTE: Upload in progress from data=WORK.RVSAMPLE to out=WORK.RVSAMPLE
NOTE: 191808 bytes were transferred at 584780 bytes/second.
NOTE: The data set WORK.RVSAMPLE has 999 observations and 18 variables.
NOTE: Uploaded 999 observations of 18 variables.
NOTE: The data set WORK.RVSAMPLE has 999 observations and 18 variables.
NOTE: PROCEDURE UPLOAD used (Total process time):
      real time           0.51 seconds
      cpu time            0.00 seconds

298
299  proc sql noprint;
300    select distinct ndate into :datesValsM separated by ' '
301    from work.rvsample;
302  quit;
NOTE: PROCEDURE SQL used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

303
304  %put &datesValsM;
20130301 20130303 20130304 20130305 20130306 20130307 20130308 20130311
20130312 20130313 20130314 20130315 20130316 20130317 20130318 20130319
20130320 20130321
```

### Step 3: Request trade and quotes data from WRDS server

To efficiently implement this procedure, I wrote three macros

1. **%getdict(yyyymmdd, type);** 

- The purpose of this macro is to get the table name `dataset` that should be requested (e.g., TAQ.CQ_20130305) in the WRDS server based on the event date `yyyymmdd` (e.g., 20130305) and table type `type` (ct or cq). The name of the respect output table `outname` will also be determined (e.g., taqout_cq_29130305)

- This is because apart from the exact trading date, there are two extra parameters to decide when picking the exact table that we request data from:
  - The library name - `TAQ` if the trading date is before 2014.12.31, and `TAQMSEC`otherwise
  - The table name - `CT` (in `TAQ`) or `CTM` (in `TAQMSEC`) for trades data; `CQ` (in `TAQ`) or `CQM` (in `TAQMSEC`) for quotes data
- To make sure the table name `dataset` (which we request data from) and the table name `outname` (which we save output data) can be referenced by other macros, I define those two variables as global macro variables. 

```sas
705  %macro getdict(yyyymmdd, type);
706
707      %global dataset dataset;
708      %global outname outname;
709
710      %if %SYSEVALF(&yyyymmdd/10000) <= 2014 %then %do; %let dic = taq ; %let type = &type; %end;
711      %else %do; %let dic = taqmsec; %let type = %sysfunc(catx(, &type, m)); %end;
712
713      %let dataset = &dic..&type._&yyyymmdd;
714      %let outname = taqout_&type._&yyyymmdd;
715
716      %put &dataset;
717      %put &outname;
718  %mend;

719
720  %getdict(20130305, cq);
taq.cq_20130305
taqout_cq_20130305
721  %getdict(20130305, ct);
taq.ct_20130305
taqout_ct_20130305
722  %getdict(20130305, cq);
taq.cq_20130305
taqout_cq_20130305
723  %getdict(20130305, ct);
taq.ct_20130305
taqout_ct_20130305
```

2. **%getdaily(date, dataset, outname, start, end);**

- The idea is to 
  - select out all the events that happened in a specified date `date` from the whole sample,
  - submit query to the table whose name `dataset` has been decided by the first macro `%getdict(yyyymmdd, type)`, 
  - require that the trading time should no earlier than the event time minus `start` number of seconds and no later than the event time plus `end` number of seconds,
  - Download the query results and save the output data as `outname`, which is also determined by the previous macro `%getdict(yyyymmdd, type)`

```sas
746  rsubmit;
NOTE: Remote submit to WRDS commencing.   
87
88   %macro getdaily(date, dataset, outname, start, end);
89
90       data datainput;
91           set rvsample;
92           where ndate = input("&date", BEST12.);
93       run;
94
95       proc sql;
96           create table &outname as select a.cusip, a.date, a.time,
96 ! a.g_ens_key, b.time as tradetime, b.*
97           from datainput a , &dataset b
98           where a.tic = b.symbol and b.time ge a.time-&start and b.time le
98 ! a.time+&end;
99       quit;
100
101      proc download data=&outname out=outdir.&outname; run;
102
103  %mend;
104
105  %getdaily(20130305, taq.ct_20130305, taqout_ct_20130305, 900, 900);

NOTE: There were 74 observations read from the data set WORK.RVSAMPLE.
      WHERE ndate=20130305;
NOTE: The data set WORK.DATAINPUT has 74 observations and 18 variables.
NOTE: DATA statement used (Total process time):
      real time           0.00 seconds
      cpu time            0.00 seconds

WARNING: Variable DATE already exists on file WORK.TAQOUT_CT_20130305.
WARNING: Variable TIME already exists on file WORK.TAQOUT_CT_20130305.
NOTE: Table WORK.TAQOUT_CT_20130305 created, with 44545 rows and 12 columns.

NOTE: PROCEDURE SQL used (Total process time):
      real time           0.44 seconds
      cpu time            0.31 seconds

NOTE: Download in progress from data=WORK.TAQOUT_CT_20130305 to out=OUTDIR.TAQOUT_CT_20130305
NOTE: The length of one or more variables has been promoted to preserve
      precision.
NOTE: 4454500 bytes were transferred at 3263370 bytes/second.
NOTE: The data set OUTDIR.TAQOUT_CT_20130305 has 44545 observations and 12 variables.
NOTE: Downloaded 44545 observations of 12 variables.
NOTE: The data set WORK.TAQOUT_CT_20130305 has 44545 observations and 12
      variables.
NOTE: PROCEDURE DOWNLOAD used (Total process time):
      real time           1.50 seconds
      cpu time            0.08 seconds
```

3. **%iterate(type, start, end);**

- With the previous two macros, we have finished the query for a single date. The only left thing is to iterate the query over all the unique days in our sample.
- This step is like a wrapper for our single-date query and thus needs to utilize the previous two queries.
- The three parameters in this macro are the very input parameters for our little high-frequency query project
  - Type - `ct`for trades data query, `cq`for quotes data query
  - Start - The `Start `number of seconds before the event time would be the beginning of the window. For example, I assign `Start`as 900 because I want the query window to start at 15 minutes before the event time.
  - End - The `End ` number of seconds after the event time would be the beginning of the window. For example, I assign `End` as 900 because I want the query window to end at 15 minutes after the event time.

```sas
336  %macro iterate(type, start, end);
337
338      %let i=1;
339      %let yyyymmdd=%scan(&datesValsM,&i);
340
341      %do %while("&yyyymmdd" ~= "");
342          %getdict(&yyyymmdd, &type);
343          %if %sysfunc(exist(&dataset)) %then %getdaily(&yyyymmdd, &dataset,
343! &outname, &start, &end) ;
344          %let i = %eval(&i + 1);
345          %let yyyymmdd=%scan(&datesValsM,&i);
346      %end;
347
348  %mend;
349
350  %iterate(ct, 900, 900);
```

## V. Output

The output dataset are saved separately for each date, named as the way we have determined with the macro `%getdict(yyyymmdd, type)`.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/hftout2.PNG" width=800 height=400>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 5: Output Files</div>
</center>

The dataset looks like as following.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/hftout1.PNG" width=800 height=450>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 6: Sample Output Dataset</div>
</center>


## VI. SAS Code

```SAS
libname home 'C:\Users\xu-m\Documents\wrdsas\';
libname outdir 'C:\Users\xu-m\Documents\wrdsas\1203test';

%let wrds = wrds.wharton.upenn.edu 4016;
options comamid=TCP remote=WRDS;
signon username=_prompt_;
run;

proc import datafile="requestsample.csv"
    out=rvsample
    dbms=csv
    replace;
run;

rsubmit;

proc upload data=rvsample out=rvsample;
run;

proc sql noprint;
  select distinct ndate into :datesValsM separated by ' ' 
  from work.rvsample;
quit;  

%put &datesValsM;

%macro getdict(yyyymmdd, type);

	%global dataset dataset;
	%global outname outname;

	%if %SYSEVALF(&yyyymmdd/10000) <= 2014 %then %do; %let dic = taq ; %let type = &type; %end;
	%else %do; %let dic = taqmsec; %let type = %sysfunc(catx(, &type, m)); %end;
	
	%let dataset = &dic..&type._&yyyymmdd;
	%let outname = taqout_&type._&yyyymmdd;

%mend;

%macro getdaily(date, dataset, outname, start, end);
		
	data datainput;
		set rvsample;
		where ndate = input("&date", BEST12.);
	run;

	proc sql;
		create table &outname as select a.cusip, a.date, a.time, a.g_ens_key, b.time as tradetime, b.*
		from datainput a , &dataset b
		where a.tic = b.symbol and b.time ge a.time-&start and b.time le a.time+&end;
	quit;

	proc download data=&outname out=outdir.&outname; run;

%mend;

%macro iterate(type, start, end);	

	%let i=1;
	%let yyyymmdd=%scan(&datesValsM,&i);

	%do %while("&yyyymmdd" ~= "");
		%getdict(&yyyymmdd, &type);
		%if %sysfunc(exist(&dataset)) %then %getdaily(&yyyymmdd, &dataset, &outname, &start, &end) ;
	   	%let i = %eval(&i + 1);
		%let yyyymmdd=%scan(&datesValsM,&i);
	%end;

%mend;

%iterate(ct, 900, 900);

endrsubmit;
```

## Main References

Ahmed, A. S., Li, Y., Xu, N. (2020). Tick size and financial reporting quality in small‐cap firms: Evidence from a natural experiment. Journal of Accounting Research, 58(4), 869-914.

Bhattacharya, N., Chakrabarty, B., Wang, X. F. (2020). High-frequency traders and price informativeness during earnings announcements. Review of Accounting Studies, 25(3), 1156-1199.

Breckenfelder, J. (2019). Competition among high-frequency traders, and market quality.

Charles M. C. Lee, Edward M. Watts; Tick Size Tolls: Can a Trading Slowdown Improve Earnings News Discovery?. The Accounting Review 1 May 2021; 96 (3): 373–401.

Chordia, T., Miao, B. (2020). Market efficiency in real time: Evidence from low latency activity around earnings announcements. Journal of Accounting and Economics, 70(2-3), 101335.

Rogers, J. L., Skinner, D. J., Zechman, S. L. (2016). The role of the media in disseminating insider-trading news. *Review of Accounting Studies*, *21*(3), 711-739.

Rogers, J. L., Skinner, D. J., Zechman, S. L. (2017). Run EDGAR run: SEC dissemination in a high‐frequency world. *Journal of Accounting Research*, *55*(2), 459-505.

SEC (2010). Concept release on equity market structure. concept release 34-61358, FileNo, 17 CFR Part 242 RIN 3235–AK47.

https://wrds-www.wharton.upenn.edu/documents/774/Daily_TAQ_Client_Spec_v2.2a.pdf
