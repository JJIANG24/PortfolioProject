
-- Total Number of COVID-19 Cases and Death Percentage.
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 AS DeathPercentage
FROM [Portfolio Project].dbo.Covid_Deaths
WHERE LOCATION like '%United States%'
ORDER BY 1,2
--------------------------------------------------------------------------------------------------------------------------------------------
-- Highest COVID-19 Infection Percentages.
Select Location, Population, MAX(cast(total_cases as int)) AS HighestInfectionCount, MAX(total_cases/population)*100 AS InfectionPercentage
FROM [Portfolio Project].dbo.Covid_Deaths
GROUP BY Location, Population
ORDER BY InfectionPercentage DESC
--------------------------------------------------------------------------------------------------------------------------------------------
-- Highest COVID-19 Death Counts.
Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
--------------------------------------------------------------------------------------------------------------------------------------------
-- Data Filtered by Continents.
Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
--------------------------------------------------------------------------------------------------------------------------------------------
-- Data Filted by Total Cases and Deaths
Select sum(new_cases) as Total_Cases, sum(new_deaths) as Total_Deaths, sum(new_deaths)/sum(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.Covid_Deaths
where new_cases <> 0 AND continent IS NOT NULL
order by 1,2
--------------------------------------------------------------------------------------------------------------------------------------------
-- Total Population vs. Vaccination [Adding up Consecutive rows for each Country] - CTE FUNCTION
WITH CTE_FUNCTION (Continent, Location, Date, Population, new_vaccinations, Sum_Vaccinated) AS 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinated
from [Portfolio Project].dbo.Covid_Deaths as dea
JOIN [Portfolio Project].dbo.Covid_Vaccines as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (Sum_Vaccinated/Population)*100
FROM CTE_FUNCTION
--------------------------------------------------------------------------------------------------------------------------------------------
-- Total Population vs. Vaccination [Adding up Consecutive rows for each Country] - TEMP TABLE
DROP TABLE IF EXISTS #TEMP_TABLE
CREATE TABLE #TEMP_TABLE
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Sum_vaccinated numeric)

INSERT INTO #TEMP_TABLE
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinated
from [Portfolio Project].dbo.Covid_Deaths as dea
JOIN [Portfolio Project].dbo.Covid_Vaccines as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (Sum_Vaccinated/Population)*100
FROM #TEMP_TABLE
--------------------------------------------------------------------------------------------------------------------------------------------
-- Views for Visualizations
CREATE VIEW Population_Vaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Sum_Vaccinated
from [Portfolio Project].dbo.Covid_Deaths as dea
JOIN [Portfolio Project].dbo.Covid_Vaccines as vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL