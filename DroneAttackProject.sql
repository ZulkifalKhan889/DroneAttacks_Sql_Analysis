




SELECT * FROM sql_store.droneattacks7
limit 10
;


#changing column name
alter table droneattacks7 change  ï»¿S_No
`S.No` int;

#now fata is the part of kpk so we should rename fata to  kpk

set sql_safe_updates = 0;

select * from 
DroneAttacks7
where province = 'fata';

update droneattacks7 
set province = 'kpk'

where province = 'fata';

select * from droneattacks7 
where province = 'fata';
#Done

#now our date is text column so we have to change it in left side schema it is shown as text and also the time is text
#use capital %Y beacuse the date is in four digit if it was in 2 digit like 23 inplace of 2023 then small y
update droneattacks7
set `Date` = str_to_date(date, '%m/%d/%Y');

alter table  droneattacks7
modify column `date` date;
alter table droneattacks7 
modify column `date` date;

#Done with date




CREATE TABLE `droneattacks72` (
  `S.No` int DEFAULT NULL,
  `date` date DEFAULT NULL,
  `Time` text,
  `Location` text,
  `City` text,
  `Province` text,
  `No_of_Strike` int DEFAULT NULL,
  `Al_Qaeda` int DEFAULT NULL,
  `Taliban` int DEFAULT NULL,
  `Civilians_Min` int DEFAULT NULL,
  `Civilians_Max` int DEFAULT NULL,
  `Foreigners_Min` int DEFAULT NULL,
  `Foreigners_Max` int DEFAULT NULL,
  `Total_Died_Min` int DEFAULT NULL,
  `Total_Died_Max` int DEFAULT NULL,
  `Injured_Min` int DEFAULT NULL,
  `Injured_Max` int DEFAULT NULL,
  `Women_Children` int DEFAULT NULL,
  `Comments` text,
  `Source_Name` text,
  `Longitude` double DEFAULT NULL,
  `Latitude` double DEFAULT NULL,
  `Temperature_C` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select * from droneattacks72;
drop table droneattacks72;
insert into droneattacks72 
select * from droneattacks7;

#we made a copy of dronattack7 which is droneattacks72 we will be using this data and the other will be our backup so 
#we dont lose it 

select * from droneattacks72;

#correcting the time column which is text 
#include p cox of pm and am
#all in small not capital like h i and s p


update droneattacks72
set `Time` = str_to_date(Time, '%h:%i:%s %p');

#now remember when we importing data to sql did remove null and replaced it with -1 in integer columns because
#it was making problem now we are again converitng those columns into null where value is -1

update droneattacks72 
set latitude = null
where latitude  = -1;


 select * from droneattacks72
 where time = '00:00:00';

#Best reported channel 
select source_Name, count(source_Name)
from droneattacks
group by source_Name
order by count(source_Name) desc;

#changinfg name into some formal one
rename Table droneattacks72 to droneattacks;

select * from droneattacks;

select * from droneattacks
where province <> 'kpk';



select *  from droneattacks
limit 6;

select `s.No`, `date`, location, city,No_of_Strike 
from droneattacks
where No_Of_strike =( 
select max(No_Of_Strike)
from droneattacks);


#it means may be these people are directly hit by bomb and directly died without injuring it 
select * from droneattacks 
where (Total_Died_Min> 0 and Total_Died_Max > 0)
and (injured_min = 0 and injured_max = 0);



#using coalesc if nulls come it is treated as zero
select 
round((coalesce(civilians_min,0) + coalesce(civilians_max,0))/2) as Civilians 
from droneattacks;

#inserting a new emoty column
alter table droneattacks add avg_civilians_died int;



set sql_safe_updates = 0;
update droneattacks 
set avg_civilians_died = round((coalesce(civilians_min,0) + coalesce (civilians_max,0))/2);

select * from droneattacks;

#moving the above calculated column to left side from the end
alter table droneattacks 
modify column avg_civilians_died int after civilians_max;
	

select total_died_min, total_died_max,
round(coalesce(total_died_min, 0) + coalesce(total_died_max,0)/2) as Avg_died
from droneattacks;

alter table droneattacks 
add column avg_died int;


set sql_safe_updates = 0;
update droneattacks 
set avg_died = (coalesce(total_died_min,0)+ coalesce(total_died_max, 0)/2);

alter table droneattacks modify column avg_died int after total_died_max;

select * from droneattacks;

alter table droneattacks add column avg_injured int;

update  droneattacks 
set avg_injured = round(coalesce(Injured_min,0) + coalesce(injured_max,0)/2);

alter table droneattacks modify column avg_injured 
int after injured_max;

#our province column is somewhere kpk and in some place it is KPK

update droneattacks 
set province = upper(province);

select * from droneattacks where

location like '%shah';

update droneattacks 
set location = 'Miran shah'
where location = 'miran shah';

#drop locaion cause we already have latitude and longitude

alter table droneattacks 
drop column location;
select * from droneattacks;

select * from droneattacks7
where time = '12:00:00 pm';
#we will handle null in power bi cause we can ignore it when doing visulaization like sum and avg

#now another problem is time which is inserted as '00:00:00 when we were importing the data'
#so the 00:00:00 does not mean that 12:00:00 coz we checked it in our originla table there is  record of 12:00:00
#which is in that same format so just goinf to make it  null and will ignore it we can replace it with mode but i am not good with it so null 

update droneattacks
set time  = null
where time = '00:00:00';


set sql_safe_updates = 0;
update droneattacks
set city = 'South Waziristan' 
where city = 'south Waziristan';
#done with time

select * from droneattacks;

#done with the cleaning except null value which are many so we are gonna ignore it in the dashobaords

#now we are importing data to power bi so it will replace null with 0
#so we just puttinh a value that can be used in place of null
#

set sql_safe_updates = 0;
update droneattacks 
set Total_died_min = -1
where Total_died_min is null;
select  * from droneattacks;



alter table droneattacks add column  avg_foreigners_died int;

update droneattacks 
set avg_foreigners_died = round(coalesce(foreigners_min, 0) + coalesce(foreigners_max,0)/2);


alter table droneattacks modify column avg_foreigners_died int after avg_civilians_died;

#so we calculated the acg died foreigners we dont nedd the max and min in my anayysis so go on drop it

alter table   droneattacks drop column foreigners_max;
















#Total no of strikes
select count(no_of_strike) 
from droneattacks;

#now if we have to find the no of attacks in bush era, obama era and trump era then we have to find thier tenure time 
#which we can do it using date columns 

select min(date), max(date) from droneattacks;
#so after we find the min date and max date then we have to do a litttle reaearch 
#in findng trumps tenure , obama tenure , and bush tenure in internet 

#so we find that george bush tenure was from jan 20 2001 to jan 20 2009
#obama was jan 20, 2009 to jan 20 , 2017
#trump's tenure was jan 20 2017 to jan 20 2021

#bush tenure
select * from droneattacks;
select * from droneattacks where date < '2009-01-20';



#Obama's tenure

select * from droneattacks
where date between  '2009-01-20' and '2017-01-20';

select * from droneattacks where date < '2021-01-20' and date > '2017-01-20';


alter table droneattacks add column Tenure text;
select * from droneattacks;

update droneattacks set tenure = 'George Bush'
where date < '2009-01-20';


set sql_safe_updates = 0;
update droneattacks set tenure = 'Barack Obama'
where date between '2009-01-20' and '2017-01-20';

update droneattacks set tenure = 'Donald Trump'
where date >= '2017-01-20' and date < '2021-01-20';

select * from droneattacks;
#now we have a separate column of tenure which represent the attacks happened in a particular president tenure

select sum(No_Of_Strike) as Total_Strikes from droneattacks
where tenure = 'Barack Obama';

select sum(No_Of_Strike) from droneattacks 
where tenure = 'Donald Trump';

select sum(No_Of_Strike) from droneattacks 
where tenure = 'George Bush';

select * from droneattacks;

#most Drone strikes in a city

select city,sum(No_Of_Strike) as strikes  from 
droneattacks group by city
order by strikes desc;

#only one city record is there which is not from kpk
select city, sum(No_Of_Strike) as Strikes 
from droneattacks
where Province <> 'KPK' 
group by city;

#find city and strikes that majority civilains died from only one strike
#worst attack it has killed more civilians and taliban and alqaeda are unknown
SELECT 
   Date,tenure, No_Of_Strike, city, avg_civilians_died
FROM
    droneattacks
WHERE
    avg_civilians_died IN (SELECT 
            MAX(avg_civilians_died)
        FROM
            droneattacks);
            
#Multiple sTRIKES THAT HAPPENed IN ONLY ONE DAY		
select date, No_of_Strike, avg_civilians_died
from droneattacks group by date, No_of_Strike,avg_civilians_died
order by No_of_Strike desc; 

select sum(No_Of_Strike) from droneattacks 
where Women_Children = -1;

#area of concern for human right 
select * from droneattacks where
Women_Children = -1;

#Finding strikes that happened in night
SELECT 
    SUM(No_of_Strike), SUM(avg_civilians_died)
FROM
    droneattacks
WHERE
    Time BETWEEN '19:00:00' AND '5:00:00'
GROUP BY No_of_Strike , avg_civilians_died
ORDER BY SUM(avg_civilians_died) DESC;


