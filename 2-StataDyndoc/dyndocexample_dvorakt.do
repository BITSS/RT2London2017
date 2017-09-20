
<<dd_include: header.txt >>

## Coding Empricial Analysis from Beginning to End

### Introduction

The purpose of this note is to illustate the use statistical code to do empirical analysis from beginning to end: from database retrieval, through cleaning and manipulating data, to analysis and display of empirical results. This note can be used as an introductory excercise of reproducible research. 

While reproducible analysis can be done by keeping code and write-up of the analysis separate, new tools now exist that combine the two. [RMarkdown](http://rmarkdown.rstudio.com/) for R users has been around for a while. The latest version of Stata (Stata 15) includes this functionality as well. It is called [dynamic documents](http://www.stata.com/new-in-stata/markdown/) (`dyndoc`). I use Stata's dyndoc to produce this note.

The empirical content of this note is motivated by the work of [Herdon et al (2014)](https://doi.org/10.1093/cje/bet075) who [famously](http://www.cc.com/video-clips/dcyvro/the-colbert-report-austerity-s-spreadsheet-error) discovered a "spreadsheet error" in the work by [Reinhart and Rogoff (2010)](https://www.aeaweb.org/articles?id=10.1257/aer.100.2.573). Herdon et al (2014) overturn Reinhart and Roggof results that economic growth declines as public debt reaches levels above 90% of GDP. The sources of the different result include a miss-typed formula in an Excel spreadsheet and arbitrary exclusions of certain observations. 

The "spreadsheet error" episode highlights the importance of careful data manipulation and thorough documentation of empirical analysis. Using Stata code to retrieve, manipulate and analyze data provides complete documentation of every step in the empirical analysis. (This is the so-called "soup-to-nuts" approach advocated by [Project TIER](http://www.projecttier.org/).) Moreover, any researcher wishing to test the sensitivity of the results to alternative manipulations can do so by merely modifying the code.


### Data retrieval

I use publicly available data from [World Development Indicators](http://databank.worldbank.org/data/reports.aspx?source=world-development-indicators&preview=on) (WDI). The advantage of using WDI is that the data is collected using consistent methodologies. The drawback is that WDI public debt data begins only in 1990 for most countries. Other researchers have put together much longer series by splicing data from a number of different sources. Some of this historical data is now available [here](http://www.imf.org/en/Publications/WP/Issues/2016/12/31/A-Historical-Public-Debt-Database-24332).  

Data from WDI can be retrieved directly using Stata command `wbopendata`. The command accesses the internet and retrieves the series listed in the `indicator` option. The names of series can be found [here](http://data.worldbank.org/data-catalog/world-development-indicators).

Running the 'wbopendata' takes a bit of time. Therefore, after I retrive the data once, I save it in a local directory. I then use the local file rather than retrieving the same data each time I run the code. Saving the retrieved data locally preserves the state of the database at the time of the retrieval. 

~~~~
<<dd_do: nooutput>>
*clear
*wbopendata, indicator(NY.GDP.MKTP.KD.ZG ; GC.DOD.TOTL.GD.ZS; NY.GDP.PCAP.KD; SP.POP.TOTL) clear long 
*save wdidata08102017, replace
<</dd_do>>
~~~~

### Cleaning data

The WDI contains data on 'aggregates' (e.g. High Income Countries). I drop these observations from the data. Prior to 1990, the WDI data on public debt is very sparse, so let's delete any data prior to 1990. I also drop countries that at any point in the data (since 1990) had population of less than 500 thousand (countries like San Marino, Marshall Islands, etc.).
~~~~
<<dd_do: nooutput>>
use wdidata08102017, clear
drop if region=="Aggregates" | region==""
keep if year>=1990
*find the minimum population for each country
egen popmin=min(sp_pop_totl), by(countrycode)
drop if popmin<500000
drop popmin sp_pop_totl
<</dd_do>>
~~~~

Let's give the variables more recognizable names.
~~~~
<<dd_do>> 
rename gc_dod_totl_gd_zs debttogdp
rename ny_gdp_mktp_kd_zg gdpgrowth
rename ny_gdp_pcap_kd gdppc
<</dd_do>>
~~~~

Let's keep only observations for which none of the three variables are missing. Let's also create log of GDP per capita - we will need it later in the analysis. Finally, let's create a debt_category variable that would put levels of debt in different buckets.

~~~~
<<dd_do: nooutput>> 
keep if debttogdp~=. & gdpgrowth~=. & gdppc~=.
g loggdppc = log(gdppc)
g str15 debt_cat="0-30%" if debttogdp<=30
replace debt_cat="30-60%" if debttogdp>30 & debttogdp<=60
replace debt_cat="60-90%" if debttogdp>60 & debttogdp<=90
replace debt_cat="Above 90%" if debttogdp>90 & debttogdp~=.
<</dd_do>>
~~~~

### Examining data I: Is debt associated with low growth?

We will create a box plot of real GDP growth by debt category (similar to Herdon et al's Figure 3).
~~~~
<<dd_do>>
graph box gdpgrowth , over(debt_cat) ytitle("Real GDP Growth (in %)") title("Contemporaneous relationship between debt and growth")
<</dd_do>>
~~~~
<<dd_graph: saving(debt.svg) replace height(500)>>

Despite using only recent data, our results are quite similar to those in Herdon et al (2014), i.e. they show very little relationship between debt levels and economic growth. 

### Examining data II: Does debt *predict* low growth?

The initial work by Reihart and Rogoff (2010) and Herdon et al (2014) was followed by a slew of papers that extended the analysis further. For example, [Eberhardt and Presbitero (2015)](http://www.sciencedirect.com/science/article/pii/S0022199615000690) look at the long-run effects of high debt, and [Panizza and Presbitero (2014)](http://www.sciencedirect.com/science/article/pii/S0164070414000536) control for endogeneity in the relationship between public debt and economic growth. In the spririt of that work, this section  examines whether indebtedness *predicts* GDP growth over the next four years. This requires a bit more data manipulation. 

Our strategy is to create five-year periods for each country. The first year in that period is the inital year and we will measure GDP growth over the next four years. Since each country enters the data set at different times, the five-year periods could begin in different years for different countries. 

~~~~
<<dd_do>>
*find when the country enters the data set 
egen minyear=min(year), by(countrycode)
*create a number for each five year period (0 for first five-year period, 1 for the second five-year period etc.)
g fiveyearid = floor((year-minyear)/5)
*create a number (0,1,2,4 or 5)for each year in each five-year period 
g year_in_five = year-minyear-fiveyearid*5 
save temp_data, replace
<</dd_do>>
~~~~

Note that we put the 'data' file into a 'temp' folder. This is because we need 'data' need temporarily - it is not the final output of the analysis, or even the final output of this program.

Let's now split the dataset into two: one that has the first year for every country and every five year period; and one that has the average GDP growth for the subsequent four years for every country and every five-year period. Then we merge the data sets back together.

~~~~
<<dd_do: nooutput>>
*keep only the first years in each five year period
keep if year_in_five==0 
keep countryname gdppc loggdppc debttogdp debt_cat fiveyearid
save temp_first_years, replace

use temp/data
*keep only the subsequent years
drop if year_in_five==0 
keep countryname gdpgrowth fiveyearid
*average across the four subsequent years
collapse (mean) gdpgrowth (count) n=gdpgrowth, by(countryname fiveyearid)
*merge back the inital debt
merge 1:1 countryname fiveyearid using temp/first_years 
*some observations will not match because may have first year without any subsequent years 
*or since there are gaps in the data, we could have subsequent without initial
drop if _merge~=3
*also drop observations with fewer than two subsequent periods 
drop if n<3
<</dd_do>>
~~~~

Now we are ready to analyze the data. Let's plot inital debt levels against subsequent growth.

~~~~
<<dd_do>>
graph box gdpgrowth ,over(debt_cat) ytitle("Average real GDP growth over next four years") title("Initial debt level and subsequent growth")
<</dd_do>>
~~~~
<<dd_graph: saving(debt5year.svg) replace height(500)>>

It appears that there is no significant relationship between initial debt and subsequent GDP growth. Let's examine this more systematically using a regression. First, the descriptive statistics:

~~~~
<<dd_do>>
*create descriptive statistics table
tabstat gdpgrowth debttogdp gdppc ,statistics(mean median sd min max) columns(statistics) format(%9.1f)
<</dd_do>>
~~~~

Now, let's display the results of the regressions in a table. (`dyndoc` does not work well with `outreg` so we use `estout`.)
~~~~
<<dd_do: nooutput>>
reg gdpgrowth debttogdp
estimates store m1 
reg gdpgrowth debttogdp gdppc
estimates store m2  
reg gdpgrowth debttogdp loggdppc
estimates store m3
<</dd_do>>
~~~~

~~~~
<<dd_do>>
estout m1 m2 m3, cells(b(star fmt(3)) se(par fmt(3))) legend stats(r2 N)
<</dd_do>>
~~~~

The regression results show statistically significant negative relationship between debt and subsequent growth. This is somewhat contradictory to the box plot we examined above, but consistent with the findings of Eberhardt and Presbitero (2015). 

### Conclusion

As described in [Gentzkow and Shapiro (2014)](http://web.stanford.edu/~gentzkow/research/CodeAndData.pdf), doing empirical work involves writing a lot of code. Code makes analysis reproducible, less prone to errors, and easily extendable. This note introduced the concepts of retrieving, manipulating and analyzing data using Stata code. Although, the empirical results are just the first pass, they are meaningful, consistent with existing finding, and, importantly, can be used as a starting point for further analysis. 

### References

Eberhardt, M. & Presbitero, A. F. (2015), 'Public debt and growth: Heterogeneity and non-linearity', *Journal of International Economics* 97(1), 45--58.

Gentzkow, M. & Shapiro, J. M. (2014), 'Code and data for the social sciences: A practitioner’s guide', University of Chicago mimeo. Last updated January.

Herndon, T.; Ash, M. & Pollin, R. (2014), 'Does high public debt consistently stifle economic growth? A critique of Reinhart and Rogoff', *Cambridge journal of economics* 38(2), 257--279.

Panizza, U. & Presbitero, A. F. (2014), 'Public debt and economic growth: is there a causal effect?', *Journal of Macroeconomics* 41, 21--41.

Reinhart, C. M. & Rogoff, K. S. (2010), 'Growth in a Time of Debt', *American Economic Review* 100(2), 573-78.

