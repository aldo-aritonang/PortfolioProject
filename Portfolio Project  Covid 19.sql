/*
Eksplorasi Data Covid 19

Query yang Digunakan: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


select * from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4


--Tampilkan data yang ingin kita mulai

select Location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2


--total kasus vs total kematian
--menampilkan persentase kematian berdasarkan negara tempat tinggal

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from PortofolioProject..CovidDeaths
where location like '%Indonesia%'
and continent is not null
order by 1,2


--total kasus vs populasi
--menampilkan persentase populasi yang terinfeksi covid 19

select location,  date, population, total_cases, (total_cases/population)*100 as percentpopulationinfected
from PortofolioProject..CovidDeaths
where location like '%Indonesia%'
order by 1,2



--Negara dengan jumlah terinfeksi covid  19 tertinggi di compare dengan populasi

select location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from PortofolioProject..CovidDeaths
--where location like '%Indonesia%'
group by location, population
order by percentpopulationinfected desc


--negara dengan jumlah kematian tertinggi per populasi

select location, min(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null 
group by location
order by TotalDeathCount asc



-- BENUA

-- menampilkan jumlah kematian tertinggi per populasi berdasarkan benua


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- menampilkan negara dengan jumlah kematian tertinggi per populasi berdasarkan benua

select continent, max(location), max(cast(total_deaths as int)) as TotalDeathCount
from PortofolioProject..CovidDeaths
where continent is not null
and continent like '%Asia%'
group by continent, location
order by TotalDeathCount desc


--Jumlah global

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2


--Total Populasi vs Vaksinasi
--Menampilkan persentasi dari populasi yang sudah menerima vaksin (Setidaknya vaksin pertama)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Menggunakan CTE's untuk menampilkan perhitungan pada query sebelumnya

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location like '%Indonesia%'

)
Select *, (RollingPeopleVaccinated/Population)*100 as percentageofvaccinated
From PopvsVac

order by 2,3


-- Temp Table

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
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3