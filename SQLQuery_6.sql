SELECT * 
FROM dbo.CovidDeaths
ORDER BY 3,4


-- SELECT *
-- FROM dbo.CovidVaccinations
-- ORDER BY 3,4

-- select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
ORDER BY 1, 2


-- looking at total cases vs total deaths 
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1, 2


-- looking at total cases vs population 
-- shows what percentage of population got covid 
SELECT location, date, population,total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1, 2


-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- showing countries with highest death count per population 
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- break things down by continent 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--showing the continents with the highest death count per population 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- global numbers 

SELECT   SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases)* 100 AS DeathPercentage
FROM dbo.CovidDeaths
-- WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
--GROUP BY date 
ORDER BY 1, 2


-- looking at total population vs vaccinations 




-- USE CTE 
WITH PopvsVac (continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date 
WHERE dea.continent is not null
-- and vac.new_vaccinations is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location NVARCHAR(255),
date datetime,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC

)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date 
WHERE dea.continent is not null
-- and vac.new_vaccinations is not null
--ORDER BY 2, 3


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- creating view to store data for later visualizations 

Create View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
    ON dea.location = vac.location 
    and dea.date = vac.date 
WHERE dea.continent is not null
-- and vac.new_vaccinations is not null
--ORDER BY 2, 3