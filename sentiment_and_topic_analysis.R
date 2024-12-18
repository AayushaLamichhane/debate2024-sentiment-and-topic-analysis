# Install necessary packages
install.packages(c("tm", "tidytext", "dplyr", "stringr", "ggplot2", "topicmodels", "wordcloud"))
install.packages("syuzhet")

# Load libraries
library(stringr)
library(tidytext)
library(dplyr)
library(ggplot2)
library(topicmodels)
library(wordcloud)
library(tidyr)
library(syuzhet)

# Read in the text file
debate_text <- readLines("Debate.txt")

# Collapse the text into a single character vector
full_text <- paste(debate_text, collapse = " ")

# Extract Trump’s and Harris's statements
trump_text <- str_extract(full_text, "(?<=TRUMP).*?(?=HARRIS|$)")
harris_text <- str_extract(full_text, "(?<=HARRIS).*?(?=TRUMP|$)")

# Create a data frame with one row per speaker
debate_df <- data.frame(
  Speaker = c("Donald Trump", "Kamala Harris"),
  Text = c(trump_text, harris_text),
  stringsAsFactors = FALSE
)

# Tokenize and clean
debate_words <- debate_df %>%
  unnest_tokens(word, Text) %>%
  anti_join(stop_words) # Remove common stop words

# Calculate total word count for each speaker #########################
word_count <- debate_words %>%
  group_by(Speaker) %>%
  summarise(total_words = n())

# Calculate word frequency by speaker
word_freq <- debate_words %>%
  count(Speaker, word, sort = TRUE)

# Display top words for each speaker
top_words <- word_freq %>%
  group_by(Speaker) %>%
  slice_max(n, n = 10)

# Plot most frequent words
ggplot(top_words, aes(reorder(word, n), n, fill = Speaker)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~Speaker, scales = "free_y") +
  labs(x = NULL, y = "Frequency") +
  coord_flip() +
  theme_minimal()

######################### Updated Sentiment Analysis (Bing) #########################
# Load lexicon
sentiments <- get_sentiments("bing")

# Join with debate words to analyze sentiment
sentiment_analysis <- debate_words %>%
  inner_join(sentiments, by = "word") %>%
  count(Speaker, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(sentiment_score = positive - negative)

# Normalize Bing sentiment counts
sentiment_analysis_normalized <- sentiment_analysis %>%
  left_join(word_count, by = "Speaker") %>%
  mutate(
    positive = positive / total_words,
    negative = negative / total_words,
    sentiment_score = sentiment_score / total_words
  ) %>%
  select(-total_words)

# Plot normalized sentiment scores
ggplot(sentiment_analysis_normalized, aes(x = Speaker, y = sentiment_score, fill = Speaker)) +
  geom_bar(stat = "identity") +
  labs(y = "Normalized Sentiment Score (per word)", x = "Speaker") +
  theme_minimal()

sentiment_analysis_normalized

######################### Updated Emotional Analysis (NRC Lexicon) #########################
# Preprocess text for both speakers
trump_text <- paste(debate_words %>% filter(Speaker == "Donald Trump") %>% pull(word), collapse = " ")
harris_text <- paste(debate_words %>% filter(Speaker == "Kamala Harris") %>% pull(word), collapse = " ")

# Sentiment analysis using NRC lexicon
trump_sentiments <- get_nrc_sentiment(trump_text)
harris_sentiments <- get_nrc_sentiment(harris_text)

# Combine sentiment results
sentiment_df <- rbind(
  data.frame(Speaker = "Donald Trump", trump_sentiments),
  data.frame(Speaker = "Kamala Harris", harris_sentiments)
)

# Summarize emotion counts for each speaker
sentiment_summary <- sentiment_df %>%
  group_by(Speaker) %>%
  summarise(across(everything(), sum))

# Normalize emotion counts
sentiment_summary_normalized <- sentiment_summary %>%
  left_join(word_count, by = "Speaker") %>%
  mutate(across(-c(Speaker, total_words), ~ . / total_words)) %>%
  select(-total_words)

# Reshape normalized emotion data
sentiment_long_normalized <- sentiment_summary_normalized %>%
  pivot_longer(cols = -Speaker, names_to = "Emotion", values_to = "Normalized_Count")

# Plot normalized emotion distribution
ggplot(sentiment_long_normalized, aes(x = Emotion, y = Normalized_Count, fill = Speaker)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = round(Normalized_Count, 3)),
            position = position_dodge(width = 0.9),
            vjust = -0.3, size = 3) + # Adds the numbers above the bars
  labs(title = "Normalized Emotion Distribution by Speaker",
       y = "Normalized Count (per word)",
       x = "Emotion") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

sentiment_long_normalized

######################### Topic Modeling #########################
# Set the number of topics
num_topics <- 5

# Create a document-term matrix
debate_dtm <- debate_words %>%
  count(Speaker, word) %>%
  cast_dtm(Speaker, word, n)

# Apply LDA topic modeling
debate_lda <- LDA(debate_dtm, k = num_topics, control = list(seed = 1234))

# Extract the top terms for each topic
debate_topics <- tidy(debate_lda, matrix = "beta")
top_terms <- debate_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 10) %>%
  ungroup() %>%
  arrange(topic, -beta)

# Define custom topic names
topic_labels <- c(
  "Leadership and Governance",
  "Economic Issues and Global Affairs",
  "Communication and Unity",
  "Policy and Social Issues",
  "Economy and Foreign Policy"
)

# Add topic labels to top_terms
top_terms <- top_terms %>%
  mutate(topic_name = topic_labels[topic])

# Plot top terms with topic names
ggplot(top_terms, aes(reorder_within(term, beta, topic_name), beta, fill = factor(topic_name))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic_name, scales = "free") +
  coord_flip() +
  labs(x = "Top Terms", y = "Beta") +
  theme_minimal() +
  scale_x_reordered()

######################### Word Clouds #########################
par(mar = c(1, 1, 1, 1)) # Reduce margins for the word cloud

# Word cloud for Donald Trump
trump_words <- debate_words %>%
  filter(Speaker == "Donald Trump") %>%
  count(word, sort = TRUE)

wordcloud(trump_words$word, trump_words$n, max.words = 100, colors = "red")

# Word cloud for Kamala Harris
harris_words <- debate_words %>%
  filter(Speaker == "Kamala Harris") %>%
  count(word, sort = TRUE)

wordcloud(harris_words$word, harris_words$n, max.words = 100, colors = "blue")
