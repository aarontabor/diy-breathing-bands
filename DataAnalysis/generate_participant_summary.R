library('ggplot2')
library('reshape2')

df = read.csv('p1/p1_data.csv')
df = subset(df, phase != 'none')


# Scale Readings to a common range (CHEST)
flex_min = min(df$flex_abdomen)
flex_max = max(df$flex_abdomen)
df$flex_scaled = (df$flex_abdomen - flex_min) / (flex_max - flex_min)

cord_min = min(df$cord_abdomen)
cord_max = max(df$cord_abdomen)
df$cord_scaled = (df$cord_abdomen - cord_min) / (cord_max - cord_min)

fabric_min = min(df$fabric_abdomen)
fabric_max = max(df$fabric_abdomen)
df$fabric_scaled = (df$fabric_abdomen - fabric_min) / (fabric_max - fabric_min)

therm_min = min(df$therm)
therm_max = max(df$therm)
df$therm_scaled = (df$therm - therm_min) / (therm_max - therm_min)



# Plot
df.melted = melt(df,
                 measure.vars = c('flex_scaled', 'cord_scaled', 'fabric_scaled', 'therm_scaled'),
                 variable.name = 'sensor',
                 value.name = 'reading')

plt = qplot(elapsed_time/1000, reading, data=df.melted, geom='point', color=phase, facets=sensor~.)
ggsave("p1/summary.png", width=72, height=20, units="cm", limitsize=FALSE)

