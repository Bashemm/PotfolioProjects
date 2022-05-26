-- Take a look at the first 10 rows of the dataset
SELECT  TOP 10*
FROM Portfolio_trial..CovidDeaths$
WHERE continent is not null

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_trial..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--COUNT OF TOTAL CASES, TOTAL DEATHS AND DEATH PERCENTAGE
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as TotalDeath_Perc
FROM Portfolio_trial..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Continent with highest infection rate
SELECT  location, population, MAX(total_cases) AS highest_infection, MAX((total_cases / population)) * 100 AS Perc_of_population_infected
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NULL AND location NOT IN('World', 'upper middle income', 'high income', 'lower middle income', 'european union', 'low income', 'international')
GROUP BY population, location
ORDER BY Perc_of_population_infected DESC

--The continents Death count
SELECT  location, MAX(cast(total_deaths AS INT)) AS Total_Death, (MAX(cast(total_deaths AS INT)) /  MAX(population)) * 100 as Percentage_of_death
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NULL
AND location NOT IN('World', 'upper middle income', 'high income', 'lower middle income', 'european union', 'low income', 'international')
GROUP BY location
ORDER BY Total_Death DESC

-- COUNTRIES INFECTION RATE
SELECT  location, population, MAX(total_cases) AS highest_infection, MAX((total_cases / population)) * 100 AS percentage_of_population_infected
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY percentage_of_population_infected DESC

-- Which country have highest death count
SELECT  location, MAX(cast(total_deaths AS INT)) AS TotalDeath, (MAX(cast(total_deaths AS INT)) / MAX(population)) * 100 as percentage_of_population_death
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY percentage_of_population_death DESC

-- NIGERIA'S POPULATION
SELECT  MAX(population) as Total_population
FROM Portfolio_trial..CovidDeaths$
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL

-- POPULATION VS TOTAL CASES PER DAY IN NIGERIA
SELECT location, date, total_cases, population, (total_cases/ population) * 100 AS population_percentage
FROM Portfolio_trial..CovidDeaths$
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY population_percentage DESC

-- POPULATION vs TOTAL DEATHS PER DAY IN NIGERIA
SELECT  location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage_per_day
FROM Portfolio_trial..CovidDeaths$
WHERE location LIKE '%Nigeria%' AND continent IS NOT NULL
ORDER BY death_percentage_per_day DESC

-- 
select *
from Portfolio_trial..CovidDeaths$ dea
join Portfolio_trial..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date

SELECT dea.date, dea.location, vac.new_vaccinations, SUM(CONVERT(BIGINT, Vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
FROM Portfolio_trial..CovidDeaths$ dea
	JOIN Portfolio_trial..CovidVaccination$ vac
On dea.date = vac.date AND
	dea.location = vac.location 
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
order by 1,2


CREATE VIEW GlobalNumbers AS 
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, 
ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases)) *100,2) AS DeathPercentage
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date


CREATE VIEW CountryNumbers AS
SELECT  location, MAX(cast(total_deaths AS INT)) AS TotalDeath, (MAX(cast(total_deaths AS INT)) / MAX(population)) * 100 as percentage_of_population_death
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location


CREATE VIEW ContinentNumbers AS
SELECT continent, MAX(total_cases) AS HighestCaseCount, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM Portfolio_trial..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY continent

CREATE VIEW RollingPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS RollingPeopleVaccinated
FROM Portfolio_trial..CovidDeaths$ dea JOIN
	Portfolio_trial..CovidVaccination$ vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date


-- Global Numbers Table
SELECT *
FROM GlobalNumbers

-- Continent Numbers Table
SELECT *
FROM ContinentNumbers

-- Counries with highest death
SELECT top 10*
FROM CountryNumbers
Order by TotalDeath desc

-- Nigeria Numbers Table
SELECT *
FROM RollingPeopleVaccinated
WHERE location LIKE '%NIGERIA%'




