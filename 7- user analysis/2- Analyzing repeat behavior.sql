USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							ANALYZING REPEAT BEHAVIOR
		Analyze the minimum, maximum, and average time between the first and the second session for the customer
		who comeback
===================================================================================================================*/

SELECT new_sessions.user_id
	,new_sessions.website_session_id AS new_session_id
	,time_first_session
	,ws.created_at AS repeat_created_at
	,ws.website_session_id AS repeat_session_id 
INTO #session_w_repeats
FROM
	(SELECT website_session_id
		, [user_id]
		,created_at time_first_session
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

SELECT [user_id]
	, DATEDIFF(DAY, time_first_session, second_sessions_created_at)*1.0 AS days_first_to_second_session
INTO #user_first_to_second1
FROM (
SELECT 
	[user_id]
	,new_session_id
	,time_first_session
	,MIN(repeat_session_id) as second_session_id
	,MIN(repeat_created_at) as second_sessions_created_at
FROM #session_w_repeats
WHERE repeat_session_id IS NOT NULL
GROUP BY [user_id], new_session_id, time_first_session) AS first_to_second
GO

SELECT 
	AVG(days_first_to_second_session) as avg_days_first_to_second
	,MIN(days_first_to_second_session) as min_days_first_to_second
	,MAX(days_first_to_second_session) as max_days_first_to_second
FROM #user_first_to_second1
