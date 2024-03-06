
-- WORKING WITH THE PREMIER LEAGUE SEASON2223 DATASET

--1. General analysis 
-- Teams that played in premier league season2223 (A total of 20 Unique teams)
SELECT DISTINCT HomeTeam
FROM [season - 2223]; 

SELECT DISTINCT AwayTeam
FROM [season - 2223];

-- Referees who officiated a match (23 Referees who officiated a match)
SELECT DISTINCT Referee
FROM [season - 2223]; 

/*SELECT TOP 2 *
FROM [season - 2223]; */

-- Correcting the data 
	-- Nottingham Forest is shortened as 'Nott'm Forest' 
	UPDATE [season - 2223]  -- changes the name of the hometeam 
	SET HomeTeam = 'Nottingham Forest' 
	WHERE HomeTeam = 'Nott''m Forest'; 

	UPDATE [season - 2223]
	SET AwayTeam = 'Nottingham Forest' 
	WHERE AwayTeam = 'Nott''m Forest'; 

	--renaming the AS and HS column names so that they do not result to confusion with aliasing (AS) when working with the number of shots taken by the teams
	EXEC sp_rename '[season - 2223].HS', 'Home Shots', 'COLUMN'; -- EXEC excecutes the sp rename stired procedure and renames the column from 'HS' to 'Home Shots' '
	EXEC sp_rename '[season - 2223].AS', 'Away Shots', 'COLUMN'; 
	
-- total matches as home/away wins, and draws (184 home win matches, 109 away win matches, and 87 draws) (Equals 380 total matches)
SELECT 
	SUM(CASE WHEN FTR = 'H' THEN 1 ELSE 0 END) AS totalhome_win_matches,  -- the CASE statement goes through the column FTR and returns a 1 where the match was a homewin (H), then the SUM statement sums these 1's and returns the number of matches which where homewins.  
	SUM(CASE WHEN FTR = 'A' THEN 1 ELSE 0 END) AS totalaway_win_matches,  
	SUM(CASE WHEN FTR = 'D' THEN 1 ELSE 0 END) AS total_draws
FROM [season - 2223]; 

--OR 

	-- the CASE statement in the COUNT aggregate function returns a column containing the HomeTeam, AwayTeam, and FTR for draws in each column. 
	-- the COUNT aggregate then counts every HomeTeam, AwayTeam, and FTR returned by the CASE statement respectively and returns the total count for each column. 
SELECT 
	COUNT(CASE WHEN FTR = 'H' THEN HomeTeam END) AS home_winmatches, 
	COUNT(CASE WHEN FTR = 'A' THEN AwayTeam END) AS away_winmatches,
	COUNT(CASE WHEN FTR = 'D' THEN FTR END) AS draws
FROM [season - 2223];


--total goals scored through the season2223 (621 homegoals, and 463 awaygoals)Totalling to 1084 goals
SELECT 
	SUM(FTHG) AS no_of_homegoals, -- sums the FTHG and FTAG separately to get the home and awayy goals. 
	SUM(FTAG) AS no_of_awaygoals
FROM [season - 2223]; 

-- average goals per match (two goals per match)
SELECT 
	(SUM(FTHG) + SUM(FTAG)) / 380 AS avg_goals -- to get average goals, you can divide the total sum of FTHG and FTAG and divide by total matches(380). 
FROM [season - 2223]; 

-- starting date and end date of the season (season started on 5th August 2022, and ended 28th May 2023)
SELECT 
	MIN(Date) AS seeason_start_date,
	MAX(Date) AS season_end_date
FROM [season - 2223]; 


-- teams with highest number of away and home goals scored in season2223 (Man City has a total of 94 goals the highest number of goals combined for both home and away matches )
WITH HomeGoals AS (
	SELECT HomeTeam,
		SUM(FTHG) AS Home_goals
	FROM [season - 2223]
	GROUP BY HomeTeam),

AwayGoals AS (
	SELECT AwayTeam,
		SUM(FTAG) AS away_goals
	FROM [season - 2223]
	GROUP BY AwayTeam)

SELECT HomeTeam, 
	SUM(Home_goals + away_goals) AS total_goals
FROM HomeGoals
	INNER JOIN AwayGoals
	ON HomeGoals.HomeTeam = AwayGoals.AwayTeam
GROUP BY HomeTeam	
ORDER BY total_goals DESC; 


-- teams and their number of home and away won matches throughout the season2223 (Man United leads with a total of 23 won matches)
WITH Home_matches AS (
	SELECT HomeTeam,
		COUNT(FTR) AS home_wonmathes
	FROM [season - 2223]
	WHERE FTR = 'H' 
	GROUP BY HomeTeam),

Away_matches AS (
	SELECT AwayTeam,
		COUNT(FTR) AS away_wonmatches
	FROM [season - 2223]
	WHERE FTR = 'H' 
	GROUP BY AwayTeam)

SELECT HomeTeam, 
	SUM(home_wonmathes + away_wonmatches) AS total_wonmatches
FROM Home_matches
	INNER JOIN Away_matches
	ON Home_matches.HomeTeam = Away_matches.AwayTeam
GROUP BY HomeTeam
ORDER BY total_wonmatches DESC; 


-- Referees who officiated the most matches (A Tylor, M Oliver, and P Tierney officiated a total of 30 matches each which happens to be the highest number of matches officiated by one Ref in the season)
SELECT Referee,
	COUNT(Referee) AS matches_officiated
FROM [season - 2223]
GROUP BY Referee
ORDER BY matches_officiated DESC; 


-- Total shots on target for each Team throughout the season
WITH H_shots_ontarget AS(
	SELECT HomeTeam,
		SUM(HST) AS home_shots_ontarget
	FROM [season - 2223]
	GROUP BY HomeTeam),

A_shots_ontarget AS(
	SELECT AwayTeam,
		SUM(AST) AS away_shots_ontarget
	FROM [season - 2223]
	GROUP BY AwayTeam)

SELECT HomeTeam, 
	SUM(home_shots_ontarget + away_shots_ontarget) AS Total_shots_ontarget
FROM H_shots_ontarget AS H
	INNER JOIN A_shots_ontarget AS A 
	ON H.HomeTeam = A.AwayTeam 
GROUP BY HomeTeam 
ORDER BY Total_shots_ontarget DESC; 


--Total shots for the teams (Created a view for the Total shots so I can reference it later)
CREATE VIEW Total_Shots AS 
	WITH H_shots AS (
		SELECT HomeTeam,
			SUM([Home Shots]) AS Home_shots
		FROM [season - 2223]
		GROUP BY HomeTeam),

	A_shots AS(
		SELECT AwayTeam,
			SUM([Away Shots]) AS Away_shots
		FROM [season - 2223]
		GROUP BY AwayTeam) 

	SELECT HomeTeam, Home_shots, Away_shots
	FROM H_shots
		INNER JOIN A_shots
		ON H_shots.HomeTeam = A_shots.AwayTeam; 

SELECT *
FROM Total_Shots
ORDER BY Home_shots DESC, Away_shots DESC; 


-- Of the total shots how many of them where from teams with 'Man' in their name 
SELECT *
FROM Total_Shots
WHERE HomeTeam LIKE 'Man%'; 


--2. Comparing the Season2223 with other seasons 
-- teams that played in season0910 but did not play the season2223 (Chose season0910 here because I had analyzed it before)
SELECT DISTINCT HomeTeam
FROM [season-0910]
EXCEPT
SELECT DISTINCT HomeTeam
FROM [season - 2223]; 

--Referees that have officiated matches in seson0910 and officiated in season2223 (A Marriner, A Tylor, and S Attwell have officiated matches in both seasons)
SELECT DISTINCT Referee 
FROM [season-0910]
INTERSECT
SELECT DISTINCT Referee
FROM [season - 2223]; 

-- comparing with season2122
	-- teams that played in season season2122 and played in season2223 (Burnley, Norwich, and Watford played in season2122 bts did not play in season2223)
	-- Burnley, Norwich and Watford were relegated from the premier League at end of season2122 meaning they did not qualify to play in the 2223 season (Makes me want to look at their performance in the season2122)
	SELECT DISTINCT HomeTeam
	FROM [season - 2122]
	EXCEPT 
	SELECT DISTINCT HomeTeam
	FROM [season - 2223]; 

	-- Referees who officiated matches in season2122 and did not officiate matches in season2223 (J Moss, K Friend, M Atkinson, and M Dean officited in Season 2122 and did not officiate in season2223)
	SELECT DISTINCT Referee
	FROM [season - 2122]
	EXCEPT 
	SELECT DISTINCT Referee
	FROM [season - 2223]


--3. ManChester United 
	--Referees who officiated matches where Man United played either as home team or away team (The referees who officiated a match while Manchester United was the home team are still the same that officiated when Manchester United was the awayteam)
	WITH Home_Referees AS(
		SELECT DISTINCT Referee
		FROM [season - 2223]
		WHERE HomeTeam = 'Man United'),

	Away_Referees AS (
		SELECT DISTINCT Referee
		FROM [season - 2223]
		WHERE HomeTeam = 'Man United')

	SELECT *
	FROM Home_Referees AS H
		INNER JOIN Away_Referees AS A
		ON H.Referee = A.Referee; 

	-- How many Red flags did Man United get through the season as the hometeam (Man United received one red card as an home team through the season2223)
	-- The match when this Red flag was given was a home win for Manchester United against Crystal Palace (2 to 1 respectively) and A Marriner was the Referee. 
	SELECT
		Date, HomeTeam, AwayTeam, HR, Referee, FTHG, FTAG
	FROM [season - 2223]
	WHERE HomeTeam = 'Man United' AND HR > 0; 

	--Red cards Man United recieved as the AwayTeam through the season (No redcards for Man United as the awayteam through the season)
	SELECT 
		COUNT(AR) AS away_redcards
	FROM [season - 2223]
	WHERE AwayTeam = 'Man United' AND AR > 0;
