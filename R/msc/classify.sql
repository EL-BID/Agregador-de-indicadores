--Gender 
update indicator_df 
set gender='Female'
where (Lower(indicator) like '% girls %' 
 or Lower(indicator) like '% female%'
 or Lower(indicator) like 'female %'
 or Lower(indicator) like '% women%' 
 or Lower(indicator) like 'women%'
 or Lower(indicator) like '%gender%'
 or Lower(indicator) like  'vaw laws %'
 or Lower(indicator) like  '% maternity%'
 or indicator like '%GPI%'
 or Lower(indicator) like  '%domestic violence%'
 or Lower(indicator) like  '%mother%'
 or Lower(indicator) like '%sexual harassment%');
 
update indicator_df 
set gender='Male'
where (gender is null or gender='other') 
and (Lower(indicator) like '% male%' 
or Lower(indicator) like '% men in%'
or Lower(indicator) like '%paternity%');

 --AREA
update indicator_df 
set area='Rural'
where Lower(indicator) like '% rural%';

update indicator_df 
set area='Urban'
where area is null and Lower(indicator) like '% urban%';
  
update indicator_df 
set area='Total'
where area is null and Lower(indicator) like '% total%';

update indicator_df 
set area='Other'
where area is null;

--Multiplier
update indicator_df
set multiplier=-1
WHERE REGEXP_LIKE(indicator,'not good at math|helpless at math|Year women obtained election|Press Freedom Index|VAW laws SIGI|Unmet need|unemployed|unemployment|Out of school|homicide|outstanding|informal|death|mort|drop|HIV|viol|disor| vulnerable| fertility|unimpro|disea|wife beating|working very long|DALYs|Forced first sex','i');

update indicator_df
set multiplier=1
WHERE multiplier IS NULL;

update indicator_df
set topic='Other'
where topic is null;
