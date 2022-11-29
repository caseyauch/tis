indicators <- read_csv("./indicators.csv")

#infrastructure
indicator_rank <- indicators %>%
  group_by(mpo) %>%
  mutate(bike_rank = rank(bikefacility_p)/length(bikefacility_p)) %>%
  mutate(sidewalk_rank = rank(sidewalk_p)/length(sidewalk_p)) %>%
  mutate(pwb_rank = rank(potential)/length(potential))  %>%
  mutate(infra_sum = pwb_rank+sidewalk_rank+bike_rank)%>%
  mutate(infra_rank = rank(infra_sum)/length(infra_sum))
#safety 
indicator_rank <- indicator_rank %>%
  group_by(mpo) %>%
  mutate(crash_rank = rank(crash_count)/length(crash_count)) %>%
  mutate(risk_rank = rank(risk_ratio)/length(risk_ratio)) %>%
  mutate(safety_sum = risk_rank + crash_rank) %>%
  mutate(safety_rank = 1-(rank(safety_sum)/length(safety_sum)))
#accessibility
indicator_rank <- indicator_rank %>%
  group_by(mpo) %>%
  mutate(cd_rank = rank(cd_sum)/length(cd_sum)) %>%
  mutate(job_rank = rank(job_mean)/length(job_mean)) %>%
  mutate(access_sum = cd_rank+job_rank) %>%
  mutate(access_rank = rank(access_sum)/length(access_sum))
#affordability
indicator_rank <- indicator_rank %>%
  group_by(mpo) %>%
  mutate(h_rank = rank(hcost_p)/length(hcost_p)) %>%
  mutate(t_rank = rank(tcost_p)/length(tcost_p)) %>%
  mutate(afford_sum = h_rank+t_rank) %>%
  mutate(afford_rank = 1-(rank(afford_sum)/length(afford_sum)))
#environment
indicator_rank <- indicator_rank %>%
  group_by(mpo) %>%
  mutate(env_rank = 1-(rank(vmt_sum)/length(vmt_sum)))
#totaling the transportation is supportive score
indicator_rank <- indicator_rank %>%
  group_by(mpo) %>%
  mutate(tis = infra_rank+safety_rank+access_rank+afford_rank+env_rank)

#simplified indicator_rank table 
tis <- indicator_rank %>% select('blockid', 'mpo', 'town', 'infra_rank', 'safety_rank', 'access_rank', 'afford_rank', 'env_rank', 'tis')

regions <- tis %>% split(tis$mpo)
list2env(regions, envir=.GlobalEnv)
print(tis)

write_excel_csv(tis,"S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/tis_final.xls")
write_csv(indicator_rank,"S:/Data and Policy/Casey Analysis/Projects/Beyond Mobility Analysis/Tables/1 Final tables/indicator_rank.csv")
