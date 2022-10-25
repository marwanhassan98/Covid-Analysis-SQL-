SELECT * from CovidDeaths
Where continent is not null 
ORDER by 3,4
/*ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float
*/
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE CovidDeaths
ALTER COLUMN new_cases float

/*ALTER TABLE CovidDeaths
ADD column_name float;
-- Select Data that we are going to be using 

/*Select Location, date, total_cases, new_cases, total_deaths, population 
From CovidDeaths
order by 1,2 */

-- Looking at the total cases vs total deaths 
-- Shows the likelihood of dying if you contacrt covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deaths_per_cases
From PortofolioProject..CovidDeaths
Where location like 'Canada'
group by continent

order by 1,2

-- Looking at the total cases vs the population 
--Shows perceentage of population that got Covid 
Select Location, date, total_cases, population, (total_cases/population)*100 as Cases_per_population
From PortofolioProject..CovidDeaths
Where location like 'Canada'
group by continent
order by 1,2


--The countries with the highest infection rate 

Select Location, population, MAX(total_cases) as HighestInfectedCount , MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortofolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

--The countries with the highest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
From PortofolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Lets take a look at the continent 
-- Showing the continents with highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount  
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global NUMBERS 
-- We need aggregate functions cause we're looking at different things, when we just grouped by the date 
Select  SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths
-- Where location like 'Canada'
where continent is not null 
--group by date
order by 1,2

-- Looking at Total population vs Vaccinations


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, CONVERT(real, dea.population), vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as A
From PopvsVac

-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, CONVERT(real, dea.population), vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as A
From #PercentPopulationVaccinated

-- Creating views to store data for Tableau 

DROP VIEW PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated