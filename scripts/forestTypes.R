
# load packages ----

  library(tidyverse)
  library(readxl)
  library(snakecase)

# clean slate ----

  graphics.off()
  rm(list=ls())
  gc()
  
# import and format data ----
  
  data <- read_xls(path = "data/raw/pagami_DOMspecies_bio20131210.xls",
                   sheet = "DOM_spp") %>% 
    select(TP_IDENT, DOM_SPECIES, TOT_sum_BIOMASS, contains("SUM")) %>% 
    rename_with(.cols = 1:3, .fn = ~to_lower_camel_case(.)) %>% 
    mutate(SUM_BEAL = replace_na(SUM_BEAL, 0)) %>% 
    separate_wider_delim(cols = domSpecies, 
                         delim = "-", 
                         too_few = "align_start",
                         names = c("dom1", "dom2", "dom3")) %>% 
    rename(SUM_TOTAL = totSumBiomass) %>% 
    pivot_longer(cols = contains("sum"), 
                 names_to = "species", 
                 names_pattern = "SUM_(\\w*)", 
                 values_to = "biomass") %>% 
  {
    assign(x = "doms",
           value = distinct(., tpIdent, dom1, dom2, dom3),
           envir = .GlobalEnv)
    .
    } %>%
  select(-contains("dom"))
  
# Forest type group mapping function ----
    
  ft_group <- function(code) {
    case_when(
      code >= 101 & code <= 105 ~ "White-Red-Jack Pine",
      code >= 121 & code <= 127 ~ "Spruce-Fir",
      code >= 161 & code <= 167 ~ "Loblolly-Shortleaf Pine",
      code == 171              ~ "Other Eastern Softwoods",
      code >= 381 & code <= 385 ~ "Exotic Softwoods",
      code == 391              ~ "Other Softwoods",
      code >= 401 & code <= 409 ~ "Oak-Pine",
      code >= 501 & code <= 520 ~ "Oak-Hickory",
      code >= 601 & code <= 609 ~ "Oak-Gum-Cypress",
      code >= 701 & code <= 709 ~ "Elm-Ash-Cottonwood",
      code %in% c(801, 802, 805, 809) ~ "Maple-Beech-Birch",
      code >= 901 & code <= 905 ~ "Aspen-Birch",
      code %in% c(991, 995)     ~ "Exotic Hardwoods",
      .default = "Other"
    )
  }

# define groups and codes ----
  
  ## build table of forest types ----
  
    forestTypes <- tibble(
      type = c(
        "ABBA",
        "PIMA",
        "PIGL",
        "PIRE",
        "PIBA",
        "LALA",
        "THOC",
        "PIST",
        "POTR",
        "BEPA",
        "FRNI",
        "BEAL",
        "mixedPine",
        "lowACRU",
        "upACRU"),
      code = c(
        121,  # Balsam fir
        125,  # Black spruce
        122,  # White spruce
        102,  # Red pine
        101,  # Jack pine
        126,  # Tamarack (larch)
        127,  # Northern white-cedar
        103,  # Eastern white pine
        901,  # Aspen
        902,  # Paper birch
        701,  # Black ash / American elm / red maple
        801,  # Sugar maple / beech / yellow birch
        409,  # Other pine / hardwood
        708,  # Red maple / lowland
        809), #  Red maple / upland
      name = c(
        "Balsam fir",
        "Black spruce",
        "White spruce",
        "Red pine",
        "Jack pine",
        "Tamarack (larch)",
        "Northern white-cedar",
        "Eastern white pine",
        "Aspen",
        "Paper birch",
        "Black ash / American elm / red maple",
        "Sugar maple / beech / yellow birch",
        "Other pine / hardwood",
        "Red maple / lowland",
        "Red maple / upland"))
  
  ## build table of wood types ----
  
    trees <- tibble(
        spp = c(
          "ABBA",
          "PIMA",
          "PIGL",
          "PIRE",
          "PIBA",
          "LALA",
          "THOC",
          "PIST",
          "POTR",
          "BEPA",
          "FRNI",
          "BEAL",
          "ACRU",
          "HWSPP",
          "SWSPP",
          "UNKN"),
        type = c(
          "soft",
          "soft",
          "soft",
          "soft",
          "soft",
          "soft",
          "soft",
          "soft",
          "hard",
          "hard",
          "hard",
          "hard",
          "hard",
          "hard",
          "soft",
          "unknown"), 
        pine = c(
          "no", 
          "no", 
          "no", 
          "yes", 
          "yes", 
          "no",
          "no", 
          "yes", 
          "no", 
          "no", 
          "no",
          "no",
          "no",
          "no",
          "no",
          "unknown"))
  
# join tables ----
  
  data.b <- data %>% 
    left_join(trees, join_by(species == spp))
    
# calculate ----
  
  data.c <- data.b %>% 
    filter(species != "TOTAL") %>% 
    mutate(type_pine = paste0(type, "_", pine)) %>% 
    select(-type, -pine) %>% 
    group_by(tpIdent, type_pine) %>% 
      summarize(sum_biomass = sum(biomass), .groups = "keep") %>% 
      ungroup() %>% 
    pivot_wider(names_from = type_pine, values_from = sum_biomass) %>% 
    group_by(tpIdent) %>% 
      mutate(total_biomass = sum(hard_no, soft_no, soft_yes, unknown_unknown),
             softwood_biomass = sum(soft_no, soft_yes),
             prop_softwood = softwood_biomass/total_biomass,
             prop_pine = soft_yes/total_biomass) %>% 
      ungroup() %>% 
    rename(hardwood_biomass = hard_no,
           pine_biomass = soft_yes,
           unk_biomass = unknown_unknown)
  
# apply rules ----
  
  data.d <- data.b %>% 
    left_join(data.c, join_by(tpIdent)) %>% 
    group_by(tpIdent) %>% 
      mutate(lowland_prop = sum(if_else(species == "FRNI" | species == "THOC" | species == "PIMA",
                                        biomass, 0))/total_biomass) %>% 
      mutate(is_top_soft = case_when(type == "soft" & 
                                       biomass == max(if_else(condition = type == "soft", 
                                                              true = biomass, 
                                                              false = -Inf), 
                                                      na.rm = TRUE) 
                                     ~ TRUE,
                                     .default = FALSE)) %>% 
      mutate(is_top_hard = case_when(type == "hard" & 
                                       biomass == max(if_else(type == "hard", 
                                                              biomass, -Inf), 
                                                      na.rm = TRUE) 
                                     ~ TRUE,
                                     .default = FALSE)) %>% 
      mutate(is_top_pine = case_when(pine == "yes" & 
                                       biomass == max(if_else(type == "soft", 
                                                              biomass, -Inf), 
                                                      na.rm = TRUE) 
                                     ~ TRUE,
                                     .default = FALSE)) %>%
      mutate(is_top_nonPineSoft = case_when(type == "soft" & 
                                            biomass == max(if_else(type == "soft" & pine == "no", 
                                                                   biomass, -Inf), 
                                                           na.rm = TRUE) 
                                            ~ TRUE,
                                            .default = FALSE)) %>%
      mutate(is_pine_enough = case_when(pine == "yes" & prop_pine >= 0.5 &
                                          biomass == max(if_else(pine == "yes", 
                                                                 biomass, -Inf), 
                                                      na.rm = TRUE) 
                                        ~ TRUE,
                                        .default = FALSE)) %>% 
      mutate(rule = case_when(prop_softwood >= 0.5 & 
                                prop_pine >= 0.25 & 
                                prop_pine < 0.5
                                ~ "mixedPine",
                              prop_softwood >= 0.5 & 
                                prop_pine < 0.25 &
                                is_top_nonPineSoft == TRUE
                                ~ species,
                              prop_softwood >= 0.5 & 
                                prop_pine >= 0.5 &
                                is_top_pine == TRUE
                                ~ species,
                              prop_softwood < 0.5 
                                & is_top_hard == TRUE 
                                & species == "ACRU"
                                & lowland_prop >= 0.2 
                                ~ "lowACRU",
                              prop_softwood < 0.5 
                                & is_top_hard == TRUE 
                                & species == "ACRU"
                                & lowland_prop < 0.2 
                                ~ "upACRU",
                              prop_softwood < 0.5 
                                & is_top_hard == TRUE 
                                & species != "ACRU"
                                ~ species,
                              .default = NA)) %>% 
    distinct(tpIdent, rule) %>% 
    filter(!is.na(rule)) 

  plotTypes <- data.d %>% 
    left_join(forestTypes, join_by(rule == type)) %>% 
    mutate(group = ft_group(code)) %>% 
    select(-rule)
  
  write_csv(x = plotTypes, file = "data/reference/forestTypes.csv")
