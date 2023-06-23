/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views
*/

-- Selected Data that we are starting with
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-project-01-388516.Covid19.covid_deaths`
WHERE continent is not null 
ORDER BY 1,2

-- Total Cases vs Total Deaths
--Shows the daily percentage of deaths from those who contracted covid in your country
SELECT  location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `portfolio-project-01-388516.Covid19.covid_deaths` 
WHERE location like "United States"
ORDER BY 1,2 

--Total Cases vs Population
--shows what percentage of the population had recorded cases
SELECT location, date, total_cases, population,(total_cases/population)*100 as TotalCasesinPop
FROM `portfolio-project-01-388516.Covid19.covid_deaths`
Where location like "United States"
ORDER BY 2


--Looking at countries with Highsets infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `portfolio-project-01-388516.Covid19.covid_deaths`
Group by location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death count per population
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM `portfolio-project-01-388516.Covid19.covid_deaths`
WHERE continent is not null
Group by location
Order by HighestDeathCount desc

-- Breaking things down by continent
-- Showing contintents with the highest death count per population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `portfolio-project-01-388516.Covid19.covid_deaths`
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS of Deaths
--by date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `portfolio-project-01-388516.Covid19.covid_deaths` 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 

--Total Cases, Total Deaths and the Percentage of deaths in realtion to the global population
SELECT SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM `portfolio-project-01-388516.Covid19.covid_deaths` 
WHERE continent is not null
ORDER BY 1,2

--Joining the two tables (Deaths and Vaccinations)
SELECT *
From `portfolio-project-01-388516.Covid19.covid_deaths` dea
JOIN `portfolio-project-01-388516.Covid19.covid_vaccinations` vac
ON dea.location = vac.location
  and dea.date = vac.date


--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From `portfolio-project-01-388516.Covid19.covid_deaths` dea
JOIN `portfolio-project-01-388516.Covid19.covid_vaccinations` vac
ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3  

--Count of vaccinations with counter column totaling values daily
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
From `portfolio-project-01-388516.Covid19.covid_deaths` dea
JOIN `portfolio-project-01-388516.Covid19.covid_vaccinations` vac
ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
From `portfolio-project-01-388516.Covid19.covid_deaths` dea
JOIN `portfolio-project-01-388516.Covid19.covid_vaccinations` vac
ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null)

SELECT *, (RollingVaxCount/population)*100 as PercentVaccinated
from PopvsVac

--Percentage of Population vaccinated by country
WITH PopvsVac AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations)OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
From `portfolio-project-01-388516.Covid19.covid_deaths` dea
JOIN `portfolio-project-01-388516.Covid19.covid_vaccinations` vac
ON dea.location = vac.location
  and dea.date = vac.date
WHERE dea.continent is not null)

SELECT location,
MAX(RollingVaxCount/population)*100 AS VaxedPop
from PopvsVac
GROUP BY location


--create view
CREATE OR REPLACE VIEW  TotalDeathCountbyContinent AS
Select continent, MAX(total_deaths) as TotalDeathCount
From `portfolio-project-01-388516.Covid19.covid_deaths`
Where continent is not null
Group by continent
order by TotalDeathCount desc
