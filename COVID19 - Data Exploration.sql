/*
Covid 19 Data Exploration from January 2020 - January 2022

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From SQLCovid..CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From SQLCovid..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From SQLCovid..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location,Population, MAX(total_cases) as HighestInfection, MAX(total_cases/population)*100 as PercentPopulationInfected
From SQLCovid..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From SQLCovid..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From SQLCovid..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From SQLCovid..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population) * 100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--Use CTE to perform Calcualation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccationas numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
From SQLCovid..CovidDeaths dea
Join SQLCovid..CovidVaccines vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
