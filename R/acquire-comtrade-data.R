# Process for downloading Comtrade data and extracting FFD trade
# Best run as a job in Rstudio

library(iapdashboardadmin)

key <- Sys.getenv("COMTRADE_KEY")
folder <- here::here("data", "downloads")

yrs <- c(2010:2018)
ctys <- c(660, 533, 112, 58, 84, 204, 60, 64, 68, 535, 92, 96, 854, 108, 132, 116, 136, 140, 148, 344, 446, 174, 178,
     184, 384, 192, 531, 200, 408, 180, 262, 212, 214, 588, 218, 222, 226, 232, 97, 234, 238, 886, 278, 866, 720,
     230, 280, 582, 590, 592, 868, 717, 736, 835, 810, 890, 836, 254, 258, 583, 266, 270, 268, 288, 292, 304, 308,
     312, 320, 324, 624, 328, 332, 336, 340, 356, 368, 400, 398, 296, 414, 417, 418, 422, 426, 430, 434, 450, 454,
     462, 466, 470, 584, 474, 478, 480, 175, 496, 500, 508, 104, 580, 516, 524, 530, 532, 540, 558, 562,
     512, 490, 585, 598, 600, 459, 634, 498, 638, 646, 647, 461, 654, 659, 658, 662, 534, 666, 670,
     882, 674, 678, 457, 686, 891, 690, 694, 711,  90, 706, 728, 144, 275, 729, 740, 748, 757, 760,
     762, 807, 626, 768, 772, 776, 780, 788, 795, 796, 798, 800, 826, 834, 858, 850, 841, 860, 548,
     862, 876, 887, 894, 716)

iapdashboardadmin::get_countries_years(periods = yrs, reporters = ctys, token = key, dest_folder = folder, unzip = FALSE)

ffd_trade <- iapdashboardadmin::merge_ffd(here::here("data", "downloads"))

saveRDS(ffd_trade, here::here("data", "db", paste0(Sys.Date(), "_ffd_trade.rds")))
