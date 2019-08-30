USE Project_8_UFC;

#################### QUERIES AND VIEWS ####################

#1 VIEWS (Test for the VIEWS are below)

#1.1 this VIEW was designed to pull fight results (I was able to figure out how to merge two rows into one)
CREATE OR REPLACE VIEW FightResults
AS
 SELECT Date, event_name AS 'Event',`Match`,
	CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(first_name), ',', 1), ',', -1),' ',
	SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(last_name), ',', 1), ',', -1)) AS First_Fighter, 
	SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(win_or_loss), ',', 1), ',', -1) AS First_Fighter_Result,
 CONCAT(if(length(GROUP_CONCAT(first_name)) - length(replace(GROUP_CONCAT(first_name), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(first_name), ',', 2), ',', -1) ,
       NULL),' ',
 if(length(GROUP_CONCAT(last_name)) - length(replace(GROUP_CONCAT(last_name), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(last_name), ',', 2), ',', -1) ,
       NULL)) AS Second_Fighter,
 if(length(GROUP_CONCAT(win_or_loss)) - length(replace(GROUP_CONCAT(win_or_loss), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(win_or_loss), ',', 2), ',', -1) ,
       NULL) Second_Fighter_Result, result_or_method AS Winning_Method
FROM fighters
JOIN fighter_matches USING (fighter_id)
JOIN venues USING (venue_id)
JOIN matches USING (match_id)
GROUP BY match_id;

#1.2 This VIEW was designed in order to pull basic information about the fighting locations
CREATE OR REPLACE VIEW FightingEvents
AS
SELECT DISTINCT `Date`, event_name AS Event, Arena, City, District_or_Country, Country
FROM matches
JOIN fighter_matches USING (match_id)
JOIN venues USING (venue_id)
ORDER BY date;

#1.3 This VIEW combines information from the first 2 VIEWS, it has information about event locations and results
CREATE OR REPLACE VIEW EventResults
AS
 SELECT Match_ID, Date, event_name AS Event, Arena, City, District_or_Country, Country,`Match`, 
	CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(first_name), ',', 1), ',', -1),' ',
	SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(last_name), ',', 1), ',', -1)) AS First_Fighter, 
	SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(win_or_loss), ',', 1), ',', -1) AS First_Fighter_Result,
	CONCAT(if(length(GROUP_CONCAT(first_name)) - length(replace(GROUP_CONCAT(first_name), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(first_name), ',', 2), ',', -1) ,
       NULL),' ',
	if(length(GROUP_CONCAT(last_name)) - length(replace(GROUP_CONCAT(last_name), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(last_name), ',', 2), ',', -1) ,
       NULL)) AS Second_Fighter,
	if(length(GROUP_CONCAT(win_or_loss)) - length(replace(GROUP_CONCAT(win_or_loss), ',', ''))>=1,  
       SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(win_or_loss), ',', 2), ',', -1) ,
       NULL) Second_Fighter_Result, result_or_method AS Winning_Method
FROM fighters
JOIN fighter_matches USING (fighter_id)
JOIN venues USING (venue_id)
JOIN matches USING (match_id)
GROUP BY match_id;

#1.4 This VIEW has basic WIN/LOSS information about each fighter
CREATE OR REPLACE VIEW FighterStats
AS
SELECT Fighter_ID, CONCAT(first_name,' ', last_name) AS Name, 
SUM(if(win_or_loss = 'win',1,0)) AS Wins, 
SUM(if(win_or_loss = 'loss',1,0)) AS Losses,
SUM(if(win_or_loss = 'draw',1,0)) AS Draws, 
SUM(if(win_or_loss = 'No Contest',1,0)) AS 'No Contest'
FROM fighters
JOIN fighter_matches USING (fighter_id)
GROUP BY fighter_id
ORDER BY Wins DESC, Losses ASC;

#################### Here I'm testing the VIEWS from above ####################

#1.1.1 Here we see the whole table containing fighting results
SELECT * 
FROM FightResults;

#1.1.2 Here I'm searching data about Donald Cerrone, one of the top fighters in UFC
SELECT * 
FROM FightResults
WHERE First_Fighter LIKE '%cerrone%' OR Second_Fighter LIKE '%cerrone%';

#1.2.1 Here we see the whole table containing information on event locations
SELECT * 
FROM FightingEvents;

#1.2.2 Here I'm testing the event table by checking which events happened in Las Vegas
SELECT * 
FROM FightingEvents
WHERE city LIKE '%vegas%';

#1.3.1 Here we see information aout all the events and fights
SELECT * 
FROM EventResults;

#1.3.2 Here I am checking which fights Cerrone had in Vegas
SELECT * 
FROM EventResults
WHERE city LIKE '%vegas%' AND (first_fighter LIKE '%corrone%' OR second_fighter LIKE '%cerrone%');

#1.4.1 Here I check fighter WIN/LOSS statistics
SELECT *
FROM FighterStats;

#2 QUERY TEST
#These are basic queries designed in order to check data flow between tables.

#2.1 This query shows fighter Names and Nicknames
SELECT Fighter_ID, CONCAT(first_name,' ', last_name) AS Name, Nickname
FROM fighters
ORDER BY fighter_id ASC;

#2.2 This query shows fighter weight classes associated with them
SELECT Fighter_ID, CONCAT(first_name,' ',last_name) AS Name, Weight_Class
FROM fighters
JOIN fighters_weight_classes USING (fighter_id)
JOIN weight_classes USING (weight_class_id);

#2.3 This query shows the total number of fights per Arena
SELECT Arena, COUNT(fighter_id) AS 'Number of Fights'
FROM fighters
JOIN fighter_matches USING(fighter_id)
JOIN venues USING (venue_id)
GROUP BY arena
ORDER BY COUNT(fighter_id) DESC;

#2.4 This query shows how many fighters are in each weight class
#In the beginning of UFC there were no weight classes, hence many fighters
#have no weight classes, or their weight class  is unknown
SELECT weight_class, COUNT(fighter_id) AS 'Weight Class'
FROM fighters
JOIN fighters_weight_classes USING(fighter_id)
JOIN weight_classes USING (weight_class_id)
GROUP BY weight_class
ORDER BY COUNT(fighter_id) DESC;
