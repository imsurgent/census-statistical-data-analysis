select *from project.dbo.data1
select *from project.dbo.data2


--number of rows into our data set
select count(*) from project..Data1
select count(*) from project..Data2

-- data set for madhya pradesh and maharastra

select * from project..Data1 where state in ('madhya pradesh','maharashtra')

-- population of the country
 select sum(population) Population from project..Data2
  
  -- average growth of India
   select avg(growth)*100 AverageGrowth from  project..Data1

-- average growth per state

select state,avg(growth)*100 avg_growth from project..data1 group by state;

-- average sex ratio by state

select state,round(avg(Sex_Ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio desc;

-- average literacy rate
select state,round(avg(Literacy),0) avg_literacy_rate from project..data1 group by state
having round(avg(Literacy),0)>90 order by avg_literacy_rate desc;

-- top 5 state showimg highest growth rate
select top 5 state,avg(growth)*100 avg_growth from project..data1 group by state order by avg_growth desc;

-- bottom 3 states having lowest sex ratio
select top 3 state,round(avg(Sex_Ratio),0) avg_sex_ratio from project..data1 group by state order by avg_sex_ratio;

-- top 5 states with highest area
select top 5 state,round(avg(Area_km2)*100,0)  state_area from project..Data2 group by state order by state_area asc;

-- top and bottom 3 states with  highest literacy rate
drop table if exists #topstates;
create table #topstates
( state nvarchar(255),
  topstates float

)

insert into #topstates
select state,round(avg(Literacy),0) avg_literacy_rate from project..data1 group by state order by avg_literacy_rate desc;

select  top 3 * from #topstates order by #topstates.topstates desc;

drop table if exists #bottomstates;
create table #bottomstates
( state nvarchar(255),
  bottomstates float

)

insert into #bottomstates
select state,round(avg(Literacy),0) avg_literacy_rate from project..data1 group by state order by avg_literacy_rate asc;

select  top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

-- union operator

select * from (
select top 3 * from #topstates order by #topstates.topstates desc) a

union

select  * from (
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b order by topstates desc;

-- state name starting with a or t
select distinct state from project..data1 where lower(state) like 'a%' or lower(state) like 't%'

-- joining the table and calculating total number of females and males in a state and a district

 select d.state, sum(d.males) total_males, sum(d.females) total_females from
 (select c.district, c.state, round(c.population/(c.sex_ratio+1),0) males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from project..Data1 a inner join project..Data2 b on a.District = b.District) c) d
group by d.State

-- total number literate and illietrate people
select c.state,sum(literate_people) total_literate,sum(illietrate_people) total_illietrate from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) literate_people, round((1-d.literacy_ratio)*d.population,0) illietrate_people from
(select a.district, a.state, a.literacy/1000 literacy_ratio, b.population from project..Data1 a inner join project..Data2 b on a.District = b.District)d)c
group by c.State

--population in previous data vs current data 

select sum(e.total_Previous_census) previous_census_population , sum(e.total_current_census) current_census_population from
(select d.state, sum(Previous_census) total_Previous_census, sum(current_census) total_current_census from
(select c.district, c.state, round(c.population/(1-c.Growth_rate),0) current_census, c.Population previous_census from
(select a.district, a.state, a.growth/1000 Growth_rate, b.population from project..Data1 a inner join project..Data2 b on a.District = b.District) c)d
group by d.State) e

  
-- population per area
 
 select (k.total_area/k.previous_census_population) as pervious_census_population_area, (k.total_area/k.current_census_population) as current_census_populayion_area 
 from
 (select h.*,i.total_area from
(select '1' as keyy, f.* from
 (select sum(e.total_Previous_census) previous_census_population , sum(e.total_current_census) current_census_population from
(select d.state, sum(Previous_census) total_Previous_census, sum(current_census) total_current_census from
(select c.district, c.state, round(c.population/(1-c.Growth_rate),0) current_census, c.Population previous_census from
(select a.district, a.state, a.growth/1000 Growth_rate, b.population from project..Data1 a inner join project..Data2 b on a.District = b.District) c)d
group by d.State) e)f)h inner join

(select '1' as keyy, g.* from(select sum(Area_km2) total_area from project..Data2) g)i on h.keyy=i.keyy)k

 -- top 3 district in literacy rate in each state 



 select a.* from (
 select district, state, literacy, rank() over(partition by state order by literacy desc) rankk from project..data1)a where a.rankk in(1,2,3) order by state