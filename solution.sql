-- task 1

select
  name as category_name,
  count(film_id) as films_count
from
  category
  left join film_category using (category_id)
group by
  name
order by
  films_count desc 
  
-- task 2

select
  concat(first_name, ' ', last_name) as actor
from
  actor
  inner join film_actor using (actor_id)
  inner join inventory using (film_id)
  inner join rental using (inventory_id)
group by
  first_name,
  last_name
order by
  count(rental_id) desc
limit
  10 

-- task 3

select
  category_name
from
  (
    select
      category.name as category_name,
      sum(payment.amount) as payment_amount,
      rank() over (
        order by
          sum(payment.amount) desc
      ) as top
    from
      category
      inner join film_category using (category_id)
      inner join inventory using (film_id)
      inner join rental using (inventory_id)
      inner join payment using (rental_id)
    group by
      category.name
    order by
      payment_amount desc
  ) temp
where
  top = 1 
  
-- task 4

select
  title
from
  film
  left join inventory using (film_id)
where
  inventory_id is null 
  
-- task 5

select
  concat(first_name, ' ', last_name) as actor
from
  (
    select
      first_name,
      last_name,
      rank() over(
        order by
          count(actor.actor_id) desc
      ) rank_count
    from
      film_category
      inner join category using (category_id)
      inner join film_actor using (film_id)
      inner join actor using (actor_id)
    where
      name = 'Children'
    group by
      actor.actor_id
  ) temp
where
  rank_count <= 3 
  
-- task 6

select
  city,
  sum(is_active) as active_users,
  sum(is_non_active) as non_active_users
from
  (
    select
      city_id,
      city,
      case when active = 1 then 1 else 0 end as is_active,
      case when active = 0 then 1 else 0 end as is_non_active
    from
      city
      left join address using (city_id)
      left join customer using (address_id)
  ) temp
group by
  city_id,
  city
order by
  non_active_users desc 
  
-- task 7

select
  category_name
from
  (
    select
      name as category_name,
      sum(return_date - rental_date) as time_diff,
      dense_rank() over(
        order by
          sum(return_date - rental_date) desc
      ) as rank_sum
    from
      city
      inner join address using (city_id)
      inner join customer using (address_id)
      inner join rental using (customer_id)
      inner join inventory using (inventory_id)
      inner join film using (film_id)
      inner join film_category using (film_id)
      inner join category using (category_id)
    where
      city_id in (
        select
          city_id
        from
          city
        where
          lower(film.title) like 'a%'
          and lower(city) like '%-%'
      )
    group by
      category.name
  ) grouped_category_by_hours
where
  rank_sum <= 1
