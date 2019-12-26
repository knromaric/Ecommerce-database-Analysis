USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							IDENTIFY REPEAT VISITORS
		Pull data on how many of our website visitors come back for another session.
===================================================================================================================*/

--step 1: Identify the relevant new sessions
SELECT new_sessions.user_id
	,new_sessions.website_session_id AS new_session_id
	,ws.website_session_id AS repeat_session_id 
INTO #session_w_repeats
FROM
	(SELECT website_session_id
		, [user_id]
	FROM website_sessions
	WHERE created_at < '20141101'
		AND created_at >='20140101'
		AND is_repeat_session = 0) AS new_sessions
	LEFT JOIN website_sessions ws
		ON ws.user_id = new_sessions.user_id
		AND ws.is_repeat_session = 1 -- was as repeat session
		AND ws.website_session_id > new_sessions.website_session_id -- was later than new session
		AND created_at < '20141101'
		AND created_at >='20140101';
GO

--step 2: Use the user_id values from step 1 to find any repeat sessions those users had
SELECT 
	repeat_sessions
	,COUNT(DISTINCT [user_id]) AS users
FROM(
SELECT [user_id]	
	,COUNT(DISTINCT new_session_id) AS new_sessions
	,COUNT(DISTINCT repeat_session_id) AS repeat_sessions
FROM #session_w_repeats
GROUP BY [user_id]) AS user_level
GROUP BY repeat_sessions
GO


/*
repeat_sessions        users
---------------        -----------
0                      126782
1                      14090
2                      313
3                      4685

*/