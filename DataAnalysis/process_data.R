library('ez')
library('plyr')
library('ggplot2')
library('reshape2')

new_theme = theme_bw(base_size = 16) +
           theme(panel.grid.major = element_line(size=.5, color="#e0e0e0"),
                 axis.line = element_line(size=.7, color="#e0e0e0"),
                 panel.border = element_rect(fill=NA, color="#e0e0e0"),
                 plot.margin=unit(c(2,2,2,2),"mm"))


# Import Dataset
df = read.csv('dataset.csv')
df.melted = melt(df,
                 measure.vars = c('flex_R', 'cord_R', 'fabric_R'),
                 variable.name = 'band',
                 value.name = 'r_error')


### Sanity Check 1: Were RMSE somewhat consistent across participants?
  
# Summarize Data
  df.rmse.participant = ddply(df.melted, c('participant', 'band'), summarize,
                          N = length(r_error),
                          rmse = sqrt(mean(r_error**2)))
  
  df.participant = ddply(df.rmse.participant, c('participant'), summarize,
                         N = length(rmse),
                         se = sd(rmse)/sqrt(N),
                         rmse = mean(rmse))
  
  p = ggplot(df.participant, aes(x=factor(participant), y=rmse)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Participant') +
    ylab(label='Root Mean Square Error (RMSE)') +
    new_theme +
    guides(fill=FALSE)
  p
  ggsave("rmse-by-participant.png", width=18, height=10, units="cm")
  
  

### Sanity Check 2: Are RMSE somewhat consistent across groups?
  
  # Summarize Data
  df.rmse.group = ddply(df.melted, c('participant', 'group'), summarize,
                        N = length(r_error),
                        rmse = sqrt(mean(r_error**2)))
  
  # Plot By Group
  df.group = ddply(df.rmse.group, c('group'), summarize,
                   N = length(rmse),
                   se = sd(rmse)/sqrt(N),
                   rmse = mean(rmse))
  
  ## TODO, how do I know this ordering will always be correct?
  df.group$group = factor(df.group$group, labels=c('fl-co-fa', 'co-fa-fl', 'fa-fl-co'))
  
  p = ggplot(df.group, aes(x=group, y=rmse)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Band Ordering (Top to Bottom)') +
    ylab(label='Root Mean Square Error (RMSE)') +
    new_theme +
    theme(legend.position="bottom") +
    guides(fill=guide_legend(title=NULL))
  p
  ggsave("rmse-by-group.png", width=18, height=10, units="cm")
  

  
### Analysis 1: Overall RMSE

  # Summarize Data
  df.rmse.overall = ddply(df.melted, c('participant', 'band'), summarize,
                       N = length(r_error),
                       rmse = sqrt(mean(r_error**2)))
  
  # Perform ANOVA
  anova.overall = ezANOVA(data=df.rmse.overall, dv=rmse, wid=participant, within=.(band), type=3, detailed=TRUE, return_aov=TRUE)
  anova.overall
  
  pairwise.t.test(df.rmse.overall$rmse, df.rmse.overall$band, p.adj = "bonf")
  
  
  # Plot By Band
  df.overall = ddply(df.rmse.overall, c('band'), summarize,
                       N = length(rmse),
                       se = sd(rmse)/sqrt(N),
                       rmse = mean(rmse))
  
  ## TODO, how do I know this ordering will always be correct?
  df.overall$band = factor(df.overall$band, labels=c('flex', 'cord', 'fabric'))
  
  p = ggplot(df.overall, aes(x=band, y=rmse, fill=band)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Breath Monitoring Band') +
    ylab(label='Root Mean Square Error (RMSE)') +
    new_theme +
    guides(fill=FALSE)
  p
  ggsave("rmse-by-band.png", width=18, height=10, units="cm")

  
### Analysis 2: RMSE by Phase
  
  # Summarize Data
  df.rmse.phase = ddply(df.melted, c('participant', 'band', 'phase'), summarize,
                          N = length(r_error),
                          rmse = sqrt(mean(r_error**2)))
  
  # Perform ANOVA
  anova.phase = ezANOVA(data=df.rmse.phase, dv=rmse, wid=participant, within=.(band, phase), type=3, detailed=TRUE, return_aov=TRUE)
  anova.phase
  
  # pairwise.t.test(df.rmse.phase$rmse, df.rmse.phase$phase, p.adj = "bonf")
  
  # Plot By Phase
  df.phase = ddply(df.rmse.phase, c('phase'), summarize,
                   N = length(rmse),
                   se = sd(rmse)/sqrt(N),
                   rmse = mean(rmse))
  
  p = ggplot(df.phase, aes(x=phase, y=rmse)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Breathing Phase') +
    ylab(label='Root Mean Square Error (RMSE)') +
    scale_x_discrete(limits=c("natural","deep","medium","shallow", "elevated"),
                     labels=c("Natural", "Deep\n6 cpm/n100%","Medium\n12 cpm\n75%", "Shallow\n18 cpm\n50%", 
                              "Elevated")) +
    new_theme
  p
  ggsave("rmse-by-phase.png", width=18, height=12, units="cm")
  
  # Plot By Band and Phase
  df.phase = ddply(df.rmse.phase, c('band', 'phase'), summarize,
                       N = length(rmse),
                       se = sd(rmse)/sqrt(N),
                       rmse = mean(rmse))
  
  ## TODO, how do I know this ordering will always be correct?
  df.phase$band = factor(df.phase$band, labels=c('flex', 'cord', 'fabric'))
  
  p = ggplot(df.phase, aes(x=phase, y=rmse, fill=band)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Breathing Phase') +
    ylab(label='Root Mean Square Error (RMSE)') +
    scale_x_discrete(limits=c("natural","deep","medium","shallow", "elevated"),
                     labels=c("Natural", "Deep\n6 cpm\n100%","Medium\n12 cpm\n75%", "Shallow\n18 cpm\n50%", 
                              "Elevated")) +
    new_theme +
    theme(legend.position="bottom") +
    guides(fill=guide_legend(title=NULL))
  p
  ggsave("rmse-by-phase-by-band.png", width=18, height=12, units="cm")
  


### Analysis 3: RMSE by Group
  
  # Summarize Data
  df.rmse.group = ddply(df.melted, c('participant', 'band', 'group'), summarize,
                        N = length(r_error),
                        rmse = sqrt(mean(r_error**2)))
  
  # Perform ANOVA
  ## TODO: Adjust back to type 3 once groups are balanced
  anova.group = ezANOVA(data=df.rmse.group, dv=rmse, wid=participant, within=.(band, group), type=3, detailed=TRUE, return_aov=TRUE)
  anova.group
  
  # pairwise.t.test(df.rmse.phase$rmse, .(df.rmse.overall$band, df.rmse.overall$phase), p.adj = "bonf")
  
  
  # Plot By Group by Band
  df.group = ddply(df.rmse.group, c('band', 'group'), summarize,
                   N = length(rmse),
                   se = sd(rmse)/sqrt(N),
                   rmse = mean(rmse))
  
  ## TODO, how do I know this ordering will always be correct?
  df.group$band = factor(df.group$band, labels=c('flex', 'cord', 'fabric'))
  df.group$group = factor(df.group$group, labels=c('fl-co-fa', 'co-fa-fl', 'fa-fl-co'))
  
  p = ggplot(df.group, aes(x=group, y=rmse, fill=band)) +
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=rmse-se, ymax=rmse+se), width=0.2, position=position_dodge(width=0.9)) +
    xlab(label='Band Ordering (Top to Bottom)') +
    ylab(label='Root Mean Square Error (RMSE)') +
    new_theme +
    theme(legend.position="bottom") +
    guides(fill=guide_legend(title=NULL))
  p
  ggsave("rmse-by-group-by-band.png", width=18, height=10, units="cm")