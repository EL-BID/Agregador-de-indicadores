library(agregadorindicadores)

ai_cachelist <- ai_cache(lang = "en")

save(ai_cachelist, file = "data/ai_cachelist.RData", compress = "xz")


topics<-read.csv("./data-raw/topicMatch.csv")
save(topics, file = "data/topics.RData", compress = "xz")


schema<-read.csv("./data-raw/schemaMatch.csv")
save(schema, file = "data/schema.RData", compress = "xz")


keywords<-read.csv("./data-raw/classify.csv", stringsAsFactors = FALSE)
save(keywords, file = "data/keywords.RData", compress = "xz")