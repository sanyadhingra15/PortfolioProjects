--select * 
--from PortfolioProject..CovidDeaths
--order by 3,4

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Data we are going to use--
select location,date,total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total death(Example:Like 1000 people got 
--diagonised with covid but 10 died so how much percentage of people
--died who had covid)

select location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at total cases vs population--
--Shows what percentage of population got covid--
select location,date,total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2


--highest infection rate as compared to population---
select location,population,MAX(total_cases) as HighestInfectionRate, population, MAX((total_cases/population))*100 
as PopulationInfectionRate
from PortfolioProject..CovidDeaths
--where location like '%India%'
group by location,population
order by PopulationInfectionRate desc

---showing countries with highest death count per population--
select location,MAX(CAST(total_deaths AS Int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is NULL
group by location
order by HighestDeathCount desc


select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total vaccinations vs population--
--partition func--- like the vaccination count increases as per the row

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) over (PARTITION BY dea.location order by dea.location,dea.date) as--CAST OR CONVERT works same 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100---we cant use created column in the query to calculate percentage so we will use 
--CTE--
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE---
With popvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) over (PARTITION BY dea.location order by dea.location,dea.date) as--CAST OR CONVERT works same 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100---we cant use created column in the query to calculate percentage so we will use 
--CTE--
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3-- order by doesnt work in CTE
)
select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
from popvsVac


--UST TEMP Table--

Drop table if exists #populationVaccinated

Create Table #populationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #populationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) over (PARTITION BY dea.location order by dea.location,dea.date) as--CAST OR CONVERT works same 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100---we cant use created column in the query to calculate percentage so we will use 
--CTE--
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select * , (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercent
from #populationVaccinated

---Cretae view for later visualizations-

Create view populationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations as int)) over (PARTITION BY dea.location order by dea.location,dea.date) as--CAST OR CONVERT works same 
RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100---we cant use created column in the query to calculate percentage so we will use 
--CTE--
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
