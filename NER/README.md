####NER tools

---
Using the maximum likelihood estimates for transitions and emissions, implement the Viterbi algorithm to compute arg_y1...yn max p(x_1...x_n, y_1...y_n)

I improved my model by split rare word into 5 parts. a) all capitalized word, b) all word whose first letter is capitalized, and others is non-capitalized letter. c) all words that contain only capital letters and dots. d) all words that consists only of numerals.

---

Run the program with command:
<pre>
Command: ruby ner.rb ner_train.dat ner_dev.dat
Output: prediction file "ner_dev_processed.hmmprediction"
</pre>

this program will create temp file ner_train_processed.dat(replaced rare words in ner_train.dat) and ner_processed.count(counts file create by count_freq.py based on ner_train_processed.dat).

then, run the eval script:
<pre>
Command: python eval_ne_tagger.py ner_dev.key ner_dev_processed.hmmprediction
</pre>
Here is the output:
  Found 6357 NEs. Expected 5931 NEs; Correct: 3579.

            precision  recall    F1-Score
     Total:  0.563001 0.603440  0.582520
     PER:  0.464014 0.894450  0.611039
     ORG:  0.484429 0.313901  0.380952
     LOC:  0.804658 0.583969  0.676777
     MISC:   0.720779 0.482085  0.577749