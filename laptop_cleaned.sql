-- data cleaning

-- creating a backup table from the original table

create table laptop_backup like laptopdata_uncleaned;

insert into laptop_backup
select * from laptopdata_uncleaned;

-- check the total rows
select count(*) from laptopdata_uncleaned;

-- drop the unnecessary columns (in my case unnamed: 0 is not important for my analysis)
alter table laptopdata_uncleaned
drop column `unnamed: 0`;

-- Drop null values
DELETE FROM laptopdata_uncleaned
WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL AND ScreenResolution
 IS NULL AND Cpu IS NULL AND Ram IS NULL AND Memory IS NULL AND Gpu IS NULL AND OpSys IS NULL AND WEIGHT IS NULL AND Price IS NULL;

-- dropping all the duplicates
-- select *,row_number() over(partition by company) from laptopdata_uncleaned

-- cleaning RAM COLUMN > replacing the GB and updating the datatype
update laptopdata_uncleaned
set Ram = replace(Ram,'GB','')
alter table laptopdata_uncleaned modify column Ram integer

-- changing the inches column data type
alter table laptopdata_uncleaned modify column inches decimal(10,2)

-- cleaning Weight COLUMN > replacing the KG
update laptopdata_uncleaned
set Weight = replace(Weight,'kg','')

-- rounding the value of the price column and changing the datatype
UPDATE laptopdata_uncleaned
SET price = ROUND(CAST(price AS decimal));

alter table laptopdata_uncleaned
modify column price int

-- change the OpSys column

select distinct opsys,
case when opsys like 'mac%' then 'macos'
when opsys like 'linux%' then 'linux'
when opsys like 'windows%' then 'windows'
when opsys = 'No OS' then 'N/A'
else 'others'
end as brands
 from laptopdata_uncleaned

update laptopdata_uncleaned
set opsys = 
case when opsys like 'mac%' then 'macos'
when opsys like 'linux%' then 'linux'
when opsys like 'windows%' then 'windows'
when opsys = 'No OS' then 'N/A'
else 'others'
end 

-- spliting the Gpu column into gpu brand and gpu name
select * from laptopdata_uncleaned

alter table laptopdata_uncleaned
add column gpu_brand varchar(255) after Gpu,
add column gpu_name varchar(255) after gpu_brand

update laptopdata_uncleaned
set gpu_brand = substring_index(Gpu,' ',1)

update laptopdata_uncleaned
set gpu_name = replace(Gpu,gpu_brand,'')

-- now we dont need the gpu column so drop it
alter table laptopdata_uncleaned drop column Gpu

-- spliting the cpu column into cpu brand and cpu name and cpu speed
select * from laptopdata_uncleaned

alter table laptopdata_uncleaned
add column cpu_brand varchar(255) after Cpu,
add column cpu_name varchar(255) after cpu_brand,
add column cpu_speed decimal(10,1) after cpu_name

update laptopdata_uncleaned
set cpu_brand = substring_index(cpu,' ',1)

update laptopdata_uncleaned
set cpu_speed = cast(replace(substring_index(cpu,' ',-1),'Ghz','')as decimal(10,2))

update laptopdata_uncleaned
set cpu_name =  replace(replace(cpu,cpu_brand,''),substring_index(replace(cpu,cpu_brand,''),'',-1),'')

alter table laptopdata_uncleaned drop cpu

-- select cpu_name,substring_index(trim(cpu_name),' ',2) from laptopdata_uncleaned
update laptopdata_uncleaned
set cpu_name = substring_index(trim(cpu_name),' ',2)

select * from laptopdata_uncleaned

-- updating memory column adding memory_type column from memory

-- select memory,
-- case when memory like '%SSD%' and memory like '%HDD%' then 'Hybrid'
-- when memory like '%SSD%' then 'SSD'
-- when memory like '%HDD%' then 'HDD'
-- WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
-- WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
-- WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
--  end as memory_type
--  from laptopdata_uncleaned

alter table laptopdata_uncleaned
add column memory_type varchar(255) after memory

update laptopdata_uncleaned
set memory_type = 
case when memory like '%SSD%' and memory like '%HDD%' then 'Hybrid'
when memory like '%SSD%' then 'SSD'
when memory like '%HDD%' then 'HDD'
WHEN Memory LIKE '%Flash Storage%' THEN 'Flash Storage'
WHEN Memory LIKE '%Hybrid%' THEN 'Hybrid'
WHEN Memory LIKE '%Flash Storage%' AND Memory LIKE '%HDD%' THEN 'Hybrid'
else null
end