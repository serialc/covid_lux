
main <- read.table('data/Situation Générale.csv', sep=',', header=T)

# simplify col names
colnames(main) <- c('date', 'cases24h_smth7', 'incare24h', 'cases24h', 'cumul_deaths')
# turn dates from string to dates
main$date <- as.Date(main$date, format = "%d/%m/%Y")

# build new data
main$deaths24h <- c(0,diff(main$cumul_deaths))
# overwrite cases24h_smth7, they use delayed method, I want centered
main$cases24h_smth7 <- filter(main$cases24h, filter = rep(1/7,7))
main$deaths24h_smth7 <- filter(main$deaths24h, filter = rep(1/7,7))
#plot(main$cases24h_smth7, filter(main$cases24h, filter = rep(1/7,7)), main='centered')
#plot(main$cases24h_smth7, filter(main$cases24h, filter = rep(1/7,7), sides = 1), main='delayed')

# sanity plots

# raw numbers
png(filename = 'figures/confirmed_cases_and_deaths.png', width = 600, height=400)
par(mar=c(4,4,2,4))
plot(main$date, main$cases24h, col='red', type='l', lwd=2, ylab='', xlab='Date', yaxt='n', main="Daily values")
axis(2, col='red', col.axis='red', col.ticks = 'red', ); mtext("Confirmed cases", 2, 2, col="red")
par(new=T)
plot(main$date, main$deaths24h, col='black', type='l', lwd=2, axes=F, ann=F)
axis(4); mtext("Deaths", 4, 2)
dev.off()

# Smoothed
png(filename = 'figures/smoothed_confirmed_cases_and_deaths.png', width = 600, height=400)
par(mar=c(4,4,2,4))
plot(main$date, main$cases24h_smth7, col='red', type='l', lwd=2, ylab='', xlab='Date', yaxt='n', main="Smoothed (7-days)")
par(new=T)
plot(main$date, main$deaths24h_smth7, col='black', type='l', lwd=2, axes=F, ann=F)
axis(4); mtext("Deaths", 4, 2)
axis(2, col='red', col.axis='red', col.ticks = 'red', ); mtext("Confirmed cases", 2, 2, col="red")
dev.off()

# Now let's get the percentage of the tests carried out that were positive
perc <- read.table('data/Pourcentage de tests COVID-19 positifs.csv', sep=',', header=T)
colnames(perc) <- c('date', 'pos_perc')
# turn dates from string to dates
perc$date <- as.Date(perc$date, format = "%d/%m/%Y")

# add to last plot
png(filename = 'figures/smoothed_confirmed_cases_and_test_pos_pc.png', width = 600, height=400)
par(mar=c(4,4,2,4))
plot(main$date, main$cases24h_smth7, col='red', type='l', lwd=2, ylab='', xlab='Date', yaxt='n', main="Smoothed (7-days)")
par(new=T)
axis(2, col='red', col.axis='red', col.ticks = 'red', ); mtext("Confirmed cases", 2, 2, col="red")
par(new=T)
plot(perc$date, perc$pos_perc, col='darkgreen', type='l', lwd=2, ann=F, axes=F)
axis(4, col='darkgreen', col.axis='darkgreen', col.ticks = 'darkgreen')
mtext("Percentage of tests positive (COVID-19)", 4, 2, col='darkgreen')
dev.off()

# That looks good. Let's try to estimate number of cases using the method from the paper
# merge sets for simplicity
full <- merge(main, perc, by = 'date')
full$cc_estim_low <- (1 + full$pos_perc * 0.01) * full$cases24h
full$cc_estim_high <- (1 + full$pos_perc * 0.02) * full$cases24h
full$cc_estim_low_smth7 <- filter(full$cc_estim_low, filter = rep(1/7,7))
full$cc_estim_high_smth7 <- filter(full$cc_estim_high, filter = rep(1/7,7))

# Try this again
png(filename = 'figures/adjusted_cases.png', width = 600, height=400)
plot(full$date, full$cc_estim_high_smth7, xlab='Date', ylab='COVID-19 Cases (7-day smoothed)', type='n', main="(Flawed) Adjusted estimated cases in Luxembourg")
# drop rows with NA for polygon
polygon(c(full$date[!is.na(full$cc_estim_high_smth7)], rev(full$date[!is.na(full$cc_estim_high_smth7)])), c(full$cc_estim_low_smth7[!is.na(full$cc_estim_high_smth7)], rev(full$cc_estim_high_smth7[!is.na(full$cc_estim_high_smth7)])), col='grey', lty=0)
# known cases confirmed
lines(full$date, full$cases24h_smth7, lwd=2)
mtext("Estimated actual number of cases", 4, 2, col='grey')
legend('top', legend = c('Confirmed cases - 7 day average', 'Estimated total number'), lty=c(1,NA), pt.bg ='black', lwd=c(2,0), fill=c(NA, 'grey'), border = NA)
dev.off()

