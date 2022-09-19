select *
from [portfolio project]..coviddeaths
where continent is not null
order by 3,4

select *
from [portfolio project]..covidvaccinations
order by 3,4

--Select the data that we wil be using

select location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]..coviddeaths
order by 1,2 

-- Looking at total cases vs total deaths
--Shows likelihood of dying if you contract Covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from [portfolio project]..coviddeaths
where location like '%states%'
order by 1,2 

-- Looking at total cases vs population
--shows what percentage got covid
select location, date, total_cases, population, (total_cases/population)*100 as Percentage_with_Covid
from [portfolio project]..coviddeaths
--where location like '%states%'
order by 1,2 

--looking at countries with highest infection rate
select location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 as PercentPopulationInfected
from [portfolio project]..coviddeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--looking at countriues with the highest death count per population
select location, max(cast(total_deaths as int)) as total_deaths
from [portfolio project]..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by total_deaths desc

--Lets break things down by continent

select location, max(cast(total_deaths as int)) as total_deaths
from [portfolio project]..coviddeaths
--where location like '%states%'
where continent is null and location NOT IN ('High Income', 'Upper middle income', 'Lower middle income', 'Low income')
group by location
order by total_deaths desc

--Lets break things down by continent

--Showing continents with the highest death count
select continent, max(cast(total_deaths as int)) as total_deaths
from [portfolio project]..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by total_deaths desc

--Showing hospital admissions and percentage hospitalized by continent

select continent, max(total_cases) as total_cases, max(cast(hosp_patients as int)) as #_hospitalized,max(cast(hosp_patients as int))/max(total_cases) *100 as Percentage_hospitalized
from [portfolio project]..coviddeaths
where continent is not null
Group by continent

select location, max(total_cases) as total_cases, max(cast(hosp_patients as int)) as #_hospitalized,max(cast(hosp_patients as int))/max(total_cases) *100 as Percentage_hospitalized
from [portfolio project]..coviddeaths
where continent is not null
Group by location
order by Percentage_hospitalized desc

-- Global numbers
-- Total cases and total Deaths
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from [portfolio project]..coviddeaths
where continent is not null
--group by date
order by 1,2 

--JOINING TABLES
select * 
from [portfolio project]..coviddeaths dea
join [portfolio project]..covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date

--TOTAL POPULATION VS VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [portfolio project]..coviddeaths dea
join [portfolio project]..covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.date) as rolling_people_vaccinated
from [portfolio project]..coviddeaths dea
join [portfolio project]..covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3



--USE CTE

With PopvsVAC (Continent, location, date, population, new_vaccinations, Rolling_people_vaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.date) as rolling_people_vaccinated
from [portfolio project]..coviddeaths dea
join [portfolio project]..covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)
Select *, (Rolling_people_vaccinated/population)*100
From PopvsVAC



--Creating view to store data for later visualizations

Create view Rolling#Vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location order by dea.date) as rolling_people_vaccinated
from [portfolio project]..coviddeaths dea
join [portfolio project]..covidvaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3