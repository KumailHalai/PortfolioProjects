--Code is Based on Covid Data of one year

--Scanning the Whole Data
Select *
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
Where continent is not null 
order by 3,4

-- Total Cases vs Total Deaths in Pakistan
-- The chances of dying if you contract covid in Pakistan ( change where to your country)
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where location='Pakistan'
order by 1,2

-- Total Cases vs Population in Pakistan
-- Shows what percentage of population infected with Covid in Pakistan

Select Location, date, Population, total_cases, (total_cases/population)*100 as percent_population_infected
From PortfolioProject..CovidDeaths$
Where location='Pakistan'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
-- Shows countries with what percentage of population infected with Covid the most to least

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as percent_population_infected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by percent_population_infected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null 
Group by Location
order by total_death_count desc

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS overall

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 

-- GLOBAL NUMBERS according to highest death percentage

Select convert(varchar, date, 6) as date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
Group By date
order by DeathPercentage desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 Cannot Do this so will use either CTE or Drop Table
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2

-- Using CTE to perform Calculation on Partition By in previous query ( Demonstrating the Use of Common Tabble Expression)

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percentage_vacinated_per_totalpopulation
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query ( Demonstrating the Use of Temp Table)

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
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations and query from it

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
