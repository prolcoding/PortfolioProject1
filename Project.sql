--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccination
--order by 3,4

--select the data that we are going to use

--Select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..CovidDeaths
--order by 1,2

--Total Cases vs Total Deaths
--showing likehood of dying if you contact covid in a given country
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from PortfolioProject..CovidDeaths
--where location like '%zim%'
--order by 1,2

--Total Cases Vs Population
--% of population with covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulatioInfected
from PortfolioProject..CovidDeaths
where location like '%zim%'
order by 1,2

--Countries With Highest Infection Rate Compared To Popution

Select location,  population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopulatioInfected
from PortfolioProject..CovidDeaths
--where location like '%zim%'
group by location, population
order by PercentagePopulatioInfected desc

--Countries With Highest DeathCount per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%zim%'
group by location
order by TotalDeathCount desc

--Group by continent


Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
--where location like '%zim%'
group by location
order by TotalDeathCount desc


--Showing Continents With Highest Death Counts
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%zim%'
group by continent
order by TotalDeathCount desc

---Global Numbers
select date, sum(new_cases)as TotalDailyNewCases, sum(cast(new_deaths as int))TotalDailyDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2
 
 --Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--TempTables
Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location

and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated


--Creating Views
Create View PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccination vac
on dea.location = vac.location

and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinated