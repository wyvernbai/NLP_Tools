####IBM Model1####

Recall that IBM model 1 only has word translation parameters t(f|e), which can be interpreted as the conditional probability of generating a foreign word f from an English word e (or from NULL). Estimate t(f |e) using the *EM algorithm* in this program.

ibmmodel1_test.rb is a IBM model1 test programe. It has two function:

* For each English word e in devwords.txt, print the list of the foreign words with the highest t(f |e) parameter (and the parameter itself)
* use the model to find alignments for the sentence pairs in the training data
	
	
To run IBM model1 test:
	<pre>
ruby ibmmode1_test.rb corpus.en corpus.de devwords.txt 10 5 20</pre>

* 10 means 10 foreign words with the highest t(f |e) parameter.
* 5 means running 5 iterations of the EM algorithm.
* 20 means using ibm model 1 to find alignments for the first 20 sentence pairs in the training data.
  	
Here is the output:
<pre>
i
[["ich", 0.42717946287809744], [",", 0.1009515320848458], [".", 0.062317827436341094], ["da&szlig;", 0.032094589328632815], ["m&ouml;chte", 0.029105372852299135], ["habe", 0.0212210942784231], ["die", 0.020146165002278903], ["der", 0.015215242997828487], ["und", 0.012377873760526813], ["zu", 0.012265739348434756]]
dog
[["servitium", 0.056685858731335456], ["delendum", 0.056685858731335456], ["postalis", 0.056685858731335456], ["&uuml;bersetzen", 0.056685858731335456], ["cato", 0.056685858731335456], ["esse", 0.056685858731335456], ["k&uuml;chenlatein", 0.056685858731335456], ["stehen", 0.05603613387922579], ["darf", 0.055457108838032336], ["jetzt", 0.05350419228592811]]
man
[["mann", 0.10723545648074366], [",", 0.051972217693707294], ["mensch", 0.03453345746286934], [".", 0.02925670347084909], ["wie", 0.0251793583495383], ["der", 0.024438504902521623], ["die", 0.02267105767162628], ["ehrenwerter", 0.021073207165965325], ["wortwahl", 0.021073207165965325], ["ein", 0.020761098091195952]]
keys
...
...
</pre>
	
<pre>
resumption of the session
wiederaufnahme der sitzungsperiode 
[0, 1, 3]
<br \>i declare resumed the session of the european parliament adjourned on thursday , 28 march 1996 .
ich erkl&auml;re die am donnerstag , den 28. m&auml;rz 1996 unterbrochene sitzungsperiode des europ&auml;ischen parlaments f&uuml;r wiederaufgenommen . 
[0, 9, 3, 11, 11, 12, 3, 13, 14, 15, 9, 4, 9, 7, 8, 9, 2, 16]
...
...
</pre>

---
####IBM Modle2####
Similar to IBM model1. To run IBM model1 test:
<pre>ruby ibmmodel2_test.rb corpus.en corpus.de 5 20
Output: stdout & a ibm model2 file called "ibmmodel2.model"</pre>

  * 5 means running 5 iterations of the EM algorithm.
  * 20 means using ibm model2 to find alignments for the first 20 sentence pairs in the training data.

Here is the result:
<pre>
resumption of the session  
wiederaufnahme der sitzungsperiode 
[0, 2, 3]

i declare resumed the session of the european parliament adjourned on thursday , 28 march 1996 .  
ich erkl&auml;re die am donnerstag , den 28. m&auml;rz 1996 unterbrochene sitzungsperiode des europ&auml;ischen parlaments f&uuml;r wiederaufgenommen . 
[0, 1, 2, 11, 11, 12, 6, 13, 14, 15, 9, 4, 9, 7, 9, 15, 2, 16]

...
...
</pre>
