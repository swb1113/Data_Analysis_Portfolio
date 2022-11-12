/*
Queries used for Covid Tableau Project
Data Visualization created based on these queries found on: https://public.tableau.com/app/profile/sang.won.baek/viz/Covid_Nov_08_2022_Visualizations/Dashboard1
*/

-- 1. 
-- Will be used for Global Covid numbers visualization 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- 2. 

-- Taking out European Union, World, International, and Income data (they will be irrelevant in the visualizations)
-- Will be used for total death per continent visualization

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
and location not like '%income%'
Group by location
order by TotalDeathCount desc


-- 3.

--  Will be used for percent of population infected per country map

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.

-- Will be used for time series graph showing percent of population infected over time per country 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
