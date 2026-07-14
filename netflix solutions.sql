-- Netflix project

CREATE TABLE netflix
(
    show_id      VARCHAR(10),
    type         VARCHAR(50),
    title        VARCHAR(200),
    director     VARCHAR(250),
    casts        VARCHAR(1000),
    country      VARCHAR(150),
    date_added   VARCHAR(50),
    release_year INT,
    rating       VARCHAR(10),
    duration     VARCHAR(20),
    listed_in    VARCHAR(100),
    description  VARCHAR(300)
);

select * from netflix

--1. Count the number of Movies vs TV Shows?
	
	select types,COUNT(*)
	FROM netflix
	GROUP BY types;
	
--2. Find the most common rating for movies and TV shows?

	with cte as 
	(select types, rating, count(*),
	rank() over(partition by types order by count(*) desc) rank
	from netflix
	group by types, rating)
	select types, rating from cte
	where rank = 1;
	
--3. List all movies released in a specific year (e.g., 2020)?

	select title from netflix
	where types ='Movie' and release_year = 2020;
	
--4. Find the top 5 countries with the most content on Netflix?
	
	select trim(unnest(string_to_array(country, ','))) countries, count(show_id)from netflix
	group by countries
	order by count(*) desc
	limit 5;

--5. Identify the longest movie?

	select title, duration from netflix
	where types='Movie' and 
	duration = (select max(duration)from netflix);

--6. Find content added in the last 5 years?

	select title,date_added from netflix
	where 
	to_date(date_added, 'month DD, YYYY') >= current_date - interval '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'?

	select title, types, director from netflix
	where director ilike '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons?

	select  title, duration from netflix
	where types = 'TV Show' and
	split_part(duration,' ',1)::numeric > 5 ;

--9. Count the number of content items in each genre?
	
	select trim(unnest(string_to_array(listed_in,','))) genre, 
	count(show_id) no_of_content from netflix
	group by genre;

--10. Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release?

	select extract(year from to_date(date_added,'month DD,YYYY')) as year, count(*) as yearly_content,
	round(count(*)::numeric /(select count(*) from netflix where country = 'India')::numeric *100,0) avg_content from netflix
	where country = 'India'
	group by country, year
	order by avg_content desc
	limit 5;

--11. List all movies that are documentaries?

	select title, types, listed_in from netflix
	where types = 'Movie' and 
	listed_in ilike'%documentaries%';

--12. Find all content without a director?

	select * from netflix
	where director is null;

--13. Find in how many movies actor 'Salman Khan' appeared in last 10 years?

	select types, title, casts, release_year from netflix
	where types = 'Movie' and 
	casts ilike '%salman khan%' and
	release_year > extract(year from current_date) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

	select trim(unnest(String_to_array(casts,','))) actors ,count(*) totalcontent from netflix
	where types ilike '%movie%' and
	country ilike '%india%'
	group by actors
	order by totalcontent desc
	limit 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
	
	with cte as 
	(select *,
	case 
	when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
	else 'Good'
	end as category from netflix)
	select category, count(*) from cte
	group by category;
	

	
	
	