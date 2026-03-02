# ============================================================
# Script de génération de la base de données simulée
# Thème : Déterminants des salaires (équation de Mincer étendue)
# ============================================================
# Ce script génère une base de données réaliste de 500 individus
# actifs sur le marché du travail, inspirée des enquêtes Emploi.
# Sauvegarder ce fichier et exécuter pour obtenir salaires.csv

set.seed(2024)
n <- 500

# --- Variables explicatives ---
education     <- sample(8:22, n, replace = TRUE,
                        prob = c(0.02,0.03,0.05,0.08,0.10,
                                 0.12,0.12,0.12,0.10,0.08,
                                 0.07,0.05,0.04,0.01,0.01))
experience    <- pmax(0, round(rnorm(n, mean = 18, sd = 10)))
experience    <- pmin(experience, 45)                          # cap à 45 ans
femme         <- rbinom(n, 1, prob = 0.48)
secteur_pub   <- rbinom(n, 1, prob = 0.30)
taille_ville  <- sample(c("rural","petite","grande"), n,
                        replace = TRUE, prob = c(0.25, 0.35, 0.40))
type_contrat  <- sample(c("CDI","CDD","indep"), n,
                        replace = TRUE, prob = c(0.65, 0.20, 0.15))
nb_enfants    <- rpois(n, lambda = 1.2)
syndique      <- rbinom(n, 1, prob = 0.12)

# --- Encodages factoriels pour la vraie loi ---
ville_eff  <- ifelse(taille_ville == "grande", 0.12,
              ifelse(taille_ville == "petite", 0.05, 0))
contrat_eff <- ifelse(type_contrat == "CDI", 0.10,
               ifelse(type_contrat == "indep", 0.05, 0))

# --- Log-salaire (vraie relation + bruit) ---
log_salaire <- 5.80 +
               0.085  * education +          # rendement de l'éducation
               0.040  * experience +          # rendement de l'expérience
              -0.0006 * experience^2 +        # concavité (Mincer)
              -0.180  * femme +               # écart de genre
               0.130  * secteur_pub +         # prime public
               ville_eff +                   # prime urbaine
               contrat_eff +                 # prime CDI
               0.020  * syndique +            # prime syndicat
              -0.015  * nb_enfants * femme +  # pénalité enfants (femmes)
               rnorm(n, 0, 0.22)             # résidu

salaire <- round(exp(log_salaire))

# --- Heures travaillées par semaine ---
heures <- round(rnorm(n, mean = 38, sd = 5))
heures <- pmax(15, pmin(heures, 60))

# --- Âge (dérivé) ---
age <- 16 + education - 6 + experience + round(rnorm(n, 0, 1))
age <- pmax(18, pmin(age, 65))

# --- Assemblage ---
donnees <- data.frame(
  id           = 1:n,
  salaire      = salaire,
  log_salaire  = round(log(salaire), 4),
  education    = education,
  experience   = experience,
  exp_carre    = experience^2,
  age          = age,
  femme        = femme,
  secteur_pub  = secteur_pub,
  taille_ville = taille_ville,
  type_contrat = type_contrat,
  nb_enfants   = nb_enfants,
  syndique     = syndique,
  heures       = heures
)

write.csv(donnees, "salaires.csv", row.names = FALSE)
cat("Base de données générée : salaires.csv\n")
cat("Dimensions :", nrow(donnees), "lignes x", ncol(donnees), "colonnes\n")
cat("\nAperçu des premières lignes :\n")
print(head(donnees, 6))
