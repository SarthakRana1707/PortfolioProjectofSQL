CREATE DATABASE PortfolioProject;

USE PortfolioProject;

SELECT *
FROM PortfolioProject.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM PortfolioProject.covidvaccinations
-- ORDER BY 3,4;

-- Select the data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.coviddeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.coviddeaths 
WHERE location = 'India' and continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.coviddeaths 
-- WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compated to population

Select Location, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.coviddeaths 
-- WHERE location = 'India'
group by location, population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with Highest Death count per Population

Select Location, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathCount
from PortfolioProject.coviddeaths 
WHERE continent IS NOT NULL
-- WHERE location = 'India'
group by location
ORDER BY TotalDeathCount desc;

-- Let's Break things down by Continent

-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as UNSIGNED)) as TotalDeathCount
from PortfolioProject.coviddeaths 
WHERE continent IS NOT NULL
-- WHERE location = 'India'
group by continent
ORDER BY TotalDeathCount desc;

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths, SUM(cast(new_deaths as SIGNED))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.CovidDeaths
-- Where location = 'India'
where continent is not null 
-- Group By date
order by 1,2;

-- Joins coviddeaths with covidvaccinations
SELECT *
From PortfolioProject.coviddeaths AS dea
Join PortfolioProject.covidvaccinations AS vac
On dea.location = vac.location
and dea.date = vac.date;

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths AS dea
JOIN PortfolioProject.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as( SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths AS dea
JOIN PortfolioProject.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated(
    Continent VARCHAR(255),
    Location VARCHAR(255),
    Date DATE,
    Population BIGINT,
    New_vaccinations BIGINT,
    RollingPeopleVaccinated BIGINT
);

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths AS dea
JOIN PortfolioProject.covidvaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

