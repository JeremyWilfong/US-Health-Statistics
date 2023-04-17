--We begin by cleaning the data to remove unwanted columns/rows and round percentages.

--First we will remove rows that are missing data due to small sample size.
DELETE FROM Nutrition
WHERE Data_Value_Footnote = 'Data not available because sample size is insufficient.'

Select * FROM Nutrition ORDER BY LocationDesc


--Round Percentage Data Values to 1 decimal places.
UPDATE Nutrition
SET Data_Value = ROUND(Data_Value, 2,2),
	Low_Confidence_Limit = ROUND(Low_Confidence_Limit, 2,2),
	High_Confidence_Limit = ROUND(High_Confidence_Limit, 2,2)

Select * FROM Nutrition ORDER BY LocationDesc


--It seems that YearStart and YearEnd might be the same each time. Let's find out if that is true.
Select YearStart, YearEnd, LocationDesc
FROM Nutrition
WHERE YearStart != YearEnd
--YearStart and YearEnd is the same value on each row. Lets just make 1 Year column.
ALTER TABLE Nutrition
DROP COLUMN YearEnd
EXEC sp_rename 'Nutrition.YearStart', 'Data_Year', 'COLUMN';

SELECT * FROM Nutrition


--Now that we have all of the wanted rows and columns. It's time to start exploring the data.

--What are the Questions being asked in this dataset?
SELECT DISTINCT Question, QuestionID FROM Nutrition
--ID 18, Percent of adults who report consuming fruit less than one time daily
--ID 43, Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)
--ID 44, Percent of adults who achieve at least 150 minutes a week of moderate-intensity aerobic physical activity or 75 minutes a week of vigorous-intensity aerobic physical activity and engage in muscle-strengthening activities on 2 or more days a week
--ID 46, Percent of adults who engage in muscle-strengthening activities on 2 or more days a week
--ID 45, Percent of adults who achieve at least 300 minutes a week of moderate-intensity aerobic physical activity or 150 minutes a week of vigorous-intensity aerobic activity (or an equivalent combination)
--ID 37, Percent of adults aged 18 years and older who have an overweight classification
--ID 36, Percent of adults aged 18 years and older who have obesity
--ID 19, Percent of adults who report consuming vegetables less than one time daily
--ID 47, Percent of adults who engage in no leisure-time physical activity


--What are the different demographics being represented in these percentages?
SELECT DISTINCT Stratification1 FROM Nutrition
--Education
--Age (years)
--Race/Ethnicity
--Total
--Gender
--Income


--What are the TOTAL National Averages for each year?
SELECT * FROM Nutrition
WHERE LocationDesc != 'National' AND Total = 'Total'
ORDER BY Data_Year
--2019 was the only year where the Gov recorded the total averages for all 9 Questions. 
--We will use 2019 as the main year for comparisons.


--Which age group ate the least amount of vegetables overall for 2021?
SELECT LocationDesc, Question, Data_Value, Stratification1
FROM Nutrition
WHERE LocationDesc = 'National' AND
	  QuestionID = 19.00 AND
	  Data_Year = 2021 AND
	  StratificationCategory1 = 'Age (years)'
ORDER BY LocationDesc, Stratification1 
--The age group of 18-24 eat the least amount of vegetables overall. 
	

--Which race is more likely to be obese?
SELECT Stratification1, Data_Value
FROM Nutrition
WHERE QuestionID = 36.00 AND
	  LocationDesc = 'National' AND
	  Data_Year = 2019 AND
	  StratificationCategory1 = 'Race/Ethnicity'
ORDER BY Data_Value Desc
--Hawaiian/Pacific Islander
--Which Race has the highest obesity rate in each state?
CREATE TABLE #Race_Obesity (
LocationAbbr varchar(255),
Stratification1 varchar(255)
)
INSERT INTO #Race_Obesity
SELECT LocationAbbr, Stratification1
FROM Nutrition t1
WHERE StratificationCategory1 = 'Race/Ethnicity' AND
	  Data_Year = 2019 AND
	  LocationDesc != 'National' AND
	  QuestionID = 36.00 AND
	  Data_Value = 
	   (SELECT MAX(Data_Value)
		FROM Nutrition AS t2
		WHERE t2.LocationAbbr = t1.LocationAbbr AND
		StratificationCategory1 = 'Race/Ethnicity' AND
	    Data_Year = 2019 AND
	    LocationDesc != 'National' AND
	    QuestionID = 36.00)
GROUP BY LocationAbbr, Stratification1


--Which Age Group is more likely to be obese?
SELECT Stratification1, Data_Value
FROM Nutrition
WHERE QuestionID = 36.00 AND
	  LocationDesc = 'National' AND
	  Data_Year = 2019 AND
	  StratificationCategory1 = 'Age (years)'
ORDER BY Data_Value Desc
-- Age 45-54
--Which Age Group has the highest obesity rate in each state?
CREATE TABLE #Age_Obesity (
LocationAbbr varchar(255),
Stratification1 varchar(255)
)
INSERT INTO #Age_Obesity
SELECT LocationAbbr, Stratification1
FROM Nutrition t1
WHERE StratificationCategory1 = 'Age (years)' AND
	  Data_Year = 2019 AND
	  LocationDesc != 'National' AND
	  QuestionID = 36.00 AND
	  Data_Value = (
		SELECT MAX(Data_Value)
		FROM Nutrition AS t2
		WHERE t2.LocationAbbr = t1.LocationAbbr AND
		StratificationCategory1 = 'Age (years)' AND
	    Data_Year = 2019 AND
	    LocationDesc != 'National' AND
	    QuestionID = 36.00)
GROUP BY LocationAbbr, Stratification1


--Are males or females more likely to be obese?
SELECT Stratification1, Data_Value
FROM Nutrition
WHERE QuestionID = 36.00 AND
	  LocationDesc = 'National' AND
	  Data_Year = 2019 AND
	  StratificationCategory1 = 'Gender'
ORDER BY Data_Value Desc
--Female
--Which Gender has the highest obesity rate in each state?
CREATE TABLE #Gender_Obesity (
LocationAbbr varchar(255),
Stratification1 varchar(255)
)
TRUNCATE TABLE #Gender_Obesity
INSERT INTO #Gender_Obesity
SELECT LocationAbbr,
CASE
    WHEN MAX(CASE WHEN Stratification1 = 'Female' THEN Data_Value END) = MAX(CASE WHEN Stratification1 = 'Male' THEN Data_Value END)
    THEN 'Tied'
    ELSE MAX(Stratification1)
END AS Stratification1
FROM Nutrition t1
WHERE StratificationCategory1 = 'Gender' AND
	  Data_Year = 2019 AND
	  LocationDesc != 'National' AND
	  QuestionID = 36.00 AND
	  Data_Value = (
		SELECT MAX(Data_Value)
		FROM Nutrition AS t2
		WHERE t2.LocationAbbr = t1.LocationAbbr AND
		StratificationCategory1 = 'Gender' AND
	    Data_Year = 2019 AND
	    LocationDesc != 'National' AND
	    QuestionID = 36.00)
GROUP BY LocationAbbr
SELECT * FROM #Gender_Obesity
--Oregon had Male and Female at a tie, so we used a case Statement to put "Tied" in the Stratification column


--Which Income Group (other than "data not reported") is most likely to be obese?
SELECT Stratification1, Data_Value
FROM Nutrition
WHERE QuestionID = 36.00 AND
	  LocationDesc = 'National' AND
	  Data_Year = 2019 AND
	  StratificationCategory1 = 'Income' AND
	  Stratification1 != 'Data not reported'
ORDER BY Data_Value Desc
--$15,000-$24,999
--Which Income Group has the highest obesity rate in each state?
CREATE TABLE #Income_Obesity (
LocationAbbr varchar(255),
Stratification1 varchar(255)
)
INSERT INTO #Income_Obesity
SELECT LocationAbbr, Stratification1
FROM Nutrition t1
WHERE StratificationCategory1 = 'Income' AND
	  Data_Year = 2019 AND
	  LocationDesc != 'National' AND
	  QuestionID = 36.00 AND
	  Stratification1 != 'Data not reported' AND
	  Data_Value = (
		SELECT MAX(Data_Value)
		FROM Nutrition AS t2
		WHERE t2.LocationAbbr = t1.LocationAbbr AND
		StratificationCategory1 = 'Income' AND
	    Data_Year = 2019 AND
	    LocationDesc != 'National' AND
	    QuestionID = 36.00 AND
	    Stratification1 != 'Data not reported')
GROUP BY LocationAbbr, Stratification1


--Which Education Group is more likely to be obese?
SELECT Stratification1, Data_Value
FROM Nutrition
WHERE QuestionID = 36.00 AND
	  LocationDesc = 'National' AND
	  Data_Year = 2019 AND
	  StratificationCategory1 = 'Education'
ORDER BY Data_Value Desc
--Less than High School
--Which Education Group has the highest obesity rate in each state?
CREATE TABLE #Education_Obesity (
LocationAbbr varchar(255),
Stratification1 varchar(255)
)
INSERT INTO #Education_Obesity
SELECT LocationAbbr,Stratification1
FROM Nutrition t1
WHERE StratificationCategory1 = 'Education' AND
	  Data_Year = 2019 AND
	  LocationDesc != 'National' AND
	  QuestionID = 36.00 AND
	  Data_Value = (
		SELECT MAX(Data_Value)
		FROM Nutrition AS t2
		WHERE t2.LocationAbbr = t1.LocationAbbr AND
		StratificationCategory1 = 'Education' AND
	    Data_Year = 2019 AND
	    LocationDesc != 'National' AND
	    QuestionID = 36.00)
GROUP BY LocationAbbr, Stratification1


--Which states have above the national average of obese people?
SELECT LocationDesc, Data_Value State_Avg, 
(SELECT Data_Value FROM Nutrition
WHERE LocationDesc = 'National' AND
	  Total = 'Total' AND
	  QuestionID = 36.00 AND
	  Data_Year = 2019) as National_Avg
FROM Nutrition
WHERE Total = 'Total' AND
	  QuestionID = 36.00 AND
	  Data_Year = 2019 AND
	  Data_Value > (SELECT Data_Value FROM Nutrition 
	  WHERE LocationDesc = 'National' AND
	  Total = 'Total' AND
	  QuestionID = 36.00 AND
	  Data_Year = 2019)
-- 32 states are above the National Average of Obese People



--Do the states with the most unhealthy people have more food deserts and a higher Poverty Rate?

--First we need to bring in a new table ("Food_Desert") taken from the USDA that measures food deserts among communities.
--A Food Desert is considered anyone in an urban area more than a mile from a Supermarket or in a rural area more than 10 miles from a Supermarket.

--First, we need to convert State Names in "Food_Desert" to Abbreviations so they'll join with the other tables.
SELECT * FROM Food_Desert
UPDATE Food_Desert
Set State = REPLACE(State, 'Alabama', 'AL')
     UPDATE Food_Desert Set State = REPLACE(State,'Alaska','AK')
     UPDATE Food_Desert Set State = REPLACE(State,'Arizona', 'AZ')
     UPDATE Food_Desert Set State = REPLACE(State,'Arkansas', 'AR')
     UPDATE Food_Desert Set State = REPLACE(State,'California', 'CA')
     UPDATE Food_Desert Set State = REPLACE(State, 'Colorado','CO')
     UPDATE Food_Desert Set State = REPLACE(State, 'Connecticut','CT')
     UPDATE Food_Desert Set State = REPLACE(State,'Delaware', 'DE')
     UPDATE Food_Desert Set State = REPLACE(State, 'District of Columbia', 'DC')
     UPDATE Food_Desert Set State = REPLACE(State, 'Florida', 'FL')
     UPDATE Food_Desert Set State = REPLACE(State,'Georgia','GA')
     UPDATE Food_Desert Set State = REPLACE(State, 'Hawaii','HI')
     UPDATE Food_Desert Set State = REPLACE(State, 'Idaho', 'ID')
     UPDATE Food_Desert Set State = REPLACE(State,'Illinois', 'IL')
     UPDATE Food_Desert Set State = REPLACE(State, 'Indiana', 'IN')
     UPDATE Food_Desert Set State = REPLACE(State, 'Iowa','IA')
     UPDATE Food_Desert Set State = REPLACE(State,'Kansas', 'KS')
     UPDATE Food_Desert Set State = REPLACE(State,'Kentucky', 'KY')
     UPDATE Food_Desert Set State = REPLACE(State,'Louisiana', 'LA')
     UPDATE Food_Desert Set State = REPLACE(State, 'Maine','ME')
     UPDATE Food_Desert Set State = REPLACE(State,'Maryland', 'MD')
     UPDATE Food_Desert Set State = REPLACE(State, 'Massachusetts','MA')
     UPDATE Food_Desert Set State = REPLACE(State, 'Michigan','MI')
     UPDATE Food_Desert Set State = REPLACE(State, 'Minnesota','MN')
     UPDATE Food_Desert Set State = REPLACE(State, 'Mississippi','MS')
     UPDATE Food_Desert Set State = REPLACE(State, 'Missouri','MO')
     UPDATE Food_Desert Set State = REPLACE(State, 'Montana','MT')
     UPDATE Food_Desert Set State = REPLACE(State, 'Nebraska','NE')
     UPDATE Food_Desert Set State = REPLACE(State,'Nevada', 'NV')
     UPDATE Food_Desert Set State = REPLACE(State,'New Hampshire', 'NH')
     UPDATE Food_Desert Set State = REPLACE(State,'New Jersey', 'NJ')
     UPDATE Food_Desert Set State = REPLACE(State, 'New Mexico','NM')
     UPDATE Food_Desert Set State = REPLACE(State,'New York', 'NY')
     UPDATE Food_Desert Set State = REPLACE(State,'North Carolina', 'NC')
     UPDATE Food_Desert Set State = REPLACE(State,'North Dakota', 'ND')
     UPDATE Food_Desert Set State = REPLACE(State, 'Ohio','OH')
     UPDATE Food_Desert Set State = REPLACE(State,'Oklahoma', 'OK')
     UPDATE Food_Desert Set State = REPLACE(State, 'Oregon', 'OR')
     UPDATE Food_Desert Set State = REPLACE(State, 'Pennsylvania','PA')
     UPDATE Food_Desert Set State = REPLACE(State,'Rhode Island',  'RI')
     UPDATE Food_Desert Set State = REPLACE(State,'South Carolina', 'SC')
     UPDATE Food_Desert Set State = REPLACE(State,'South Dakota', 'SD')
     UPDATE Food_Desert Set State = REPLACE(State, 'Tennessee', 'TN')
     UPDATE Food_Desert Set State = REPLACE(State,'Texas', 'TX')
     UPDATE Food_Desert Set State = REPLACE(State,'Utah', 'UT')
     UPDATE Food_Desert Set State = REPLACE(State, 'Vermont','VT')
     UPDATE Food_Desert Set State = REPLACE(State, 'Virginia', 'VA')
     UPDATE Food_Desert Set State = REPLACE(State, 'Washington','WA')
     UPDATE Food_Desert Set State = REPLACE(State,'West Virginia', 'WV')
     UPDATE Food_Desert Set State = REPLACE(State, 'Wisconsin', 'WI')
     UPDATE Food_Desert Set State = REPLACE(State,'Wyoming',  'WY')

--Create Temp Tables with all of the columns we need from the original dataset to answer our questions.
--First we create a Temp Table showing Rural Data.
CREATE TABLE #Rural_Desert (
State nvarchar(255),
Perecent_in_Poverty float,
Percent_in_Desert float,
Median_Income float)

INSERT INTO #Rural_Desert
SELECT State, ROUND(AVG(PovertyRate),2,2) Percent_in_Poverty, ROUND(AVG(TRY_CONVERT(float, lapop10share)),2,2) as Percent_in_Desert, ROUND(AVG(MedianFamilyIncome),2,2) as MedianIncome
FROM Food_Desert
WHERE Urban = 0
GROUP BY State
HAVING AVG(TRY_CONVERT(float, lapop10share)) IS NOT NULL
ORDER BY State

--Second, we create a Temp Table showing Urban Data.
CREATE TABLE #Urban_Desert (
State nvarchar(255),
Perecent_in_Poverty float,
Percent_in_Desert float,
Median_Income float)

INSERT INTO #Urban_Desert
SELECT State, ROUND(AVG(PovertyRate),2,2) Percent_in_Poverty, ROUND(AVG(TRY_CONVERT(float, lapop1share)),2,2) as Percent_in_Desert, ROUND(AVG(MedianFamilyIncome),2,2) as MedianIncome
FROM Food_Desert
WHERE Urban = 1
GROUP BY State
HAVING AVG(TRY_CONVERT(float, lapop1share)) IS NOT NULL
ORDER BY State

--Finally, We combine the 2 tables to create the final Temp Table, "Desert"
CREATE TABLE #Desert (
State nvarchar(255),
Urban_Poverty float,
Urban_Desert float,
Urban_Income float,
Rural_Poverty float,
Rural_Desert float,
Rural_Income float)

INSERT INTO #Desert
SELECT u.State, u.Perecent_in_Poverty as Urban_Poverty, u.Percent_in_Desert as Urban_Desert, u.Median_Income as Urban_Income,
	   r.Perecent_in_Poverty as Rural_Poverty, r.Percent_in_Desert as Rural_Desert, r.Median_Income as Rural_Income
FROM #Urban_Desert u
JOIN #Rural_Desert r
ON u.State = r.State


--Now that the final Temp Table is completed, it is time to compare Poverty Rate/Food Desert to Obesity Rate.
SELECT n.LocationDesc, n.Data_Value as Percent_Obese, d.Rural_Desert, d.Rural_Poverty, d.Urban_Desert, d.Urban_Poverty,
	   ROW_NUMBER() OVER(ORDER BY (h.data_value) desc) AS Obesity_Rank
FROM #Desert d
JOIN Nutrition n
ON d.State = n.LocationDesc
WHERE n.QuestionID = 36.00 AND
	  n.Total = 'Total' AND
	  n.LocationDesc != 'National' AND
	  n.Data_Year = 2019
ORDER BY Rural_Desert Desc
--Mississippi has the highest Urban and Rural Povery Rate and also has the Highest Percentage Obese.
--Doesn't seem to be a correlation between Food Desert and Obesity. We'll double check in Excel once done querying.


--Now let's compare Poverty Rate/Food Desert to Amount of Vegetables ate.
SELECT n.LocationDesc, n.Data_Value as Percent_Eating_Veggies, d.Rural_Desert, d.Rural_Poverty, d.Urban_Desert, d.Urban_Poverty,
	   ROW_NUMBER() OVER(ORDER BY (h.data_value)) AS Veggie_Rank --Higher rank means they eat more veggies.
FROM #Desert d
JOIN Nutrition n
ON d.State = n.LocationDesc
WHERE n.QuestionID = 19.00 AND
	  n.Total = 'Total' AND
	  n.LocationDesc != 'National' AND
	  n.Data_Year = 2019
ORDER BY d.Rural_Desert desc
--Poverty once again trends toward individuals eating less veggies.
--Food Desert doesn't seem to have a correlation with Amount of Veggies ate.


 --Do the states with the most unhealthy people have a higher death rate from Heart Disease/Stroke?
DELETE FROM Heart_Disease
WHERE Data_Value IS NULL

SELECT n.LocationAbbr, AVG(hd.Data_Value), AVG(n.Data_Value) 
FROM Heart_Disease hd
JOIN Nutrition n
ON hd.LocationAbbr = n.LocationAbbr
WHERE n.QuestionID = 36.00 AND
	  n.Total = 'Total' AND
	  n.LocationDesc != 'National' AND
	  n.Data_Year = 2019
GROUP BY n.LocationAbbr
ORDER BY 3 desc
--At a quick glance, there is a relationship between States with High Obesity and High Heart Disease death rate.
--We will confirm the correlation in Excel.

--Do the states with the most cardio activity have the least Heart Disease Death Rate?
SELECT n.LocationAbbr, AVG(hd.Data_Value) as Disease_Rate, AVG(n.Data_Value) as Cardio_Lvl
FROM Heart_Disease hd
JOIN Nutrition n
ON hd.LocationAbbr = n.LocationAbbr
WHERE n.QuestionID = 45.00 AND
	  n.Total = 'Total' AND
	  n.LocationDesc != 'National' AND
	  n.Data_Year = 2019
GROUP BY n.LocationAbbr
ORDER BY 3 desc
--There seems to be a correlation, but we'll determine for sure in Excel.


--Which group of people are more likely to have higher Heart Disease Rates, people who do minimal physical activity or who don't eat veggies?
--We will join 3 tables to get all the data in one view and then do statistical analysis on Excel.
SELECT hd.LocationAbbr, ROUND(AVG(hd.Data_Value),2,2) as Disease_Rate, ROUND(AVG(n1.Data_value),2,2) as No_Veggies, ROUND(AVG(n2.Data_value),2,2) as Minimum_Activity
FROM Heart_Disease hd
JOIN Nutrition n1
ON hd.LocationAbbr = n1.LocationAbbr
JOIN Nutrition n2
ON n1.LocationAbbr = n2.LocationAbbr
WHERE n1.QuestionID = 19.00 AND
	  n1.Total = 'Total' AND
	  n1.LocationDesc != 'National' AND
	  n2.QuestionID = 47.00 AND
	  n2.Data_Year = 2019 AND
	  n2.Total = 'Total' AND
	  n2.LocationDesc != 'National' AND
	  n2.Data_Year = 2019
GROUP BY hd.LocationAbbr
ORDER BY 1 



--Now that we've explored the data and know what to analyze it's
--Time to wrap this up and make the final query for our statistical analysis in Excel.

SELECT hd.LocationAbbr,
	ROUND(AVG(n3.Data_value),2,2) as Percent_Obese,
	ROUND(AVG(hd.Data_Value),2,2) as Heart_Disease_Rate_Per_100k, 
	ROUND(AVG(n1.Data_value),2,2) as No_Veggies, 
	ROUND(AVG(n2.Data_value),2,2) as Minimum_PhysActivity,
	ROUND(AVG(rd.Perecent_in_Poverty),2,2) as Rural_PovertyRate,
	ROUND(AVG(ud.Perecent_in_Poverty),2,2) as Urban_PovertyRate,
	ROUND(AVG(rd.Percent_in_Desert),2,2) as Rural_FoodDesert,
	ROUND(AVG(ud.Percent_in_Desert),2,2) as Urban_FoodDesert,
	ROUND(AVG((ud.Median_Income + rd.Median_Income)/2),0) as Median_Income,
	g.Stratification1 as Most_Obese_Gender, 
	r.Stratification1 as Most_Obese_Race, 
	a.Stratification1 as Most_Obese_Age, 
	e.Stratification1 as Most_Obese_Education, 
	i.Stratification1 as Most_Obese_Income
FROM Heart_Disease hd
JOIN Nutrition n1
	ON hd.LocationAbbr = n1.LocationAbbr
JOIN Nutrition n2
	ON n1.LocationAbbr = n2.LocationAbbr
JOIN #Rural_Desert rd
	ON n2.LocationAbbr = rd.State
JOIN #Urban_Desert ud
	ON rd.State = ud.State
JOIN Nutrition n3
	ON n2.LocationAbbr=n3.LocationAbbr
JOIN #Gender_Obesity g
	ON n3.LocationAbbr=g.LocationAbbr
JOIN #Race_Obesity r
	ON g.LocationAbbr=r.LocationAbbr
JOIN #Age_Obesity a
	ON r.LocationAbbr=a.LocationAbbr
JOIN #Education_Obesity e
	ON a.LocationAbbr=e.LocationAbbr
JOIN #Income_Obesity i
	ON e.LocationAbbr=i.LocationAbbr
WHERE n1.QuestionID = 19.00 AND
	  n1.Total = 'Total' AND
	  n1.LocationDesc != 'National' AND
	  n2.QuestionID = 47.00 AND
	  n2.Data_Year = 2019 AND
	  n2.Total = 'Total' AND
	  n2.LocationDesc != 'National' AND
	  n2.Data_Year = 2019 AND
	  n3.QuestionID = 36.00 AND
	  n3.Data_Year = 2019 AND
	  n3.Total = 'Total' AND
	  n3.LocationDesc != 'National'
GROUP BY hd.LocationAbbr, g.Stratification1, r.Stratification1, a.Stratification1, e.Stratification1, i.Stratification1
ORDER BY 1




