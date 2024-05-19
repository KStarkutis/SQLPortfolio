--select *
--From CovidPortfolio..CovidDeaths
--order by 3,4

--select *
--From CovidPortfolio..CovidVacinations
--order by 3,4

-- Susirenkame reikiama DATA
select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From CovidPortfolio..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths in Lithuania
select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	CONVERT(DECIMAL(18, 2),(CONVERT(DECIMAL(18, 2),total_deaths)/CONVERT(DECIMAL(18, 2),total_cases))) as [DeathPercentage]
From CovidPortfolio..CovidDeaths
where location like 'Lithuania'
order by 1,2

--Total Cases vs Population (percantage of population that got sick)
select 
	location, 
	date, 
	population,
	total_cases, 
	CONVERT(DECIMAL(18, 2),(CONVERT(DECIMAL(18, 2),total_cases)/CONVERT(DECIMAL(18, 2),population))*100) as [SickPercentage]
From CovidPortfolio..CovidDeaths
--where location like 'Lithuania'
order by 1,2

--Countries with Highest infection rates
select 
	Location,
	CONVERT(DECIMAL(18, 0),population) as Population,
	max(CONVERT(DECIMAL(18, 0), total_cases)) as HighestInfectionCount,
	CONVERT(DECIMAL(18, 3), (max(CONVERT(DECIMAL(18, 3),total_cases)/CONVERT(DECIMAL(18, 3),population)))*100) as SickPercentage
From CovidPortfolio..CovidDeaths
--where location like 'Lithuania'
group by
	location, population
order by 
	SickPercentage desc
	
--Countries with highest Death rates
select 
	Location,
	max(CONVERT(DECIMAL(18, 0), total_deaths)) as TotalDeathCount
From CovidPortfolio..CovidDeaths
where continent is not null
group by
	location, population
order by 
	TotalDeathCount desc

--Continents with highest Death rates
select 
	continent,
	max(CONVERT(DECIMAL(18, 0), total_deaths)) as TotalDeathCount
From CovidPortfolio..CovidDeaths
where continent is not null
group by
	continent
order by 
	TotalDeathCount desc

--Global Numbers
select 
	date,
	SUM(cast(new_cases as decimal(18,0))) as total_cases,
	SUM(cast(new_deaths as decimal(18,0))) as total_deaths,
	CONVERT(DECIMAL(18, 4), (SUM(CAST(new_deaths AS DECIMAL(18, 4))) / SUM(CAST(new_cases AS DECIMAL(18, 4)))) * 100) AS DeathPercentage
From 
	CovidPortfolio..CovidDeaths
where 
	continent is not null 
    AND TRY_CAST(new_cases AS DECIMAL(18, 2)) <> 0
    AND TRY_CAST(new_deaths AS DECIMAL(18, 2)) <> 0
group by 
	date
order by 
	1,2
	

-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinations) 
as
(
-- Total population vs vaccinations
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS DECIMAL(18, 0))) over (partition by death.location order by death.location, death.date) as RollingVaccinations
From CovidPortfolio..CovidVacinations vac
join CovidPortfolio..CovidDeaths death
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3
)
Select *, (RollingVaccinations/Population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #VaccinationPercentage
Create table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingVaccinations numeric
)
insert into #VaccinationPercentage
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS DECIMAL(18, 0))) over (partition by death.location order by death.location, death.date) as RollingVaccinations
From CovidPortfolio..CovidVacinations vac
join CovidPortfolio..CovidDeaths death
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null
--order by 2,3

Select *, (RollingVaccinations/Population)*100
from #VaccinationPercentage

--Creating view to store data and visualize it
IF OBJECT_ID('VaccinationPercentageView') IS NOT NULL
    DROP VIEW VaccinationPercentageView;
GO
CREATE VIEW	LithuaniaDeathPercentageView AS
select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	CONVERT(DECIMAL(18, 2),(CONVERT(DECIMAL(18, 2),total_deaths)/CONVERT(DECIMAL(18, 2),total_cases))) as [DeathPercentage]
From CovidPortfolio..CovidDeaths
where location like 'Lithuania'

