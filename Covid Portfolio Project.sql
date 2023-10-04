select *
from PortfolioProject..CovidDeath
where location like '%State%' and total_deaths is not null
order by 3, 4

select *
from PortfolioProject..CovidVaccination
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by 3, 4

---Looking at the total deaths and total cases---------
--Need to convert the division caculation into folat number like using (cast (value as float))--- 

select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentages
from PortfolioProject..CovidDeath
where location like 'United S%'
order by 1, 2


--------Looking at total_cases vs populations-------
---Shows what percentages population got covid efficted---

select location, date, Population, total_cases, (cast(total_cases as float)/ cast(Population as float)) * 100 as PopulationPercentages
from PortfolioProject..CovidDeath
where location like 'United S%'
order by 1, 2 


---Looking at contries heighest infrection rate compare to population---

select location, Population, max(total_cases) as HighestInfactions, max((cast(total_cases as float)/ cast(Population as float))) * 100 as PopulationPercentages
from PortfolioProject..CovidDeath
--where location like 'United S%'
group by location, population
order by PopulationPercentages desc



----Show the countrie's heigest death count per population---

select location, population, max(cast(total_deaths as int)) as DeathCount
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by location, population
order by DeathCount desc

----Showing continent of height death count per population ---

select continent, max(cast(total_deaths as int)) as DeathCount
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by continent
order by DeathCount desc


----Gobal number----

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Totaldeath, 
		CASE
        WHEN SUM(new_cases) = 0 THEN 0 -- Handle division by zero
        ELSE (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100
    END as DeathPercentages
from PortfolioProject.dbo.CovidDeath
where continent is not null
group by date
order by 1, 2




----find total cases, total death and Deathpercentafes--- 

select  sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as Totaldeath, 
		CASE
        WHEN SUM(new_cases) = 0 THEN 0 -- Handle division by zero
        ELSE (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100
    END as DeathPercentages
from PortfolioProject.dbo.CovidDeath
where continent is not null
order by 1, 2

select *
from PortfolioProject..CovidVaccination




--Join table together--
--Looking total population vs Vaccinations---

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeath as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


------Using partition by --------- 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(float, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidDeath as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3



-----Finding population vs vaccinations----
----------Using CTE Table-----


with PeovsVac(continent, location, date, population, new_vaccinations, VaccinatingPeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinatingPeople
from PortfolioProject..CovidDeath as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (VaccinatingPeople / population) * 100 as VaccinatedPercentagesPopulation
from PeovsVac



-----TEMP Table------
--Drop table method need to use so we can create temp table as mush as we can--

drop table if exists #PercentagePopulationVaccinated 
create table #PercentagePopulationVaccinated
(continet nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
VaccinatingPeople numeric)


insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinatingPeople
from PortfolioProject..CovidDeath as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null

select *, (VaccinatingPeople / population) * 100 as VaccinatedPercentagesPopulation
from #PercentagePopulationVaccinated




------Creating view to store data for later visualiazitions------
drop view if exists PercentagePopulationVaccinated
create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as VaccinatingPeople
from PortfolioProject..CovidDeath as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null



select *
from PortfolioProject.dbo.PercentagePopulationVaccinated