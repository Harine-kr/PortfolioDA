/*
Covid 19 Data Exploration Project

Skills applied: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Displaying the two tables after importing

Select *
From PortfolioProject..CovidDeaths;

SELECT * 
FROM PortfolioProject..CovidVaccinations;

--refining the query result

Select *
From PortfolioProject..CovidDeaths
--Where continent is not null 
order by 3,4;

Select *
From PortfolioProject..CovidVaccinations
--Where continent is not null 
order by 3,4;

--Selecting data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2;

--Looking at total cases vs total deaths in a country
--this helps us understand the likelihood of dying if infected in a country

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2;

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
Where location like '%india%'
order by 1,2;

--total cases vs population
--shows what percentage of population infected with covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentageInfected
from PortfolioProject..CovidDeaths
order by 1,2;

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentageInfected
from PortfolioProject..CovidDeaths
Where location like 'india'
order by 1,2;

--countries with higest infection rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc;

--countries with highest death count per population
--total_deaths were nvarchar
--when continent was null it was interfering with location

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc;

--we were breaking things down by location now lets break things down by continent

--showing continents with highest death count per population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc;

--global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2;

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2;


--Exploring the vaccination data

Select * from
PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
on dea.location= vac.location
and dea.date=vac.date;

--total population vs vaccinations
--shows percentage of population that has received at least one covid vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and roll
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccThen
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
order by 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;