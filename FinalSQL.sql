----SELECT *
----FROM CovidDeaths$
--Where continent is not null
----Order by 3,4

--SELECT *
--FROM covidvaccinations$
--Order by 3,4

-- Select the data we are going to be using 

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths$
Order by 1,2



--Looking at Total Cases vs. Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
WHERE location like '%states%'
Order by 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of the population got Covid
SELECT location,date,Population,total_cases,(total_cases/Population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population 

SELECT location,Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/Population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
GROUP BY Population, Location 
ORDER BY PercentPopulationInfected desc



-- Showing the Countries with the Highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is not null
GROUP BY Location 
ORDER BY TotalDeathCount desc


--Breaking Things Down by Continent

--Showing Continents with the Highest Death Counts
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Use for Visual Purposes 
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths$
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Global Numbers Group By dates
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)
AS DeathPercentage
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
Order by 1,2


--Global Total Cases, Totals Deaths and Death Percentages
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)
AS DeathPercentage
FROM CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
Order by 1,2


-- Looking at Total Population vs. Vaccinations
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
--AS RollingPeopleVaccinated / Population *100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location= vac.location
 AND dea.date = vac.date
where dea.continent is not null
Order by 2,3

-- Same Code ( Using Convert instead of Cast)
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
--AS RollingPeopleVaccinated / Population *100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location= vac.location
 AND dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use a CTE 
With PopvsVac ( Continent,Location,Date,Population,RollingPeopleVaccinated, New_Vaccinations)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
--AS RollingPeopleVaccinated / Population*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location= vac.location
 AND dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
SELECT* , RollingPeopleVaccinated/Population*100
FROM popvsvac



--TEMP TABLE 


CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
--AS RollingPeopleVaccinated / Population*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
 ON dea.location= vac.location
 AND dea.date = vac.date
where dea.continent is not null
--Order by 2,3

SELECT* , RollingPeopleVaccinated/Population*100
FROM #PercentagePopulationVaccinated


-- Creating View to Store Data for Visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated


