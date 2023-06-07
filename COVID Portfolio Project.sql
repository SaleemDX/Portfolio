Select *
from PortfolioProject..CovidDeaths$
order by 3,4

Select *
from PortfolioProject..CovidVaccinations$
order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at the total cases vs total deaths

-- But first you have to change the data type of the column total_deaths from nvarchar to float to render
-- calculations. 

Alter Table PortfolioProject..CovidDeaths$
Alter Column total_deaths float;

-- Now we can do calcs
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2;

--let's see for the US

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2;

--total cases vs populations in US

Select Location, date, population, total_cases, (total_cases/population)*100 as ContractionRate
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2 desc;

--Countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population)*100 as 
ContractionRate
from PortfolioProject..CovidDeaths$
Group by location, population
order by ContractionRate desc;

--Showing countries with hightest death count rate per Population

Select Location, max(cast(total_deaths as int)) as TotalDeaths, max(total_deaths/population)*100 AS DeathRate
from PortfolioProject..CovidDeaths$
where continent is not null
Group by location
order by TotalDeaths desc;

--Let's break down by continent
Select continent, max(cast(total_deaths as int)) as TotalDeaths, max(total_deaths/population)*100 AS DeathRate
from PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeaths desc;

--Global numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

--Looking at total Population vs Vaccinations

Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.Location order by D.location, D.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
	on D.location = V.location
	and D.date = V.date
where D.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.Location order by D.location, D.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
	on D.location = V.location
	and D.date = V.date
where D.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime, 
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.Location order by D.location, D.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
	on D.location = V.location
	and D.date = V.date
--where D.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating Veiw to store data for later visualization

Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population, V.new_vaccinations, 
SUM(CONVERT(bigint, V.new_vaccinations)) OVER (Partition by D.Location order by D.location, D.date) 
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
	on D.location = V.location
	and D.date = V.date
where D.continent is not null
--order by 2,3