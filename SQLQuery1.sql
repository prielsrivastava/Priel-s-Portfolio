Select *
From PortfolioProject1..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations$
--order by 3,4

--Select the data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths$ 
order by 1,2

--Check the total cases vs Total Deaths
--Shows the likelihood of dying if a  person contracts covid in their country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--inserted this line to look at the United States specifically
From PortfolioProject1..CovidDeaths$ 
Where location like '%states%'and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of population got Covid 
Select location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths$ 
Where location like '%states%' and continent is not null
order by 1,2

--Countries with the highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths$ 
--Where location like '%states%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--Show countries with the higest death count per population
--casting total_deaths as integer because it was stored as a char in the database
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$ 
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--Break data down by continent 
--Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject1..CovidDeaths$ 
--Where location like '%states%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$ 
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Show the continents with the highest death counts
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths$ 
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
--Will be utilizing aggergate functions here to perform a calculation on multiple values

Select date, SUM(New_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--inserted this line to look at the United States specifically
From PortfolioProject1..CovidDeaths$ 
Where location like '%states%'
Group by date
order by 1,2

--Looking at total population vs vaccinations
--Join the two data tables 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations$ vac
Join PortfolioProject1..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--USE CTE, a temporary named result set
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations$ vac
Join PortfolioProject1..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temporary Table

DROP Table if exists #PercentPopulationVaccinated --Removes one or more table definitons and all data, indexes, triggers, permission specificiations for those tables
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations$ vac
Join PortfolioProject1..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for late visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidVaccinations$ vac
Join PortfolioProject1..CovidDeaths$ dea
	On dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated