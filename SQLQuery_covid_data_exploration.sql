/*
Covid 19 Exploratory Data Analysis 
Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Windows Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


-- Select Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs total deaths
-- Shows the liklihood of dying if you contract covid in your country 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Total cases vs population 
-- What percentage of the Canadian population have tested positive for covid over time

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- Countries with highest infection rate compared to population

SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS InfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY continent, location, population
ORDER BY InfectionRate DESC

-- Countries with highest death count 

SELECT continent, location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

-- Continents with highest death count 

-- Method 1
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Method 2 
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND location NOT LIKE '%income%'
GROUP BY continent
ORDER BY TotalDeathCount DESC
/* there seems to be an error, as it just shows the 
highest death count of each continent 
as the country with the highest death count within that continent 
*/

-- GLOBAL NUMBERS

SELECT date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'World'
ORDER BY 1

-- Method 1 more accurate method (using the actual "World" location included in the data)
SELECT MAX(total_cases) AS TotalWorldCases, Max(cast(total_deaths as int)) AS TotalWorldDeaths, 
	(Max(cast(total_deaths as int))/MAX(total_cases))*100 AS TotalWorldDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'World' 

-- Method 2: less accurate method (not using the actual "World" location included in the data, the numbers are a tiny bit off)
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast
	(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2
	

-- Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.Date) AS RollingVaccinationCount --> partition by location and order by location and date so that the summing restarts at each new location
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE

WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingVaccinationCount)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.Date) AS RollingVaccinationCount --> partition by location and order by location and date so that the summing restarts at each new location
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingVaccinationCount/population)*100 AS PercentageVaccinated
FROM PopvsVac

-- Creating TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
  dea.Date) AS RollingVaccinationCount --> partition by location and order by location and date so that the summing restarts at each new location
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (RollingVaccinationCount/population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated
ORDER BY 2,3



-- Creating view to store data (for later data visualization)

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinationCount --> partition by location and order by location and date so that the summing restarts at each new location
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

