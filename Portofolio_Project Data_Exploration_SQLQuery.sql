SELECT *
FROM Portofolio_Project..['Covid Deaths$']
WHERE continent is not null
order by 3,4

--SELECT *
--FROM Portofolio_Project..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that I am going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portofolio_Project..['Covid Deaths$']
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in Greece

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPrecentage
FROM Portofolio_Project..['Covid Deaths$']
WHERE location like '%Greece%'
AND continent is not null
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of populationgot Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfeced
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfeced
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfeced Desc

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount Desc


SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc

--We can use the same query on the next step with "population" instead of "continent" so the numbers are more correct!

--SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
--FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
--WHERE continent is null
--GROUP BY location
--ORDER BY TotalDeathCount Desc


--Showing continents witht the Highest Death Cout Per Population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc

--GLOBAL NUBMERS

SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPrecentage
FROM Portofolio_Project..['Covid Deaths$']
--WHERE location like '%Greece%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
FROM Portofolio_Project..['Covid Deaths$'] dea
Join Portofolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
FROM Portofolio_Project..['Covid Deaths$'] dea
Join Portofolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPeoplePercentage
FROM PopvsVac



--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
FROM Portofolio_Project..['Covid Deaths$'] dea
Join Portofolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)
FROM Portofolio_Project..['Covid Deaths$'] dea
Join Portofolio_Project..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


