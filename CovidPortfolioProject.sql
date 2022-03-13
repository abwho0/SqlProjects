------------------------------------------------------ COVID - PORTFOLIO PROJECT	--------------------------------------------------------------
---COUNTRIES RANKED WITH THE HIGHEST DEATH PERCENTAGE
SELECT location,  max(total_cases) as total_cases, max(total_deaths) as total_deaths, max(total_deaths)/max(total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL  
--WHERE location like '%states%'
GROUP BY location
ORDER BY death_percentage desc

-- CREATE TABLE FOR VISUALIZATION
CREATE VIEW DeathPercentagePerCountry as
	SELECT location,  max(total_cases) as total_cases, max(total_deaths) as total_deaths, max(total_deaths)/max(total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL  
--WHERE location like '%states%'
GROUP BY location
HAVING max(total_deaths) is not null
--ORDER BY 4 asc

-- VIEW THE CREATED TABLE  WITH HIGHEST DEATH PERCENTAGE
SELECT * 
FROM DeathPercentagePerCountry
ORDER BY 4 desc

-- DEATHS PER COUNTRY POPULATION
SELECT location,Population, max(total_deaths) as total_deaths,  (Max(total_deaths)/Population)*100 as deaths_per_population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location, population
ORDER BY deaths_per_population desc

-- COUNTRY RANKED WITH HIGHEST NUMBER OF DEATHS
SELECT location,  (Max(Cast(total_deaths as int))) as deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location
ORDER BY deaths desc

-- CONTINENTS RANKED WITH HIGHEST NUMBER OF DEATHS 
SELECT location,  (Max(Cast(total_deaths as int))) as deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is NULL
and location not in ('World', 'Upper middle income','High income','Lower middle income','Low income', 'International', 'European Union')
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location
ORDER BY deaths desc

--PERCENTAGE CHANCE OF DYING IF YOU CONTRACTED COVID
SELECT   SUM(Cast(new_cases as int)) as cases, SUM(Cast(new_deaths as int)) as deaths, 
SUM(Cast(new_deaths as int)) / SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1,2

--MOVING PERCENTAGE CHANCE OF DYING IF YOU CONTRACTED COVID 
SELECT date,  SUM(Cast(new_cases as int)) as cases, SUM(Cast(new_deaths as int)) as deaths, 
SUM(Cast(new_deaths as int)) / SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE location like '%states%'
GROUP BY date
ORDER BY 1,2

-- COUNTRIES RANKED WITH THE HIGHEST INFECTED POPULATION
SELECT location,Population, max(total_cases) as totalcases,  (Max(total_cases)/Population)*100 as infected_population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 200000000 
--and population < 4500000
--WHERE location like '%kuwait%'
GROUP BY location, population
ORDER BY infected_population desc

-- CONTINENTS RANKED WITH THE HIGHEST INFECTED POPULATION
SELECT location,Population, max(total_cases) as totalcases,  (Max(total_cases)/Population)*100 as infected_population
FROM PortfolioProject..CovidDeaths$
WHERE continent is NULL
and location not in ('World', 'Upper middle income','High income','Lower middle income','Low income', 'International', 'European Union')
--WHERE population > 200000000 
--and population < 4500000
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY infected_population desc

-- COUNTRIES RANKED WITH THE HIGHEST INFECTED POPULATION [MOVING PERCENTAGE]
SELECT location,Population, date, max(total_cases) as totalcases,  (Max(total_cases)/Population)*100 as infected_population
FROM PortfolioProject..CovidDeaths$
--WHERE continent is not NULL
--WHERE population > 200000000 
--and population < 4500000
WHERE location like '%kuwait%'
GROUP BY location, population,date
ORDER BY location, date asc

-- MOVING POPULATION VACCINATED PER COUNTRY [CTE METHOD]
With PopVsVac (Continent, Location, Date, population, new_vaccinations, TotalVaccinationsPerDate)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--take a SUM of vaccinations by date on just the location, start the sum againn once we reach a new location
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccs$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location
)
SELECT *, (TotalVaccinationsPerDate/population) * 100 as PercentPopVacc
FROM PopVsVac

-- MOVING POPULATION VACCINATED PER COUNTRY [TEMP TABLE]
DROP TABLE IF EXISTS #PercentPeopleVaccinated

CREATE TABLE #PercentPeopleVaccinated
(continent nvarchar(255), Location nvarchar(255), Date datetime, population numeric, new_vaccinations numeric, TotalVaccinationsPerDate numeric)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,

--take a SUM of vaccinations by date on just the location, start the sum againn once we reach a new location
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccs$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.location

SELECT *, (TotalVaccinationsPerDate/population) * 100 as PercentPopVacc
FROM #PercentPeopleVaccinated
WHERE Location LIKE '%pakistan%'
ORDER BY Date


--CREATE VIEW TABLES FOR FUTURE VISUALIZATIONS

CREATE VIEW VaccinationsPerDate as
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--take a SUM of vaccinations by date on just the location, start the sum againn once we reach a new location
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationsPerDate
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccs$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
	FROM VaccinationsPerDate
