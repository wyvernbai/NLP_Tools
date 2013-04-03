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
<pre>
  Found 5909 NEs. Expected 5931 NEs; Correct: 4021.

             precision  recall    F1-Score
     Total:  0.680487 0.677963  0.679223
     PER:  0.745192 0.758977  0.752022
     ORG:  0.447526 0.615097  0.518099
     LOC:  0.823378 0.699019  0.756119
     MISC:   0.812793 0.565689  0.667093
</pre>
