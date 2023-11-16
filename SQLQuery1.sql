-- Observing Contents of data
select location, date, total_cases, new_cases, total_deaths, population 
from `coviddashboard-405122.mydataset.CovidDeaths`
order by 1,2

Select continent
from `coviddashboard-405122.mydataset.CovidDeaths`
group by Continent

Select continent, location
from `coviddashboard-405122.mydataset.CovidDeaths`
where continent is Null
group by Continent, location

Select * 
from `coviddashboard-405122.mydataset.CovidDeaths`
where Location in ('United States')
and date in ('2023-11-01')

Select * 
from `mydataset.CovidVaccines`
where Location in ('United States')
and date in ('2023-11-01')

--Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from `coviddashboard-405122.mydataset.CovidDeaths`
where continent is not null
or location in ('World')
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from `coviddashboard-405122.mydataset.CovidDeaths`
where location in ('World')
and date in ('2023-11-01')
order by 1,2


--Total Cases vs Total Population
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from `coviddashboard-405122.mydataset.CovidDeaths`
where location like '%State%'
--where continent is not null
--or location in ('World')
order by 1,2

--Comparing peak Infection Rate by Country
select location, population, max(total_cases) as PeakInfectionCount, max((total_cases/population))*100 as PeakInfectionRate
from `coviddashboard-405122.mydataset.CovidDeaths`
--where location like '%State%'
where continent is not null
or location in ('World')
group by location, population
order by PeakInfectionRate desc

--observing peak death count by Country
select location, max(total_deaths) as PeakDeathCount
from `coviddashboard-405122.mydataset.CovidDeaths`
--where location like '%State%'
where continent is not null
or location in ('World')
group by location
order by PeakDeathCount desc

--Comparing Peak Death by Continent
select location, max(total_deaths) as PeakDeathCount
from `coviddashboard-405122.mydataset.CovidDeaths`
--where location like '%State%'
where continent is null
and location not like '%income%'
group by location
order by PeakDeathCount desc

--Global Numbers
select 
--date,
sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathRate
from `mydataset.CovidDeaths`
where continent is not null
--group by date
--order by date

--Death by Continent
select 
location, sum(new_deaths) as TotalDeaths--, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathRate
from `mydataset.CovidDeaths`
where continent is null
and location not like '%income%'
and location not in ('World')
group by Location
order by TotalDeaths desc

--Death by Country
select 
continent, location, sum(new_deaths) as TotalDeaths--, sum(new_deaths)/nullif(sum(new_cases),0)*100 as DeathRate
from `mydataset.CovidDeaths`
where continent is not null
group by continent, Location
order by TotalDeaths desc

--observing total vaccinations by date
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as VaccinesAdministered
from `mydataset.CovidDeaths` dea
join `mydataset.CovidVaccines` vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
where dea.location in ('World', 'Africa', 'Asia', 'European Union', 'Europe', 'North America', 'Oceania', 'South America', 'United States')
order by 2,3

--Death by Date
select dea.continent, dea.location, dea.date, dea.population, 
dea.new_deaths, sum(dea.new_deaths) over(partition by dea.location order by dea.location, dea.date) as TotalDeaths
from `mydataset.CovidDeaths` dea
join `mydataset.CovidVaccines` vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
where dea.location in ('World')
or
dea.continent is null
and dea.location not like '%income%'
or
dea.location in ('United States')
order by 2,3

--Global vs US (Death & Vaccine)
select dea.continent, dea.location, dea.date, dea.population, 
dea.new_deaths, sum(dea.new_deaths) over(partition by dea.location order by dea.location, dea.date) as TotalDeaths,
ifnull(vac.new_vaccinations, 0), ifnull(sum(new_vaccinations) over(partition by dea.location order by dea.location, dea.date), 0) as VaccinesAdministered
from `mydataset.CovidDeaths` dea
join `mydataset.CovidVaccines` vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.location in ('World', 'United States')
order by 2,3

--using cte
With VaccineStats (Continent, Location, Date, Population, New_Vaccines, Total_Administered)
as
(
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as VaccinesAdministered
from `mydataset.CovidDeaths` dea
join `mydataset.CovidVaccines` vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
where dea.location in ('World', 'Africa', 'Asia', 'European Union', 'Europe', 'North America', 'Oceania', 'South America', 'United States')
)
Select *, (VaccinesAdministered/population)*100
From VaccineStats

