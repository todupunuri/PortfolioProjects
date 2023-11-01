select top 1 location,
       CHARINDEX('A',location) as a_location,
       date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
from dbo.CovidDeaths
order by 1,2

--looking at total cases vs total deaths---
-- provide data on the mortality rate associated with COVID-19 infection in your country.--
select location,
       date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases)*100 as [deathpercentage]
from dbo.CovidDeaths where location ='india' and continent is not null
order by location,date

--looking at the total_cases VS population--
--shows what percent of population got covid--
select location,
       date,
	   total_cases,
	   population,
	   (total_cases/population)*100 as [Covid_percentage]
from dbo.CovidDeaths where location ='india' and continent is not null
order by location,date

--looking at countries with highest infection rate compared to population--
select location,
       population,
       max(total_cases) as HighestInfectionRate,
	   max(total_cases/population)*100 as [percentage_infected]
	   from dbo.CovidDeaths where  continent is not null
group by location,population
order by [percentage_infected] desc


--lets break down by continent--
--showing continent with highest death count per population--
select continent,
max(cast(total_deaths as int))as totalDeathCount
from dbo.CovidDeaths where  continent  is not  null
group by continent
order by totalDeathCount desc


--global numbers--
select 
       sum(new_cases) as total_new_cases,
	   sum(cast(new_deaths as int))as total_new_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage

	   from CovidDeaths
	   where continent is not null
	   order by 1,2


	   --joiningboth the tables--
--Total Population that has been vaccinated in the world

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
from dbo.CovidDeaths CD join dbo.CovidVaccinations CV on  CD.location=cv.location and cd.date=cv.date 
where cd.continent is not null
order by cd.location,cd.date 


--Finding the total vaccination number by partitioning by location,so we can get everyday's total
--vaccinations and it is gonna add to the coming days vaccinations )
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date)as rollingpeoplevaccinated
from dbo.CovidDeaths cd join dbo.CovidDeaths cv on cd.location=cv.location
and cd.date=cv.date where cd.continent is not null and cd.location='albania' order by cd.location,cd.date


--
with PopvsVac (Continent,Location,Date,Population,new_vaccinations,rollingpeoplevaccinated)
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date)as rollingpeoplevaccinated
from dbo.CovidDeaths cd join dbo.CovidDeaths cv on cd.location=cv.location
and cd.date=cv.date where cd.continent is not null and cd.location='albania'
--order by cd.location,cd.date

)
select *,(rollingpeoplevaccinated/Population)*100 from PopvsVac

--Temp table(--raising error--)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
[location] nvarchar(255),
[Date] datetime,
[Population] numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date)as rollingpeoplevaccinated
from dbo.CovidDeaths cd join dbo.CovidDeaths cv on cd.location=cv.location
and cd.date=cv.date where cd.continent is not null and cd.location='albania'
--order by cd.location,cd.date
select *,(rollingpeoplevaccinated/Population)*100 from #PercentPopulationVaccinated


--View--
create View percentpopulationVaccinated
AS
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location,cd.date)as rollingpeoplevaccinated
from dbo.CovidDeaths cd join dbo.CovidDeaths cv on cd.location=cv.location
and cd.date=cv.date where cd.continent is not null and cd.location='albania'
--order by cd.location,cd.date

)



