select *
from CovidDeaths
order by location;

--select *
--from CovidVaccinations
--order by location;

-- select data that I will use

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by location, date;

--total cases vs total deaths

select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from CovidDeaths
where location = 'United States'
order by location, date;

-- total cases vs population
-- shows percentage of the population that has been infected with covid

select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from CovidDeaths
where location = 'United States'
order by location, date;

--Countries with highest infection rate

select location, Max(total_cases) as HighestInfectionCount, population, (max(total_cases)/population)*100 as InfectionRate
from CovidDeaths
where continent is not null
group by location, population
order by InfectionRate desc

--countries with the most total deaths

select location, max(cast(total_deaths as int)) as TotalDeaths 
from CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

-- total deaths by continent

select location, max(cast(total_deaths as int)) as TotalDeaths 
from CovidDeaths
where continent is null
group by location
order by TotalDeaths desc

-- deaths globally

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

-- vaccination by population

drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
NumPeopleVaccinated numeric
)
insert into PercentPopulationVaccinated
select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
sum(convert(bigint, V.new_vaccinations)) over (partition by D.Location order by D.location, D.date) as TotalVaccinations
from CovidDeaths D
join CovidVaccinations V
	on D.date = V.date
	and D.location = V.location
--where D.continent is not null
--order by 2,3

select *, (NumPeopleVaccinated/Population)*100 as PercentVaccinated
from PercentPopulationVaccinated


-- Queries used for tableau visualization

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High Income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  (max(total_cases)/population)*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc