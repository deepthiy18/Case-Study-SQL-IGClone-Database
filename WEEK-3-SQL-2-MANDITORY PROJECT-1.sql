-- Week 3 - Mandatory Project --
-- USE this database to solve the given questions:ig_clone
-- 1.Create an ER diagram or draw a schema for the given database.
/*
-- HERE IN ig_clone database we have users,photos,likes,photo_tags,comments,follows,tags tables
-- users-pk-id ( primary key),username-not-null column(blue color),created_at-null column(white/empty dot)
-- photos-pk-id ( primary key),image_url-not-null column(blue color),user_id-fk(redcolor)
-- likes-user_id,photo_id(foreign key-red color),created_at-null column(white/empty dot)
-- comments-pk-id (primary key),comment_text-not-null column(blue dot),user_id,photo_id(foreign key-red color),created_at-null column(white/empty dot)
-- follows-follower_id(fk),followee_id(fk),created_at-null column(white/empty dot)
-- photos_tags-photo_id(foreign key)tag_id(foreign key)
-- here in "users" table we have primary key refernces to the other tables they are "follow" table-follower_id,followee_id these are composite key
-- in "likes" table-user_id , in "photos" table user_id, in "comments" table user_id
-- here in "photos" table ID is referncing to "photo_tags" table photo_id,tag_id these are composite key
-- in "comments"  table-photo_id,user_id  these are composite key
-- dotted line weak relationship pk of 1 table acts as foreign key in other table
-- strong relationship line pk of 1 table acts as primary key in other table
-- here we have - 1 to many relationships for example we see photo and comments tables we see photo to comments(1-many) & comments to photos(many to 1)
-- another example photo_tags and photo table here we see photo_tags to photo (1-many) that is a particular tag is used one time & photo to photo_tags(many to 1)
-- a photo can have many photo_tags
*/
-- 2.We want to reward the user who has been around the longest, Find the 5 oldest users.-- 
 -- USING ORDER BY CLAUSE--
SELECT * FROM  users
ORDER BY created_at ASC LIMIT 5;
-- 3.To target inactive users in an email ad campaign, find the users who have never posted a photo.
 SELECT users.id,users.username FROM users WHERE users.id  NOT IN
 (SELECT photos.user_id FROM photos 
 GROUP BY user_id)ORDER BY users.id;
 -- OR
 SELECT * FROM users WHERE id NOT IN 
(SELECT user_id FROM photos);
-- 4.Suppose you are running a contest to find out who got the most likes on a photo. Find out who won?
-- if you add users,photos,likes
SELECT username, count(likes.photo_id) as Number_of_Likes 
FROM users 
INNER JOIN photos ON users.id=photos.user_id
INNER JOIN likes ON photos.user_id=likes.user_id
GROUP BY username
ORDER BY Number_of_Likes DESC LIMIT 1;
-- 5.The investors want to know how many times does the average user post.
-- normal query
SELECT user_id, count(id) AS Number_of_Posts
FROM photos
GROUP BY user_id
ORDER BY Number_of_Posts DESC;
-- by using VIEW & group by
CREATE VIEW POSTS AS -- 
SELECT user_id,count(*) as no_of_posts FROM photos
GROUP BY user_id;

SELECT * FROM posts;

SELECT AVG(no_of_posts) FROM posts;
-- 6.A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.
-- by using views--
CREATE VIEW tag_id_name AS
SELECT tag_id,tag_name FROM photo_tags  
JOIN tags ON photo_tags.tag_id=tags.id ;

SELECT * FROM tag_id_name;

SELECT tag_name,COUNT(tag_id) AS count_of_used_hastags FROM tag_id_name 
GROUP BY tag_name
ORDER BY count_of_used_hastags DESC LIMIT 5;
-- OR
SELECT tag_name, COUNT(tag_id) AS Number_of_Times_Used
FROM tags 
JOIN photo_tags ON tags.id=photo_tags .tag_id
GROUP BY tag_name
ORDER BY Number_of_Times_Used DESC
LIMIT 5;
-- 7.To find out if there are bots, find users who have liked every single photo on the site.
-- BY USING CTE's -
WITH cte AS
(SELECT user_id,COUNT(user_id) AS TOTALLIKES from likes
 GROUP BY user_id
 HAVING TOTALLIKES =
(SELECT COUNT(distinct id) from photos))
SELECT user_id,username,TOTALLIKES FROM cte 
JOIN users ON users.id=cte.user_id ;
 -- OR
 SELECT likes.user_id, users.username
FROM likes 
JOIN users  ON likes.user_id=users.id
GROUP BY likes.user_id
HAVING COUNT(DISTINCT photo_id) = (SELECT COUNT(*) FROM photos);
-- 8.Find the users who have created instagramid in may and select top 5 newest joinees from it? 
SELECT users.id,users.username,users.created_at as "instas created in may" FROM users 
WHERE EXTRACT(MONTH FROM users.created_at)=5
ORDER BY users.created_at DESC 
LIMIT 5;
-- OR
SELECT *
FROM users
WHERE MONTHNAME(created_at)= 'May'
ORDER BY created_at DESC
LIMIT 5;
-- 9.Can you help me find the users whose name starts with c and ends with any number and have posted the photos as well as liked the photos?
-- BY USING SUBQUERIES--- 
SELECT users.username AS 'username',users.id AS 'id',photos.user_id AS 'user_id' FROM users
INNER JOIN photos ON users.id=photos.user_id
INNER JOIN likes ON photos.user_id=likes.user_id 
WHERE users.username REGEXP '^C' AND users.username REGEXP '[0-9]$'
GROUP BY username,id;
-- OR  BY USING CTE'S----5 rows
WITH photos_likes AS
(
SELECT photos.id,likes.user_id FROM photos
INNER JOIN likes ON photos.user_id=likes.user_id
) 
SELECT photos_likes.id,photos_likes.user_id,users.username FROM users 
INNER JOIN photos_likes ON users.id=photos_likes.user_id
WHERE users.username REGEXP '^C' AND users.username REGEXP '[0-9]$'
GROUP BY photos_likes.id;
-- 10.Demonstrate the top 30 usernames to the company who have posted photos in the range of 3 to 5.
SELECT user_id, username, COUNT(photos.id) AS Number_of_Photos_Posted
FROM users 
JOIN photos ON users.id=photos.user_id
GROUP BY user_id
HAVING Number_of_Photos_Posted BETWEEN 3 AND 5
ORDER BY Number_of_Photos_Posted DESC LIMIT 30;