library(agregadorindicadores)

ai_cachelist <- ai_cache(lang = "en")

save(ai_cachelist, file = "data/ai_cachelist.RData", compress = "xz")