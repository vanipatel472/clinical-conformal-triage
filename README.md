# clinical-conformal-triage
Reliability-aware clinical triage using Split-Conformal Prediction and the MIMIC-IV-ED schema.


# Reliability-Aware Clinical Triage 
### Implementing Split-Conformal Prediction for High-Stakes MedTech

## Project Overview
Standard machine learning models in healthcare often suffer from **overconfidence** - they provide a single prediction without quantifying the statistical "risk of being wrong." For a clinical startup, a high accuracy model that cannot signal when it is "confused" by messy data is a significant regulatory and safety liability.

This project implements a **Split-Conformal Prediction** wrapper on a triage pipeline inspired by the **MIMIC-IV-ED schema**. Instead of a "black-box" guess, this system generates **statistically rigorous confidence sets**, ensuring a pre-defined safety guarantee (e.g. 95% coverage) is maintained even on out-of-distribution clinical data.

## Key Features
* **Uncertainty Quantification:** Transforms point-estimate probabilities into distribution-free prediction sets.
* **Ambiguity Detection:** Automatically flags "Ambiguous" cases (where the confidence set contains multiple possible outcomes) for immediate human clinician review.
* **Scientist-Level Pipeline:** Implements a rigorous three way split (Training, Calibration, and Testing) to ensure the validity of the statistical guarantees.
* **Business ROI:** Identifies the "Automation-Safety Tradeoff", allowing startups to automate routine cases with near-perfect certainty while de-risking complex clinical encounters.

## Technical Stack
* **Language:** R (tidyverse, tidymodels, ggplot2)
* **Methodology:** Split-Conformal Prediction / Uncertainty Quantification (UQ)
* **Domain:** Clinical Informatics / Emergency Department Triage / MedTech

## Methodology & Results
The framework evaluates model surprise (non-conformity) on a dedicated calibration set to determine a threshold ($q\_hat$). 

1. **Scoring:** We calculate the non-conformity score as $1 - \hat{f}(x)_y$.
2. **Thresholding:** We find the $(1-\alpha)$ quantile of scores to define the boundary for the 95% confidence set.
3. **Deployment:** On the test set, the model only outputs a "High-Certainty" prediction if only one class exceeds the probability threshold. Otherwise, the case is flagged as "Ambiguous."

> **Impact:** By isolating ambiguous cases, we maintain almost perfect accuracy on automated decisions, providing the statistical traceability required for FDA AI/ML regulatory clearance.

## Repository Structure
* `data_pipeline.R`: Simulation of the MIMIC-IV-ED schema and feature engineering.
* `conformal_wrapper.R`: Implementation of non-conformity scoring and $q\_hat$ calculation.
* `visualizations.R`: ggplot2 scripts for the "Certainty vs. Ambiguity" ROI plots.
* `Technical_Brief.pdf`: A 2-page executive summary for clinical and commercial stakeholders.

---

## References & Acknowledgments
This implementation is inspired by and builds upon foundational research in distribution-free uncertainty and conformal:

* **Research Paper:** [Uncertainty Sets for Image Classifiers using Conformal Prediction](https://arxiv.org/abs/2107.07511) (Angelopoulos & Bates, 2021).
* **Reference Implementation:** [Conformal Triage GitHub](https://github.com/aangelopoulos/conformal-triage) by Anastasios Angelopoulos.

---

## About the Author
I am a **Master’s student in Biostatistics and Health Data Science** at the University of Pittsburgh School of Public Health (expected graduation Dec 2026). 

With a multidisciplinary undergraduate background in **Bioinformatics and Business** from the University of Waterloo, I bridge the gap between large-scale biological data,  statistical inference, and commercial product strategy. I am currently seeking **Summer 2026 Internship** opportunities in Scientist or Engineer-level roles where I can help startups build reliable, safety-first health technology.

**Connect with me:** vanipatel1526@gmail.com | www.linkedin.com/in/vanipatel472 
