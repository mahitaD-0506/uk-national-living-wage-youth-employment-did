# uk-national-living-wage-youth-employment-did-

# Evaluating the Impact of the UK National Living Wage on Youth Employment

## Project Overview

This project evaluates whether the introduction of the UK National Living Wage in April 2016 affected employment outcomes for young workers aged 18–24 in the UK.

The analysis uses UK Labour Force Survey longitudinal data from 2013–2018 and applies a Difference-in-Differences approach. The treatment group is workers aged 18–24, while the comparison group is workers aged 25–64.

## Research Question

What effect did the introduction of the National Living Wage have on youth employment among workers aged 18–24 in the UK?

## Methodology

The project uses a Difference-in-Differences model to compare employment outcomes before and after the introduction of the National Living Wage.

The main regression specification is:

`employed = β0 + β1post + β2young + β3(post × young) + ε`

The coefficient of interest is `post × young`, which captures the differential change in youth employment after the policy was introduced.

## Data

This project uses the UK Labour Force Survey Two-Quarter Longitudinal Datasets for 2013–2015 and 2017–2018, accessed through the UK Data Service.

The raw dataset is not included in this repository because access may be subject to licensing restrictions.

## Key Findings

The baseline model finds no statistically significant effect on youth employment.

After adding controls for sex, marital status, education, ethnicity, and disability, the Difference-in-Differences coefficient becomes positive and statistically significant.

The controlled model suggests that youth employment increased by approximately 2.1 percentage points relative to older workers after the introduction of the National Living Wage.

Pre-trends testing supports the validity of the Difference-in-Differences approach, and robustness checks show that the main result remains positive across alternative specifications.

## Skills Demonstrated

- Econometric analysis
- Difference-in-Differences estimation
- Policy evaluation
- Regression modelling
- Robustness testing
- Event study analysis
- Data cleaning
- Statistical interpretation
- Stata programming
- Written communication of analytical findings

## Tools Used

- Stata
- UK Labour Force Survey longitudinal data
- Difference-in-Differences estimation
- Event study analysis

## Repository Structure

```text
uk-national-living-wage-youth-employment/
│
├── README.md
├── code/
│   └── analysis.do
├── report/
│   └── nlw_youth_employment_portfolio_report.pdf
├── data/
│   ├── data_access_notes.md
│   └── data_dictionary.md
└── outputs/
    ├── pre_trends_graph.png
    └── event_study_graph.png
