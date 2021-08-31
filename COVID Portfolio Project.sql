SELECT *
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..['covid vaccinations$']
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
ORDER BY 1,2

--Number of people dying who are getting infected
--Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE location = 'India'
AND continent is not null
ORDER BY 1,2

--Total cases vs total population
--Percentage of people getting infected from covid

SELECT location,date,total_cases,population,(total_cases/population)*100 AS InfectionRates
FROM PortfolioProject..['covid deaths$']
--WHERE location = 'India'
ORDER BY 1,2

--Countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionRates
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
GROUP BY location,population
ORDER BY InfectionRates desc

--Countries with highest death count per population
--As total_deaths columns is in varchar so we need to CAST it in integer

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..['covid deaths$']
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Total population vs vaccinations

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(int,vaccine.new_vaccinations)) OVER(Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid deaths$'] death
JOIN PortfolioProject..['covid vaccinations$'] vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent is not null
ORDER BY 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(int,vaccine.new_vaccinations)) OVER(Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid deaths$'] death
JOIN PortfolioProject..['covid vaccinations$'] vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(int,vaccine.new_vaccinations)) OVER(Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid deaths$'] death
JOIN PortfolioProject..['covid vaccinations$'] vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated


--view to store data for later visualizations

CREATE VIEW PercentPopVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(int,vaccine.new_vaccinations)) OVER(Partition by death.location ORDER BY death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..['covid deaths$'] death
JOIN PortfolioProject..['covid vaccinations$'] vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date
WHERE death.continent is not null
--ORDER BY 2,3
