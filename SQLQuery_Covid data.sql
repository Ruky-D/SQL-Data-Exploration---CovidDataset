use [PortfolioProject]


select *
from dbo.CovidDeaths

select *
from dbo.CovidDeaths
where continent is not null
order by 3,4


select *
from dbo.CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
where continent is not null
order by 1,2

---Total Cases vs Total deaths 
select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)* 100 AS DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2

--in Canada
select location, date, total_cases, total_deaths, (Total_deaths/Total_cases)* 100 AS DeathPercentage
from dbo.CovidDeaths
Where location like '%Canada%' and continent is not null
order by 1,2

--Total cases vs population ( what percentage of the total population got covid
select location, date, population, total_cases, (Total_cases/population)* 100 AS InfectionPercentage
from dbo.CovidDeaths
Where location like '%Canada%'
order by 1,2


---Looking at countries with hightest infection rates
select location, Max(total_cases) HighestinfectionCount, Max((Total_cases/population))* 100 AS InfectionPercentage
from dbo.CovidDeaths
where continent is not null
Group By location, population
Order by InfectionPercentage desc

--- Showing COunries with highest Death COunt per population
select location, Max(cast (total_deaths as int)) HighestDeathCount
from dbo.CovidDeaths
where continent is not null
Group By location, population
Order by HighestDeathCount Desc

--Break things down by continent
select location, Max(cast (total_deaths as int)) TotalDeathCount
from dbo.CovidDeaths
where continent is null
Group By location
Order by TotalDeathCount Desc


-- Showing Continents with highest death counts

select continent, Max(cast (total_deaths as int)) TotalDeathCount
from dbo.CovidDeaths
where continent is not null
Group By continent
Order by TotalDeathCount Desc

---Global Numbers
Select (cast (date as date)),SUM(new_cases), SUM(cast (new_deaths as int)), Round(((SUM(cast (new_deaths as int))/SUM(new_cases))*100), 2) as DeathPercentage
from dbo.CovidDeaths
where continent is not null
Group By date
Order by 1,2


--Total population vs vaccinations

select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
from PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD .date = CV.date 
where CD.continent is not null
Order by 2,3

--Rolling Count of Total Population Vs Vaccinations

select CD.continent, CD.location, CD.date, CD.population, (cast (CV.new_vaccinations as int)), 
SUM (cast (CV.new_vaccinations as int)) over (Partition By cd.location order by cd.location, cd.date) RollingVaccinationCount
from PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD .date = CV.date 
where CD.continent is not null
Order by 2,3

--Usint CTE to get rolling Percentages
with PopVsVac (Continent, Location, Date, population, New_Vaccinations, RollingVaccinationCount) 
as
(select CD.continent, CD.location, CD.date, CD.population, (cast (CV.new_vaccinations as int)), 
SUM (cast (CV.new_vaccinations as int)) over (Partition By cd.location order by cd.location, cd.date) RollingVaccinationCount
from PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD .date = CV.date 
where CD.continent is not null
)
select *, Round((RollingVaccinationCount/population)*100,2)
from PopVsVac


---Using Temp Tables instead of CTE
Drop Table if exists #PopVaccinated

Create table #PopVaccinated
(Continent nvarchar (255),
Location nvarchar(255),
Date Datetime,
Population bigint,
new_vaccinations bigint,
RollingVaccinationCount numeric
)

insert into #PopVaccinated
select CD.continent, CD.location, CD.date, CD.population, (cast (CV.new_vaccinations as int)), 
SUM (cast (CV.new_vaccinations as int)) over (Partition By cd.location order by cd.location, cd.date) RollingVaccinationCount
from PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD .date = CV.date 
where CD.continent is not null

select *, Round((RollingVaccinationCount/population)*100,2) PercentPopVaccinated
from #PopVaccinated

--Create Views to store data for later visualizations

Create View populationVaccinated as
select CD.continent, CD.location, CD.date, CD.population, (cast (CV.new_vaccinations as int)) new_Vaccinations, 
SUM (cast (CV.new_vaccinations as int)) over (Partition By cd.location order by cd.location, cd.date) RollingVaccinationCount
from PortfolioProject..CovidDeaths CD
Join PortfolioProject..CovidVaccinations CV
on CD.location = CV.location
and CD .date = CV.date 
where CD.continent is not null


