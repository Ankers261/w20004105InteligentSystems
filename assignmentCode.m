%Opening the positive words list from the working file
positiveFile = fopen(fullfile('opinion-lexicon-English','positive-words.txt'));
%Opening the negative words list from the working file
negativeFile = fopen(fullfile('opinion-lexicon-English','negative-words.txt'));

%Viewing and extracting the positive words from the open positive file
posScan = textscan(positiveFile, '%s', 'CommentStyle', ';');
%Viewing and extracting the negative words from the open negative file
negScan = textscan(negativeFile, '%s', 'CommentStyle', ';');

%converting the positive words from the file to a string
wordsPos = string(posScan{1});
%converting the negative words from the file to a string
wordsNeg = string(negScan{1});

%Closing the files
fclose all;

%Establishing a hashtable to store the words
words_hashtable = java.util.Hashtable;

%storing the size of the positive words list
[positiveSize, ~] = size(wordsPos);
%storing the size of the negative words list
[negativeSize, ~] = size(wordsNeg);

%Iterating through the positive words list and placing them in hashtable
%Assigning positive words with a 1
for i = 1 : positiveSize
    words_hashtable.put(wordsPos(i,1),1);
end

%Iterating through the negative words list and placing them in hashtable
%Assigning positive words with a -1
for i = 1 : negativeSize
    words_hashtable.put(wordsNeg(i,1),-1);
end


%Loading test dataset
dataset = "comfort_camry_toyota_2007.txt";
%Reading the dataset
carReviews = readtable(dataset,'format','auto');
%extracting reviews from the dataset
reviewText = carReviews.Review;
%extracting the given score from the dataset
goldenScore = carReviews.Score;
%Running the text processing function on the review text
processedText = preprocessText(reviewText);
%outputting success of data loading
fprintf('File: %s, Sentences: %d \n', dataset, size(processedText));

%Setting all sentiment scores to 0
sentimentScore = zeros(size(processedText));

%Iterating over the reveiws after they have been processed
%Each sentence is analysed for sum of sentiment scores
%Then if it's overall positive it is 1 and overall negative is -1
for i = 1 : processedText.length
    documentWords = processedText(i).Vocabulary;
    for j = 1 : length(documentWords)
        if words_hashtable.containsKey(documentWords(j))
            sentimentScore(i) = sentimentScore(i) + words_hashtable.get(documentWords(j));
        end
    end
    if (sentimentScore(i) >= 1)
        sentimentScore(i) = 1;
    elseif (sentimentScore(i) <= -1)
        sentimentScore(i) = -1;
    end
    fprintf('Sentence: %d, words: %s, FoundScore: %d, GoldScore: %d\n', i, joinWords(processedText(i)), sentimentScore(i), goldenScore(i));
end


%find the quantity of scores that are 0
zeroValue = sum(sentimentScore == 0);

%Find all reviews that are overall positive or negative
coveredTexts = numel(sentimentScore) - zeroValue;

fprintf("Total of positive and negative classes: %2.2f%%, Distinct %d, Not found or Neutral: %d\n",(coveredTexts*100)/numel(sentimentScore), coveredTexts, zeroValue);

%calculating the number of true positives
truePos = sentimentScore((sentimentScore==1) & (goldenScore==1));
%calculating the number of true negatives
trueNeg = sentimentScore((sentimentScore==-1) & (goldenScore==0));

%Calculating the accuracy by comparing the true answers to total texts
%covered
accuracy = (numel(truePos) + numel(trueNeg))*100/coveredTexts;

fprintf("Accuracy: %2.2f%%, TP: %d, TN: %d\n", accuracy, numel(truePos), numel(trueNeg)); 











