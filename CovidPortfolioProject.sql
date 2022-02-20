------------------------------------------------------ COVID - PORTFOLIO PROJECT	--------------------------------------------------------------

--Death Percentage Per Country
-- Likelihood of Dying if you got COVID in your country
SELECT location,  max(total_cases) as totalcases, max(total_deaths) as totaldeaths, max(total_deaths)/max(total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL  
--WHERE location like '%states%'
GROUP BY location
HAVING max(total_deaths) is not null
ORDER BY 4 asc

-- CREATE TABLE FOR VISUALIZATION
CREATE VIEW DeathPercentagePerCountry as
	SELECT location,  max(total_cases) as total_cases, max(total_deaths) as total_deaths, max(total_deaths)/max(total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL  
--WHERE location like '%states%'
GROUP BY location
HAVING max(total_deaths) is not null
--ORDER BY 4 asc

-- VIEW THE CREATED TABLE
SELECT * 
FROM DeathPercentagePerCountry
ORDER BY 4 asc

-- Highest Percentage of Infected people per Country
SELECT location,Population, max(total_cases) as totalcases,  (Max(total_cases)/Population)*100 as infected_population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 200000000 
--and population < 4500000
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY infected_population desc

-- Highest Percentage of Deaths per Population
SELECT location,Population, max(total_deaths) as totaldeaths,  (Max(total_deaths)/Population)*100 as deaths_per_population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location, population
ORDER BY deaths_per_population desc

-- Highest Death Count per country
SELECT location,  (Max(Cast(total_deaths as int))) as deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location
ORDER BY deaths desc

-- Highest Death Count by Continent
--Inaccurate
SELECT continent,  (Max(Cast(total_deaths as int))) as deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY continent
ORDER BY deaths desc

--Seems more Accurate
SELECT location,  (Max(Cast(total_deaths as int))) as deaths
FROM PortfolioProject..CovidDeaths$
WHERE continent is NULL
--WHERE population > 4000000 
--and population < 5000000
GROUP BY location
ORDER BY deaths desc

--Total Death Percentage.
SELECT   SUM(Cast(new_cases as int)) as cases, SUM(Cast(new_deaths as int)) as deaths, 
SUM(Cast(new_deaths as int)) / SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE location like '%states%'
--GROUP BY date
ORDER BY 1,2

--Total Death Percentage per date
SELECT date,  SUM(Cast(new_cases as int)) as cases, SUM(Cast(new_deaths as int)) as deaths, 
SUM(Cast(new_deaths as int)) / SUM(new_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not NULL
--WHERE location like '%states%'
GROUP BY date
ORDER BY 1,2

------------------------------------------------Looking at Total Population Vs Vaccinations, Using CTEs
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

----------------------------------------------------------------------Looking at Total Population Vs Vaccinations, Using TEMP TABLE----------------------------------------------------------------------------
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


------------------------------ CREATE VIEW TABLES FOR FUTURE VISUALIZATIONS

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
