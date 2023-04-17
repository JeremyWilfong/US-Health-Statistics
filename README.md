# US-Health-Statistics
**GOAL:** 
- Government wants to know the correlation between Health, Heart Disease, Poverty Rate, and Food Access(Desert).

**SOLUTION:** 
- Used SQL to create a table of different metrics for each state; analyzed correlations of the table in Excel and visualized all the data and correlations in multiple Tableau Dashboards.
- **There was a higher correlation between No/Minimum Physical Activity and Obesity than there was for No Veggies and Obesity. Lack of Physical Activity is a better indicator of someone becoming obese.**
- **There was a higher correlation between Urban Poverty and Obesity than there was for Rural Poverty and Obesity. There was also a higher correlation between Urban Poverty and Lack of Physical Activity than there was for Rural Poverty and Lack of Physical Activity. Based on these correlations, we can infer that individuals in Urban areas are more likely to become obese because of their lack of physical activity.**
- **There was very little correlation between Food Deserts and Obesity/Lack of Eating Veggies.**
- **States that had higher % of Obese people also had higher # of individuals with Heart Disease.**

**SKILLS USED:** 
- Excel for analyzing Correlations. 
- MS SQL For Joining Heart Disease, Health Statistics, and Poverty/Food Desert Tables.
- Tableau for Visualizing the Data and explaining the most notable Correlations.

**QUESTIONS ASKED:** 
- Which group in each Demographic had the highest rate of Obesity Nationwide?
- Which group in each Demographic had the highest rate of Obesity per State?
- Is there a correlation between Health, Food Desert, Poverty Rate and Heart Disease?
                 
**PROCESS:**
1. Downloaded [U.S. Health Statistics](https://catalog.data.gov/dataset/nutrition-physical-activity-and-obesity-behavioral-risk-factor-surveillance-system), [U.S. Heart Disease Rates](https://catalog.data.gov/dataset/heart-disease-mortality-data-among-us-adults-35-by-state-territory-and-county-2018-2020-3a2b0), and [Food Access/Poverty Rate](https://www.ers.usda.gov/data-products/food-access-research-atlas/download-the-data/) Tables from Data.Gov.
  - The Health Statistics table had different questions that the government asked to a Sample Population of each county in each state. Below are the questions:
    - Percent of adults who report consuming fruit less than one time daily
    - Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic   activity (or an equivalent combination)
    - Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic physical activity and engage in muscle-strengthening activities on 2 or more days a week
    - Percent of adults who engage in muscle-strengthening activities on 2 or more days a week
    - Percent of adults who achieve at least 300 minutes a week of moderate-intensity aerobic physical activity or 150 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)
    - Percent of adults aged 18 years and older who have an overweight classification
    - Percent of adults aged 18 years and older who have obesity
    - Percent of adults who report consuming vegetables less than one time daily
    - Percent of adults who engage in no leisure-time physical activity
  - I created an average % of question for each state based on the county data.
2. Cleaned the datasets, matched primary keys by Location Abbreviation and explored them in SSMS.
3. Queried a large table by joining all three Data.Gov Tables. This table ("Data_For_Statistical_Analysis") was used to do correlations in Excel. This table also showed the Most Obese of Each Demographic by state.
4. Used Excel to create correlations between different Categories. (=Correl Function)
5. Visualized all the data and explained the most notable correlations in Tableau.
