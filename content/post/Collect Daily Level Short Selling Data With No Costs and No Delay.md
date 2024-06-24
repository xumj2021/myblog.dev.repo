---
title:       "Collect Daily Level Short Sale Data From FINRA With Low Costs and Low Delay"
subtitle:    ""
description: "Affordable and high-quality daily-level short selling data collection"
date:        2022-05-14
author:      "Mengjie Xu"
toc:         true
image:    "https://assets.bbhub.io/company/sites/51/2022/02/Home.jpg"
tags:        ["Market Transparency", "Short Selling"]
categories:  ["Data" ]
---

## Short Sale Data Matters

Short selling, by definition, occurs when an investor borrows a security and sells it on the open market, planning to buy it back later for less money. Short-sellers bet on, and profit from, a drop in a security's price. 

Being timely informed about equities' short-selling status is of interests to broad market participants. For investors, short-selling is a power signal indicating the existed or, sometimes, upcoming market sentiment, both matter a lot when making the trading decisions. For firms, the level of short-selling is a highly relevant indicator for market monitoring.

Given the broad market interests about the timely short-selling data, several self-regulatory organizations (SROs) are providing on their websites daily aggregate short selling volume information for individual equity securities. The SROs are also providing website disclosure on a one-month delayed basis of information regarding individual short sale transactions in all exchange-listed equity securities.

In this blog, I will summarize the available sources of short sale data at various granularity and introduce how to approach the daily-summarized short sale dataset from FINRA (the Financial Industry Regulatory Authority).

## Challenges in Getting Affordable Short Sale Data

As the disclosure of short-selling data is out of self-regulatory purposes, the disclosure platforms and prices of the dataset are not uniform for different trading market. 

Regarding exchanges, NASDAQ sells real-time trade-by-trade short sale information for subscription fees \$1,250 per firm per month, and similar for NYSE. CBOE, the 3rd largest exchange group in U.S., releases shorting data every night on [its website](https://www.cboe.com/us/equities/market_statistics/short_sale/). 

In terms of dark pools and OTC market, FINRA posts on its website a summary for each ticker symbol of the total reported off-exchange trading volume that day and the number of those reported shares that were sold by a short seller by the start of the next trading day. There is no transaction-by-transaction short sale information included in these daily summaries. Two weeks or so after the end of each month, FINRA posts all off-exchange transactions for that month that involve a short seller, and this trade-by-trade short sale dataset.

As a result, the challenges in collecting short sale data mainly originate from the by nature non-integrated data sources, some of which may not necessarily be free or at a low price. That is why many existed literature seeks for help from professional data vendors, such as DataExplorers used by Massa et al. (2015, RFS) and S3 Paterners employed by Gargano (2020, WP),  to approach the short sale dataset.

For those who want to acquire the affordable integrated short sale data, the following data sources may be at your disposal, depending on your requirement in granularity. 

1. [Compustat - Monthly Summary Dataset](https://wrds-www.wharton.upenn.edu/pages/get-data/compustat-capital-iq-standard-poors/compustat/north-america-daily/supplemental-short-interest-file/)
   - Requires WRDS subscription
   - Monthly summarized
   - Data points start from 1973-01-15 to the present
   - e.g., Gargano et al. (2017, RFS)
2. [FINRA - Daily Summary Dataset](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data/daily-short-sale-volume-files)
   - Public available
   - Daily updated
   - Exchange daily short summary data available since 2018-08-01
   - Off-exchange daily short summary data available since 2009-08-03
3. [FINRA - Transaction Level Dataset](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data/monthly-short-sale-volume-files)
   - Public available
   - Monthly updated
   - Trade-to-trade data
   - Only off-exchange transactions available since 2009-08-03
   - e.g., Hu et al. (2021, WP)
4. [CBOE - Transaction Level Dataset](https://www.cboe.com/us/equities/market_statistics/short_sale/)
   - Public available
   - Daily Updated
   - Trade-to-trade data traded in CBOE exchange since 2008-01-02
   - e.g., Hu et al. (2021, WP)

5. [Reg SHO dataset](https://wrds-www.wharton.upenn.edu/pages/get-data/nyse-trade-and-quote/trade-and-quote-monthly-product-1993-2014/reg-sho-nyse-short-sales/)
   - Public available in both [FINRA](https://developer.finra.org/docs#query_api-equity) and [WRDS](https://wrds-www.wharton.upenn.edu/pages/get-data/nyse-trade-and-quote/trade-and-quote-monthly-product-1993-2014/reg-sho-nyse-short-sales/)
   - Transaction level data in stocks traded in NYSE
   - Pilot program data only covering between 2005-01-03 and 2007-06-06
   - e.g., Engelberg et al. (2012, JFE)



## Acquire Daily Summarized Short Sale Data From FINRA

For most archival researchers, equity-level daily-summarized short sale data is perfectly enough. That is to say, the public available FINRA dataset might be the most ideal data source with complete coverage, low costs and acceptable time delay. In this section, I will introduce a light algorithm to parse daily short sale dataset from [FINRA's website](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data/daily-short-sale-volume-files).

### Analyze Website

There are three features in FINRA's website.

1. The daily short sales are classified into 6 categories, depending on which market the sales were executed. They are FINRA Consolidated NMS, FINRA/NASDAQ TRF Chicago, ADF, FINRA/NASDAQ TRF Carteret, FINRA/NYSE TRF, ORF. Note that the so-called "FINRA Consolidated NMS" is short sales executed in exchanges and the others are short sales executed in the off-exchange market.

<center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp1.PNG" width=800 height=500>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 1: Analyze Website of FINRA</div>
</center>


2. The naming way for daily data of the 6 categories is as the following table shows. Apparently, FINRA gives each market place a single name. For example, short sales happening in the exchanges are collected to filings started with CNMSshvol and short sales executed in the ADF are collected to filings started with FNRAshvol. 

   | Market  Place             | Name | Link                                                         |
   | ------------------------- | ---- | ------------------------------------------------------------ |
   | FINRA  Consolidated NMS   | CNMS | https://cdn.finra.org/equity/regsho/daily/CNMSshvol20220513.txt |
   | FINRA/NASDAQ TRF Chicago  | FNQC | https://cdn.finra.org/equity/regsho/daily/FNQCshvol20220513.txt |
   | ADF                       | FNRA | https://cdn.finra.org/equity/regsho/daily/FNRAshvol20220513.txt |
   | FINRA/NASDAQ TRF Carteret | FNSQ | https://cdn.finra.org/equity/regsho/daily/FNSQshvol20220513.txt |
   | FINRA/NYSE TRF            | FNYX | https://cdn.finra.org/equity/regsho/daily/FNYXshvol20220513.txt |
   | ORF                       | FORF | https://cdn.finra.org/equity/regsho/daily/FORFshvol20220513.txt |

3. Given that FINRA updates data every trading day since 2009-08-03, one only needs to iterate all the possible calendar dates thereafter and keep all existed filing-date matches. Of course there are dates where there are no FINRA updates at all. Just ignore them and continue the iteration. 

   

### Parsing the data

With the above summarized features of FINRA's website, I wrote two simple functions.

`getdatelist()` : return the list of all possible calendar dates from 2009-08-01 to 2022-05-13.

`getfile(tabletype, date)`:

1.  Format the download url for each dataset with parameters `tabletype` and `date`. For example, if one wants to get the short sales submitted to all exchanges (the NMS) on 2022-05-13, the parameter `tabletype` then is CNMS and the parameter `date` is 20220513. With the parameters, the download url of the dataset mechanically would be https://cdn.finra.org/equity/regsho/daily/CNMSshvol20220513.txt

2. Check the existence of the dataset and record the content of the response if exists. If the dataset doesn't exist, the web page you get will show "Access Denied". Note that I write all the data lines into a same filing named by the category name (e.g., CNMS) for all datasets belong to a same category but recorded in different dates. 

   <center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp3.png" width=800 height=400>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 2: An Accepted Page: An Existed Datafile</div>
</center>

   <center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp2.png" width=800 height=100>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 3: A Denied Page: Non-existed Datafile</div>
</center>

The last thing is to iterate over all the possible calendar dates during 2009-08-01 and 2022-05-13 for each of the 6 filing categories, which consist of CNMS, FNQC, FNRA, FNSQ, FNYX, and FORF. In such case, all the available short sale datasets in FINRA will be downloaded. One can modify the date range to update the dataset.

```python
import os, re
from tqdm import tqdm
import requests
import datetime
import time

def getdatelist():
	datelist = []
	start_date = datetime.date(2009, 8, 1)
	end_date = datetime.date(2022, 5, 12)
	delta = datetime.timedelta(days=1)
	while start_date <= end_date:
	    datelist.append(start_date.strftime("%Y%m%d"))
	    start_date += delta
	return datelist

def getfile(tabletype, date):
	url = "https://cdn.finra.org/equity/regsho/daily/%sshvol%s.txt"%(tabletype, date)
	fileadd = "C:\\Users\\xu-m\\Documents"
	page = requests.get(url)
	if not re.findall("Access Denied", page.text):
		with open("%s\\%s.txt"%(fileadd, tabletype), 'ab') as f:
			f.write(page.content)

if __name__ == "__main__":
	tabletype = ["CNMS", "FNQC","FNRA",	"FNSQ",	"FNYX",	"FORF"]
	datelist = getdatelist()
	for table in tabletype:
		for date in tqdm(datelist):
			try:
				getfile(table, date)
				##time.sleep(1)
			except:
				print([table, date])
```

## Outcome
If the code is executed successfully, one will get 6 text files named by CNMS, FNQC, FNRA, FNSQ, FNYX, and FORF separately. Each file contains all the available stock-level daily short sale record in FINRA. 

   <center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp5.png" width=800 height=150>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 4: Output: File Lists</div>
</center>



   <center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp4.png" width=800 height=450>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 5: Output: An Example File</div>
</center>



## Summary

This blog posts introduces the sources from which one can collect short sale dataset with various granularity and shows the data collection procedures with FINRA as the data source. If necessary, one may easily collect trade-by-trade short sale dataset from [CBOE - Transaction Level Dataset](https://www.cboe.com/us/equities/market_statistics/short_sale/) and [FINRA - Transaction Level Dataset](https://www.finra.org/finra-data/browse-catalog/short-sale-volume-data/monthly-short-sale-volume-files) following the spirit of this blogpost.

Please let me know if you have any questions or suggestions. Just insert the comment below. You don't have to log in!

   <center>
    <img style="border-radius: 0.3125em;
    box-shadow: 0 2px 4px 0 rgba(34,36,38,.12),0 2px 10px 0 rgba(34,36,38,.08);" 
    src="https://fig-lianxh.oss-cn-shenzhen.aliyuncs.com/pp6.png" width=800 height=400>
    <br>
    <div style="color:orange; border-bottom: 1px solid #d9d9d9;
    display: inline-block;
    color: #999;
    padding: 2px;">Figure 6: Log-in Free Comment</div>
</center>



## References

Engelberg, Joseph E., Adam V. Reed, and Matthew C. Ringgenberg. "How are shorts informed?: Short sellers, news, and information processing." *Journal of Financial Economics* 105, no. 2 (2012): 260-278.

Gargano, Antonio. "Short Selling Activity and Future Returns: Evidence from FinTech Data." *Available at SSRN 3775338* (2020).

Gargano, Antonio, Alberto G. Rossi, and Russ Wermers. "The freedom of information act and the race toward information acquisition." *The Review of Financial Studies* 30, no. 6 (2017): 2179-2228.

Hu, Danqi, Charles M. Jones, and Xiaoyan Zhang. "When do informed short sellers trade? Evidence from intraday data and implications for informed trading models." *Evidence from Intraday Data and Implications for Informed Trading Models (February 16, 2021)* (2021).

Massa, Massimo, Bohui Zhang, and Hong Zhang. "The invisible hand of short selling: Does short selling discipline earnings management?." *The Review of Financial Studies* 28, no. 6 (2015): 1701-1736.