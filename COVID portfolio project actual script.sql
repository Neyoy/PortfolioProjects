SELECT *
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

-- Select only needed data for the project

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

-- Looking at total cases vs. total death (death percentage)
-- Shows likelihood of dying if you contract covid in your country

SELECT location,date,total_cases,total_deaths,CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS Death_percentage
FROM CovidDeaths
WHERE LOCATION LIKE '%state%' AND continent is NOT NULL
ORDER BY 1,2

-- Looking at total cases vs. population
-- Shows percentage of population got covid

SELECT location,date,population,total_cases,CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
--WHERE LOCATION LIKE '%state%'
ORDER BY 1,2

-- Looking at countries with hightest infection rate compared to population 

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC


-- Showing countries with highest death count per population

SELECT location,MAX(total_deaths) AS TotaldeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotaldeathCount DESC

--LET'S BREAK IT DOWM BY CONTINENT

-- Showing  continents with the highest death count per population

SELECT continent,MAX(total_deaths) AS TotaldeathCount
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotaldeathCount DESC


-- GLOBAL NUMBERS
SELECT SUM(new_cases) as totalCases,SUM(CAST(new_deaths AS float)) as totaldeaths,
SUM(CAST(new_deaths AS float))/SUM((new_cases))*100 AS Death_percentag

FROM CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at total population vs. vaccinations
With popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT death.continent,death.location,death.date,death.population,vaccin.new_vaccinations,
SUM(vaccin.new_vaccinations)OVER (PARTITION BY death.location  ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
FROM CovidVaccinations  vaccin
  JOIN CovidDeaths death
   ON death.location = vaccin.location 
   AND death.date = vaccin.date
WHERE death.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeopleVaccinated/population)*100
FROM popvsvac

--TEM TABLE
DROP Table #PercentagePeopleVaccinated
CREATE TABLE #PercentagePeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

INSERT INTO #PercentagePeopleVaccinated 

SELECT death.continent,death.location,death.date,death.population,vaccin.new_vaccinations,
SUM(vaccin.new_vaccinations)OVER (PARTITION BY death.location  ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
FROM CovidVaccinations  vaccin
  JOIN CovidDeaths death
   ON death.location = vaccin.location 
   AND death.date = vaccin.date
--WHERE death.continent is not null
--ORDER BY 2,3


SELECT *,(RollingPeopleVaccinated/population)*100 as PeopleVaccinatedPercentage
FROM   #PercentagePeopleVaccinated


--Creating view to store data for later

CREATE VIEW PercentagePeopleVaccinated AS
SELECT death.continent,death.location,death.date,death.population,vaccin.new_vaccinations,
SUM(vaccin.new_vaccinations)OVER (PARTITION BY death.location  ORDER BY death.location,
death.date) AS RollingPeopleVaccinated
FROM CovidVaccinations  vaccin
  JOIN CovidDeaths death
   ON death.location = vaccin.location 
   AND death.date = vaccin.date
WHERE death.continent is not null
--ORDER BY 2,3

