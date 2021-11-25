SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL -- This was added after exploring the data. We will be adding this to the next queries too
ORDER BY 3,4


--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1, 2

-- Looking at total cases vs total deaths
-- Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths 
WHERE location = 'India'
AND continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total cases vs population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths 
WHERE continent IS NOT NULL
--WHERE location = 'India'
ORDER BY 1, 2

--Looking at countries with the highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionRate, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing the coutries with the highest death count per population.

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS NOT NULL -- This was added because the data contained continent names in location. So, we are removing them.
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENTS

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS  NULL -- The raw data is bit confusing. If the continent is null, then the location has the actual continent data.
--Hence we are selecting location instead of continent
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENTS
--showing the continents with the highest death count per population
-- The above is the right query, but for vizualization (drilling down) purpose for this project we are going to use a different query
--Eventhough it is wrong

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS  NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS NOT NULL
GROUP BY date -- we are checking what the sum of above were on each date at the global level
ORDER BY 1, 2

--The percentage of death across the world till date(7/20/2021)

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM CovidDeaths 
--WHERE location = 'India'
WHERE continent IS NOT NULL
--GROUP BY date -- we are checking what the sum of above were on each date at the global level
ORDER BY 1, 2

--Checking out the vaciination table

SELECT *
FROM CovidVaccination
ORDER BY 3,4

--Joining the 2 tables

SELECT * 
FROM CovidDeaths AS dea
JOIN CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 

-- Looking at the total no of people vaccinated in the world
-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--instead of cast, we can use convert as well
--SUM(CONVERT(int, vac.new_vaccinations)
FROM CovidDeaths AS dea
JOIN CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--AND dea.location = 'India'
ORDER BY 2,3

-- When we want to use a new column name we have created in further calculation, the system throws an error. So we use CTM
--CTM; This is present in his advanced classes.

--No of columns within WITH should be equal to distinct no of columns in the SELECT statement
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--instead of cast, we can use convert as well
--SUM(CONVERT(int, vac.new_vaccinations)
FROM CovidDeaths AS dea
JOIN CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
AND dea.location = 'Canada'
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated -- if this was used without CTM, then we would get an error
FROM PopvsVac

--Creating temp tables

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- CREATING VIEWS
--creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS numeric)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths AS dea
JOIN CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

--Now we can use the view to query a table

SELECT * 
FROM PercentPopulationVaccinated

Based on the project
