-- Retrive ALL DATA of Covid Death Table
--SELECT * FROM CovidAnalysis..covid_death

-- Retrive ALL DATA of Covid Vaccination Table
--SELECT * FROM CovidAnalysis..covid_vaccine

-- Sorting Data by Location Using "Order By = Column_name"
--SELECT * FROM CovidAnalysis..covid_vaccine
--order by location

-- Retrive Data of loctaion, deths, new_cases.
--SELECT location, date, population, total_deaths, total_cases, new_cases, new_deaths  
--FROM CovidAnalysis..covid_death
--Where location = 'India'
--order by location

-- Total Cases VS total Death
--SELECT location, date, population, total_deaths, total_cases, (total_deaths/total_cases)*100 as 'Average death'
--FROM CovidAnalysis..covid_death
--Where location Like '%India'
--order by location



-- looking at total cases vs population
--SELECT location, date, population, total_deaths, total_cases, (total_cases/population)*100 as 'Average Cases'
--FROM CovidAnalysis..covid_death
--Where location Like '%India'
--order by location

---- looking at total Vaccination vs population and Join Two tables
--SELECT CovidAnalysis..covid_death.location, CovidAnalysis..covid_death.date, population, total_vaccinations, total_cases, (total_vaccinations/population)*100 as 'Average Vaccination'
--FROM CovidAnalysis..covid_death
--Join CovidAnalysis..covid_vaccine ON CovidAnalysis..covid_death.date = CovidAnalysis..covid_vaccine.date
--Where CovidAnalysis..covid_death.location Like '%India'

--Which country has most cases
--SELECT Location, Population, MAX(total_cases) as HighestCases, MAX(total_cases/population)*100 as InfectedPopulationPercentafe
--FROM CovidAnalysis..covid_death
--group by population, Location
--Order By HighestCases desc

--Highest death in countries by population
--SELECT Location, Population, MAX(CAST(total_deaths AS INT)) as Highestdeaths
--FROM CovidAnalysis..covid_death
--WHERE continent is not null
--group by population, Location
--Order By Highestdeaths desc

-- LET'S BREAK THINGS BY CONTINENT
--SELECT Location, Population, MAX(CAST(total_deaths AS INT)) as Highestdeaths
--FROM CovidAnalysis..covid_death
--WHERE continent is null and population is not null
--group by population, Location
--Order By Highestdeaths desc


---- Showing Continnets with the Highest death per population
--SELECT Distinct(Continent), MAX(CAST(total_deaths AS INT)) as TotalDeathCount
--FROM CovidAnalysis..covid_death
--WHERE continent  is not null
--group by Continent
--Order By TotalDeathCount desc

-- Global Numbers
--SELECT SUM(new_cases) AS CasesRateGlobally, SUM(CAST(new_deaths AS INT)) AS DeathRAteGlobally, 
--SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
--FROM CovidAnalysis..covid_death
--Where continent is not null


-- This is a Create View Code.
--CREATE VIEW Countries AS 
--SELECT CovidAnalysis..covid_vaccine.continent,  CovidAnalysis..covid_vaccine.location,  CovidAnalysis..covid_death.date, population, CovidAnalysis..covid_vaccine.new_vaccinations,
--SUM(cast(new_vaccinations as int))  as total_Vaccinations
--from CovidAnalysis..covid_death
--join CovidAnalysis..covid_vaccine
--on  CovidAnalysis..covid_death.date = CovidAnalysis..covid_vaccine.date 
--and CovidAnalysis..covid_death.location = CovidAnalysis..covid_vaccine.location
--where  CovidAnalysis..covid_death.continent is not null
--GROUP BY CovidAnalysis..covid_vaccine.continent, CovidAnalysis..covid_vaccine.location, CovidAnalysis..covid_death.date, CovidAnalysis..covid_vaccine.new_vaccinations, population;
--SELECT * FROM [Countries];



----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Covid_vaccine related codes Here


-- Total population who got vaccination
-- ASIA
--SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location) AS TotalVaccination
--FROM CovidAnalysis..covid_death dea
--JOIN CovidAnalysis..covid_vaccine vac On dea.date = vac.date 
--	AND dea.location = vac.location
--	where dea.continent like '%ASIA' 
--	order by location 
-- Europe
--SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location) AS TotalVaccination
--FROM CovidAnalysis..covid_death dea
--JOIN CovidAnalysis..covid_vaccine vac On dea.date = vac.date 
--	AND dea.location = vac.location
--	where dea.continent like '%Europe' 
--	order by location


-- For All Cotinent
--SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations, 
--SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopulationVaccination
--FROM CovidAnalysis..covid_death dea
--JOIN CovidAnalysis..covid_vaccine vac On dea.date = vac.date 
--	AND dea.location = vac.location
--	where dea.continent is not null 
--	order by location



--- USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, TotalPopulationVaccination)
as 
(SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopulationVaccination
FROM CovidAnalysis..covid_death dea
JOIN CovidAnalysis..covid_vaccine vac On dea.date = vac.date 
	AND dea.location = vac.location
	where dea.continent is not null 
	--order by 2, 3
	)
	Select *, (TotalPopulationVaccination/population)*100 as PeopleVaccinationByPopulationPrecentage  FROM PopvsVac;



--- Temp Table
CREATE TABLE PercentPopulationVaccinated
(Continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
TotalPopulationVaccination numeric);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.location order by dea.location, dea.date) AS TotalPopulationVaccination
FROM CovidAnalysis..covid_death dea
JOIN CovidAnalysis..covid_vaccine vac On dea.date = vac.date 
	AND dea.location = vac.location
	where dea.continent is not null 
	--order by 2, 3
	Select *, (TotalPopulationVaccination/population)*100 as PeopleVaccinationByPopulationPrecentage  FROM PercentPopulationVaccinated;




---- Creating View to store data for later visualization
--DROP View AveragePopulationVaccinated
CREATE VIEW AveragePopulationVaccinated AS 
SELECT CovidAnalysis..covid_vaccine.continent,  CovidAnalysis..covid_vaccine.location,  
CovidAnalysis..covid_death.date, population, CovidAnalysis..covid_vaccine.new_vaccinations,
SUM(cast(new_vaccinations as int))  as total_Vaccinations
from CovidAnalysis..covid_death
join CovidAnalysis..covid_vaccine
on  CovidAnalysis..covid_death.date = CovidAnalysis..covid_vaccine.date 
and CovidAnalysis..covid_death.location = CovidAnalysis..covid_vaccine.location
where  CovidAnalysis..covid_death.continent is not null
GROUP BY CovidAnalysis..covid_vaccine.continent, CovidAnalysis..covid_vaccine.location, 
CovidAnalysis..covid_death.date, CovidAnalysis..covid_vaccine.new_vaccinations, population;
SELECT * FROM [AveragePopulationVaccinated];












