# Sentiment and Topic Analysis of the 2024 Presidential Debate

This repository contains the code and related files for the project **"Sentiment and Topic Analysis of the 2024 Presidential Debate"** by Aayusha Lamichhane. The analysis uses **natural language processing** techniques in R to uncover sentiment trends, emotional tones, and dominant topics from the candidates' speeches.

---

## Table of Contents
- [Description](#description)
- [Prerequisites](#prerequisites)
- [Running the Code](#running-the-code)
- [Data Sources](#data-sources)
- [Project Files](#project-files)
- [Outputs](#outputs)
- [Contact Information](#contact-information)

---

## Description
This project focuses on analyzing the linguistic tone and thematic content of the 2024 U.S. Presidential Debate. The tasks include:

- **Sentiment Analysis**: Evaluated positive and negative sentiment using Bing and NRC lexicons.  
- **Emotion Analysis**: Measured emotions such as trust, anger, and joy for each candidate.  
- **Topic Modeling**: Identified the top 5 themes using Latent Dirichlet Allocation (LDA).  
- **Word Frequency**: Generated word clouds and frequency charts for comparative analysis.

---

## Prerequisites
To run the code, ensure you have the following:

1. **R** and **RStudio**: Installed on your system.  
2. **Libraries**: Install the required R packages:  
   ```r
   install.packages(c("tidytext", "dplyr", "ggplot2", "syuzhet", "topicmodels", "wordcloud", "tm", "tidyr"))


## Running the Code

1. Clone the Repository:
```
  git clone https://github.com/username/debate-analysis.git
  cd debate-analysis
```
2. Load the Script: Open sentiment_and_topic_analysis.R in RStudio.
3. Run the Code: Execute the script line by line or as a whole. The script performs the following tasks:
  - Reads and preprocesses the debate transcript.
  - Generates sentiment scores, emotion distributions, and word frequency plots.
  - Implements topic modeling and visualizes the results.

## Data Sources
- **Debate Transcript**: Provided in `debate_transcript.txt`.
- **Sentiment Lexicons**:
  - **Bing**: Positive and negative word classification.
  - **NRC**: Emotion-based categories (trust, fear, joy, etc.).

## Project Link
For a detailed summary of the project and findings, please refer to the final presentation:  
[Sentiment and Topic Analysis of the 2024 Presidential Debate](Analysis_2024_Presidential_Debate_Presentation.pdf).

## Contact Information
For questions or feedback, please reach out to:  
📧 **Aayusha Lamichhane** – [lamichhaneaayusha@gmail.com](mailto:lamichhaneaayusha@gmail.com).
