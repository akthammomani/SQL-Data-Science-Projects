/* QUESTIONS */

/* 
Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. 
*/

SELECT
    name AS Facility,
    membercost
FROM Facilities
WHERE membercost> 0
GROUP BY Facility
ORDER BY membercost;


/* 
Q2: How many facilities do not charge a fee to members? 
*/

SELECT
    COUNT(*) AS Facilities_Count
FROM Facilities
WHERE membercost = 0;


/* 
Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. 
*/

SELECT
    facid,
    name AS Facility,
    membercost,
    monthlymaintenance
FROM Facilities
WHERE membercost > 0 AND membercost < monthlymaintenance * 0.2
GROUP BY facid,Facility,membercost,monthlymaintenance
ORDER BY monthlymaintenance;


/* 
Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. 
*/

SELECT *
FROM Facilities 
where facid IN (1, 5);


/* 
Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. 
*/

SELECT 
    name AS Facility,
    monthlymaintenance, 
    CASE WHEN monthlymaintenance <= 100 THEN 'cheap'
         ELSE 'expensive' END AS Monthly_Maintenance_Label
FROM Facilities 
GROUP BY Facility, monthlymaintenance, Monthly_Maintenance_Label;


/* 
Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. 
*/

SELECT
    firstname, 
    surname
FROM Members
WHERE joindate
    IN (SELECT 
            MAX(joindate)
	    FROM Members);


/* 
Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. 
*/

SELECT 
    f.name AS Facility,
    CONCAT(m.firstname, ' ', m.surname) AS Member
FROM Facilities AS f
    INNER JOIN Bookings AS b
      ON f.facid = b.facid
    INNER JOIN Members AS m
      ON b.memid = m.memid
WHERE f.name LIKE 'Tennis%'
    AND m.firstname NOT LIKE 'GUEST%'
GROUP BY Member; 
 

/* 
Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. 
Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. 
*/

SELECT 
    name AS Facility,
    CONCAT(firstname, ' ', surname) AS Member,
    SUM(slots) * (CASE WHEN memid = 0 THEN guestcost
                       ELSE membercost END) AS Cost
FROM Bookings
    INNER JOIN Facilities USING (facid) 
    INNER JOIN Members USING (memid)
WHERE starttime LIKE '2012-09-14%'
GROUP BY Facility, Member
HAVING Cost > 30
ORDER BY Cost DESC;

-- and below Query in case we need to filter out 'GUEST GUEST':

SELECT 
    name AS Facility,
    CONCAT(firstname, ' ', surname) AS Member,
    SUM(slots) * membercost AS Cost
FROM Bookings
    INNER JOIN Facilities USING (facid) 
    INNER JOIN Members USING (memid)
WHERE starttime LIKE '2012-09-14%'
    AND firstname NOT LIKE 'GUEST%'
GROUP BY Facility, Member
HAVING Cost > 30
ORDER BY Cost DESC;


/* 
Q9: This time, produce the same result as in Q8, but using a subquery. 
*/
SELECT 
    Facility,
    CONCAT( m.firstname, ' ', m.surname ) AS Member,
    (CASE WHEN m.memid =0 THEN guestcost
          ELSE membercost END) * b.slots AS Cost
FROM Members AS m,
     (SELECT
         SUM(slots) AS slots,
         memid,
         facid 
     FROM Bookings
	 WHERE starttime LIKE '2012-09-14%'
	 GROUP BY facid, memid) AS b,
     (SELECT
         name AS Facility,
         facid, 
         guestcost, 
         membercost
     FROM Facilities) AS f
WHERE m.memid = b.memid AND f.facid = b.facid
GROUP BY Facility, Member
HAVING Cost >30
ORDER BY Cost DESC;