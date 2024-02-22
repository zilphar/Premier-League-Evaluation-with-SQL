CREATE DATABASE Premier_League; 

-- Correcting Wrongly Formatted data 
	-- M Atkinson is Misspelled twice as Mn Atkinson (According to the premier league results no such Ref as Mn Atkinson officiated a match)
	UPDATE [season-0910]
	SET Referee = 'M Atkinson' 
	WHERE Referee = 'Mn Atkinson'; 

	-- S Bennett is misspelled one time too 
	UPDATE [season-0910]
	SET Referee = 'S Bennett' 
	WHERE Referee = 'St Bennett'; 


SELECT 
	DISTINCT HomeTeam     -- a total of 20 teams in both home and away 
FROM [season-0910]; 

SELECT 
	DISTINCT Awayteam
FROM [season-0910]; 

-- 17 Unique referees in the dataset 
SELECT 
	DISTINCT Referee
FROM [season-0910]; 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1. The number of matches Manchester United won either home and away (27 matches)
--The CASE statement checks each row to see if it meets certain conditions. 
	--If the condition is true, it returns 1; otherwise, it returns 0. 
	--The SUM function then adds up all these 1s and 0s, effectively counting the number of rows that meet the condition. 
	--Here, it's counting the number of matches where Manchester United won, either as the home team (HomeTeam = 'Manchester United' and FTR = 'H') or as the away team (AwayTeam = 'Manchester United' and FTR = 'A'). The result is assigned an alias total_wins.

SELECT
	SUM(CASE WHEN(HomeTeam = 'Man United' AND FTR = 'H') OR (AwayTeam = 'Man United' AND FTR = 'A') THEN 1 ELSE 0 END) AS total_ManU_wins
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR AwayTeam = 'Man United'); 


--2. Number of matches Manchester won at home and away (16 homewins, and 11 away wins)
--In this case, the CASE statement counts the number of matches where Manchester United won as the home team (FTR = 'H'). The result of this calculation is aliased as Home_wins. 
	--It then counts the number of matches where Manchester United won as the away team (FTR = 'A'). The result of this calculation is aliased as away_wins. 

SELECT 
	SUM(CASE WHEN HomeTeam = 'Man United' AND FTR = 'H' THEN 1 ELSE 0 END) AS Home_wins,
	SUM(CASE WHEN AwayTeam = 'Man United' AND FTR = 'A' THEN 1 ELSE 0 END) AS Away_wins
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR AwayTeam = 'Man United'); 


-- 3. Number of goals manchester scored during the season 
--The first SUM function calculates the total number of goals scored by Manchester United in home matches (HomeTeam = 'Manchester United'). 
	--It uses the FTHG (Full-Time Home Goals) column to count the goals scored.
	--The second SUM function calculates the total number of goals scored by Manchester United in away matches (AwayTeam = 'Manchester United'). 
	--It uses the FTAG (Full-Time Away Goals) column to count the goals scored. 
	
	-- total home and  away goals in season 0910 (52 home goals, and 34 away goals)
SELECT 
	SUM(CASE WHEN HomeTeam = 'Man United' THEN FTHG ELSE 0 END) AS home_goals, 
	SUM(CASE WHEN AwayTeam = 'Man United' THEN FTAG ELSE 0 END) AS away_goals
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR AwayTeam = 'Man United'); 

	-- total goals in the season 0910 (86 goals)
SELECT 
	SUM(CASE WHEN HomeTeam = 'Man United' THEN FTHG ELSE 0 END) + 
	SUM(CASE WHEN AwayTeam = 'Man United' THEN FTAG ELSE 0 END) AS Total_manU_goals
	FROM [season-0910]
WHERE HomeTeam = 'Man United' OR Awayteam = 'Man United'; 


-- 4. yellow cards Manchester United got in the season 0910 with Martin Atkinson as the Referee (Chose Martin Atkinson because he is regarded one of the best Refs in Football history)
	-- total yellow cards
SELECT 
	SUM(CASE WHEN HomeTeam = 'Man United' THEN HY ELSE 0 END) AS home_cards,
	SUM(CASE WHEN AwayTeam = 'Man United' THEN AY ELSE 0 END) AS away_cards
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR Awayteam = 'Man United'); 
	
	-- total yellow cards with Atkinson as the referee 
SELECT Date,
	SUM(CASE WHEN HomeTeam = 'Man United' THEN HY ELSE 0 END) AS home_yellowcards,
	SUM(CASE WHEN AwayTeam = 'Man United' THEN AY ELSE 0 END) AS away_yellowcards
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR Awayteam = 'Man United') AND Referee = 'M Atkinson'
GROUP BY Date;


-- 5 Redcards Manchester recieved when M Atkinson was the Referee
	-- Total redcards Manchester United recieved duing the 0910 season (0 homeredcards, and 4 awayredcards)
SELECT
	SUM(CASE WHEN HomeTeam = 'Man United' THEN HR ELSE 0 END) AS home_redcards,
	SUM(CASE WHEN AwayTeam = 'Man United' THEN AR ELSE 0 END) AS away_Redcards
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR Awayteam = 'Man United');  -- AND Referee = 'M Atkinson';  

	-- Redcards recieved during the 0910 season with M Atkinson as the Ref (0 for both home and away)
SELECT
	SUM(CASE WHEN HomeTeam = 'Man United' THEN HR ELSE 0 END) AS home_redcards,
	SUM(CASE WHEN AwayTeam = 'Man United' THEN AR ELSE 0 END) AS away_Redcards
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR Awayteam = 'Man United') AND Referee = 'M Atkinson';


-- 6. Referees who officiated the most matches (M Atkinson and M Clattenburg officiated the most matches with 31 matches each in the season)
SELECT 
	Referee,
	COUNT(Referee) AS matches_officiated, 
	RANK() OVER(ORDER BY COUNT(Referee) DESC) AS matches_officiated_rank -- creates a rank in descending order with Referees that ties with Number of matches having the same rank 
FROM [season-0910]
GROUP BY Referee; 

-- 7. Teams that had the highest home and away goals
SELECT HomeTeam,
	SUM(FTHG) AS h_goals    -- Chelsea is leading with 68 home goals with Man United beeing the second with 52 goals
FROM [season-0910]
GROUP BY HomeTeam
ORDER BY h_goals DESC;

SELECT AwayTeam,
	SUM(FTAG) AS a_goals    -- Arsenal and Chelsea lead with 35 away goals each 
FROM [season-0910]
GROUP BY AwayTeam
ORDER BY a_goals DESC;

-- 8. Teams with the most matches won in both home and away 
SELECT HomeTeam,
	COUNT(FTR) AS home_win    -- Chelsea had the most matches won at 17 followed by Man United at 16 won home matches. 
FROM [season-0910]
WHERE FTR = 'H'
GROUP BY HomeTeam
ORDER BY home_win DESC; 

SELECT AwayTeam, 
	COUNT(FTR) AS away_win   -- Man United had the most won away matches with 11 followed by Chelsea at 10 won away matches. 
FROM [season-0910]
WHERE FTR = 'A'
GROUP BY AwayTeam
ORDER BY away_win DESC; 

-- 9. Number of draw matches in the Season0910
SELECT 
	COUNT(FTR) AS Draws  -- 96 total draws 
FROM [season-0910]
WHERE FTR = 'D'; 

	-- total Man U draws (4 draws)
SELECT HomeTeam, AwayTeam, FTAG, FTHG,
	COUNT(FTR) AS ManU_Draws
FROM [season-0910]
WHERE (HomeTeam = 'Man United' OR AwayTeam = 'Man United') AND FTR = 'D'
GROUP BY HomeTeam, AwayTeam, FTAG, FTHG; 

	-- out of the draws from the season which ones are from when Man United was the Home team
		-- 1 draw where Man United is the Hometeam (Away team was Sunderland) with a draw of 2 goals each  
SELECT HomeTeam,AwayTeam, FTAG, FTHG,
	COUNT(FTR) AS ManU_Draws
FROM [season-0910]
WHERE HomeTeam = 'Man United' AND FTR = 'D'
GROUP BY HomeTeam, AwayTeam, FTAG, FTHG; 

	-- who where the referees in these Man United matches where the final outcome is a draw 
WITH TotalDraws AS(
	SELECT *,
		COUNT(FTR) OVER() AS ManU_Draws
	FROM [season-0910]
	WHERE (HomeTeam = 'Man United' OR AwayTeam = 'Man United') AND FTR = 'D')

SELECT HomeTeam, AwayTeam, Referee
FROM TotalDraws
GROUP BY HomeTeam, AwayTeam, Referee; 

	
















