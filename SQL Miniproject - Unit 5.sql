
/* 
-- UNIT 5 - SQL Miniproject
--
-- Laura Gascue
--

The "country_club" database has been downloaded from the Springboard online SQL platform, 
and uploaded into a Microsoft SQL Server. The database contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

*/

---------------------------------------------------------------------------------------------------------------------------
-- EXPLORE:
-- Is there a unique facility identifier in the Facilities table?


SELECT COUNT(*) AS number_of_lines, COUNT(DISTINCT facid) AS number_of_facilities
FROM dbo.Facilities;

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT facid, name, membercost
FROM dbo.Facilities
WHERE membercost >0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(DISTINCT facid) as facilities_with_no_fee
FROM  dbo.Facilities
WHERE membercost =0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM dbo.Facilities
WHERE membercost/monthlymaintenance <.2


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM dbo.Facilities
WHERE facid IN(1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name, CASE WHEN monthlymaintenance<=100 THEN 'cheap'
		ELSE 'expensive' END AS maintenance_type,
		monthlymaintenance
FROM dbo.Facilities
ORDER BY name

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate
FROM dbo.Members a INNER JOIN 
	(SELECT MAX(joindate) as max_joindate from dbo.Members) b
	on a.joindate = b.max_joindate


/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT concat(c.firstname,' ',c.surname) as Member_Name, name as facility_name
FROM dbo.Bookings a  
		INNER JOIN (SELECT DISTINCT facid, name FROM dbo.FacilitIes WHERE upper(name) LIKE '%Tennis%') b ON a.facid=b.facid
		LEFT JOIN dbo.Members c ON a.memid=c.memid
ORDER BY Member_Name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT a.starttime, b.name, concat(c.firstname,' ',c.surname) as member_name, 
	CASE WHEN a.memid!=0 THEN b.membercost
		ELSE b.guestcost END AS cost
FROM dbo.Bookings a 
	LEFT JOIN dbo.Facilities b ON a.facid=b.facid 
	LEFT JOIN dbo.Members c ON a.memid=c.memid
WHERE cast(a.starttime as date)='09/14/2012' AND 
	(b.membercost > 30 AND a.memid != 0 OR b.guestcost > 30 AND a.memid=0)
ORDER BY 3 DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT a.starttime, concat(c.firstname,' ',c.surname) as member_name, b.membercost, b.guestcost
FROM (SELECT * FROM dbo.Bookings WHERE cast(starttime as date)='09/14/2012') a
		INNER JOIN dbo.Facilities b ON a.facid=b.facid
		INNER JOIN dbo.Members c ON a.memid=c.memid
	WHERE (b.membercost > 30 AND a.memid != 0 OR b.guestcost > 30 AND a.memid=0)
ORDER BY guestcost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name, f.total_revenue
	FROM (SELECT a.name, a.membercost*c.num_members_bookings+a.guestcost*d.num_guests_bookings as total_revenue
		FROM dbo.Facilities a LEFT JOIN
			(SELECT facid, count(*) as num_members_bookings 
				FROM dbo.Bookings
				WHERE memid != 0
				GROUP BY facid) c ON a.facid=c.facid
		LEFT JOIN
			(SELECT facid, count(*) as num_guests_bookings 
				FROM dbo.Bookings
				WHERE memid = 0
				GROUP BY facid) d ON a.facid=d.facid) f
	WHERE f.total_revenue < 1000
	ORDER BY total_revenue
