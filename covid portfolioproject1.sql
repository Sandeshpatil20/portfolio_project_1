
SELECT*
FROM portfolio_project..deathscovid$
ORDER BY 3,4;

SELECT*
FROM portfolio_project..vaccinationcovid$
ORDER BY 3,4; 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio_project..deathscovid$
ORDER by 1,2

--looking at total_cases vs total deaths
--percentage of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from portfolio_project..deathscovid$
WHERE location like '%states%'
order by 1,2

--Looking at Total cases ve population
--Shows percentage of population who got covid

Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS Diagnosepercentage
from portfolio_project..deathscovid$
WHERE location like '%states%'
order by 1,2

--looking at countries with highest infection rate

Select location,population, MAX(total_cases) as Highestinfectioncount,
(CONVERT(float,MAX( total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS Diagnosepercentage
from portfolio_project..deathscovid$
--WHERE location like '%states%'
GROUP by location,population
order by Diagnosepercentage DESC

--showing countries with highest death count per population

Select location,MAX(cast (total_deaths as int)) AS Totaldeathcounts
from portfolio_project..deathscovid$
--WHERE location like '%states%'
WHERE continent is NOT NULL
GROUP by location
order by Totaldeathcounts DESC

--Showing continents with highest death count per population

 select continent,  sum(new_deaths)
from portfolio_project..deathscovid$
where continent!=''
group by continent;

 --Global Numbers
 SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint))as total_deaths,
 SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as deathpercentage
 FROM portfolio_project..deathscovid$
 WHERE continent IS NOT NULL
 order by 1,2


 --Looking at Total Population vs vaccination
 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition  by dea.location order by dea.location,dea.date) 
 FROM portfolio_project..deathscovid$ dea
 JOIN portfolio_project..vaccinationcovid$ vac
   on dea.location=vac.location
   and dea.date=vac.date
 WHERE dea.continent is NOT NULL
 order by 2,3
 

 --USE CTE
  
 with PopvsVac(continent, location, date, population,new_vaccinations, Rollingpeoplevaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition  by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
 FROM portfolio_project..deathscovid$ dea
 JOIN portfolio_project..vaccinationcovid$ vac
   on dea.location=vac.location
   and dea.date=vac.date
 WHERE dea.continent is NOT NULL
 --order by 2,3
 )
 SELECT *, (Rollingpeoplevaccinated/population)*100 
 FROM PopvsVac

 --TEMP TABLE

 DROP TABLE if exists #Percentpopulationvaccinated
 CREATE TABLE #Percentpopulationvaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 Rollingpeoplevaccinated numeric
 )

 INSERT INTO #Percentpopulationvaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition  by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
 FROM portfolio_project..deathscovid$ dea
 JOIN portfolio_project..vaccinationcovid$ vac
   on dea.location=vac.location
   and dea.date=vac.date
 WHERE dea.continent is NOT NULL
 --order by 2,3

  SELECT *, (Rollingpeoplevaccinated/population)*100 
 FROM #Percentpopulationvaccinated

 --Creating view to store data for later visualization

 CREATE VIEW Percentpopulationvaccinated as
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition  by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
 FROM portfolio_project..deathscovid$ dea
 JOIN portfolio_project..vaccinationcovid$ vac
   on dea.location=vac.location
   and dea.date=vac.date
 WHERE dea.continent is NOT NULL
 --order by 2,3

 SELECT * FROM Percentpopulationvaccinated