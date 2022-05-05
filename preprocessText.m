%function to clean the review text data for analysis
function [documents] = preprocessText(reviewText)
cleanTextData = lower(reviewText);
documents = tokenizedDocument(cleanTextData);
erasePunctuation(documents);
documents = removeStopWords(documents);
end 

