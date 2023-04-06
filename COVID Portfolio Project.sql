-- Create Database

create database PortfolioProject1

-- Data Inspection

select * from PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4 

-- Select Data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2 

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dyiing if you contract covid in your country

select location, date, total_cases, total_deaths, (CAST(total_deaths as decimal)/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%states%'
order by 1,2 desc

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

select location, date, population, total_cases, (CAST(total_cases as decimal)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths 
where location like '%states%' 
order by 1,2

-- Looking at countries with highest infection compared to population 

select location, population, MAX((CAST(total_cases as decimal))) as HighestInfectionCount, 
     MAX((CAST(total_cases as decimal)/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with the highest death count per population

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc 

-- Breaking things down by Continents

-- Showing continents with the highest death count per population

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc 

-- Global Numbers 

update PortfolioProject..CovidDeaths 
set new_cases = null 
where new_cases = 0 


select sum(new_cases) as total_cases, sum(cast(new_deaths as decimal)) as total_deaths, 
     sum(cast(new_deaths as decimal))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
--group by date
order by 1,2 

-- Exploring the Covid Death and Vaccinations Tables Using Joins
-- Looking at total population vs vaccinations

select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null 
order by 2,3 

-- USE CTE 

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null 
)
select * , (Cast(RollingPeopleVaccinated as decimal)/Population)*100
from PopvsVac

-- TEMP Table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric, 
    RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
--where dea.continent is not null 
--order by 2,3

select * , (Cast(RollingPeopleVaccinated as decimal)/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations 

create view PercentPopulationVaccinated as
select dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations, 
sum(new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac 
    on dea.[location] = vac.[location]
    and dea.[date] = vac.[date]
where dea.continent is not null
--order by 2,3 

select * 
from PercentPopulationVaccinated