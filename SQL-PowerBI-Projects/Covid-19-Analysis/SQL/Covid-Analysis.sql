
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
order by 1,2


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Analysis..CovidDeaths
WHERE location like '%Egypt%' and continent is not null
order by 1,2


SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infected_Percentage
FROM Covid_Analysis..CovidDeaths
WHERE location = 'Egypt' and continent is not null
order by 1,2


SELECT location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
GROUP BY location, population
order by Percent_Population_Infected desc


Select TOP 10 location, MAX(cast(total_deaths as int)) AS Highest_Deaths_Country
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Deaths_Country desc


Select continent, MAX(cast(total_deaths as int)) AS Highest_Deaths_Country
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY Highest_Deaths_Country desc


Select location, MAX(cast (total_deaths as int)) AS Highest_Deaths, population, Max((total_deaths/population)) *100 AS Death_Percentage
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY Death_Percentage desc


Select continent, MAX(cast(total_deaths as int)) AS Highest_Deaths_Country
FROM Covid_Analysis..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Highest_Deaths_Country desc


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_Analysis..CovidDeaths dea
Join Covid_Analysis..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From Covid_Analysis..CovidDeaths dea
Join Covid_Analysis..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_Analysis..CovidDeaths dea
Join Covid_Analysis..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated