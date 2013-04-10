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
  Found 5872 NEs. Expected 5931 NEs; Correct: 4390.

             precision  recall    F1-Score
     Total:  0.747616 0.740179  0.743879
     PER:  0.829310 0.785092  0.806596
     ORG:  0.535123 0.700299  0.606669
     LOC:  0.852378 0.752454  0.799305
     MISC:   0.826772 0.684039  0.748663
</pre>
