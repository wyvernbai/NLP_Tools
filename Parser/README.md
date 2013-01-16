----
####Maximum likelihood estimates  + CKY algorithm Parser####

1. As in the tagging model, we need to predict emission probabilities for words in the test data that do not occur in the training data. Recall our approach is to map infrequent words in the training data to a common class and to treat unseen words as members of this class. Replace infrequent words (Count(x) < 5) in the original training data file with a common symbol RARE .
	<pre>
Command: ruby data_process.rb parse_train.dat parse_train_rare.dat
Output: parse_train_rare.dat
</pre> 

2. Using the maximum likelihood estimates for the rule parameters, implement the CKY algorithm to produce output in the following format: the tree for one sentence per line represented in the JSON tree format.
	<pre>
Command: python count_cfg_freq.py parse_train_rare.dat > cfg_rare.counts
Ouput: cfg_rare.counts</pre>
	<pre>
Command: ruby pcfg_parser.rb cfg_rare.counts parse_dev.dat parse_dev.res
Output: parse_dev.res
</pre>
	Then, run the eval script:
	<pre>
python eval_parser.py parse_dev.key parse_dev.res</pre>
	You will get output like below:
	<pre>
 +----------+------+------------+------------+------------+
 |Type      |Total |Precision   |Recall      |F1 Score    |
 +----------+------+------------+------------+------------+
 |.         |370   |1.000       |1.000       |1.000       |
 |ADJ       |164   |0.827       |0.555       |0.664       |
 |ADJP      |29    |0.333       |0.241       |0.280       |
 |ADJP+ADJ  |22    |0.542       |0.591       |0.565       |
 |ADP       |204   |0.955       |0.946       |0.951       |
 |ADV       |64    |0.694       |0.531       |0.602       |
 |ADVP      |30    |0.333       |0.133       |0.190       |
 |ADVP+ADV  |53    |0.756       |0.642       |0.694       |
 |CONJ      |53    |1.000       |1.000       |1.000       |
 |DET       |167   |0.988       |0.976       |0.982       |
 |NOUN      |671   |0.752       |0.842       |0.795       |
 |NP        |884   |0.625       |0.524       |0.570       |
 |NP+ADJ    |2     |0.286       |1.000       |0.444       |
 |NP+DET    |21    |0.783       |0.857       |0.818       |
 |NP+NOUN   |131   |0.641       |0.573       |0.605       |
 |NP+NUM    |13    |0.214       |0.231       |0.222       |
 |NP+PRON   |50    |0.980       |0.980       |0.980       |
 |NP+QP     |11    |0.667       |0.182       |0.286       |
 |NUM       |93    |0.984       |0.645       |0.779       |
 |PP        |208   |0.597       |0.635       |0.615       |
 |PRON      |14    |1.000       |0.929       |0.963       |
 |PRT       |45    |0.957       |0.978       |0.967       |
 |PRT+PRT   |2     |0.400       |1.000       |0.571       |
 |QP        |26    |0.647       |0.423       |0.512       |
 |S         |87    |0.628       |0.784       |0.697       |
 |SBAR      |25    |0.091       |0.040       |0.056       |
 |VERB      |283   |0.683       |0.799       |0.736       |
 |VP        |399   |0.559       |0.594       |0.576       |
 |VP+VERB   |15    |0.250       |0.267       |0.258       |
 +----------+------+------------+------------+------------+
 |total     |4664  |0.714       |0.714       |0.714       |
 +----------+------+------------+------------+------------+
	</pre>

Note: the worst time cost of CKY algorithm is O(n^3 * |G|), |G| is rules' num, n is setence's length.

---
####Maximum likelihood estimates  + vertical markovization + CKY algorithm Parser ####

The file parse train vert.dat contains the original training sentence with vertical markovization applied to the parse trees. 

1. Process training data.

	<pre>
	ruby data_process.rb parse_train_vert.dat parse_train_vert_rare.dat
	python count_cfg_freq.py parse_train_vert_rare.dat > cfg_vert_rare.counts</pre>
2. Train with the new file and reparse the development set. 
	
	<pre>
	ruby pcfg_parser.rb cfg_vert_rare.counts parse_dev.dat parse_dev_vm.res
	Output: parse_dev_vm.res</pre>
	Then, run the eval script:
	<pre>
python eval_parser.py parse_dev.key parse_dev_vm.res</pre>
	You will get output like below:
	<pre>
 +---------+---------+------------+------------+-----------+
 |Type     | Total   |Precision   |Recall      |F1 Score   |
 +---------+---------+------------+------------+-----------+
 |.        |370      |1.000       |1.000       |1.000      |
 |ADJ      |164      |0.689       |0.622       |0.654      |
 |ADJP     |29       |0.324       |0.414       |0.364      |
 |ADJP+ADJ |22       |0.591       |0.591       |0.591      |
 |ADP      |204      |0.960       |0.951       |0.956      |
 |ADV      |64       |0.759       |0.641       |0.695      |
 |ADVP     |30       |0.417       |0.167       |0.238      |
 |ADVP+ADV |53       |0.700       |0.660       |0.680      |
 |CONJ     |53       |1.000       |1.000       |1.000      |
 |DET      |167      |0.988       |0.994       |0.991      |
 |NOUN     |671      |0.795       |0.845       |0.819      |
 |NP       |884      |0.617       |0.548       |0.580      |
 |NP+ADJ   |2        |0.333       |0.500       |0.400      |
 |NP+DET   |21       |0.944       |0.810       |0.872      |
 |NP+NOUN  |131      |0.610       |0.656       |0.632      |
 |NP+NUM   |13       |0.375       |0.231       |0.286      |
 |NP+PRON  |50       |0.980       |0.980       |0.980      |
 |NP+QP    |11       |0.750       |0.273       |0.400      |
 |NUM      |93       |0.914       |0.688       |0.785      |
 |PP       |208      |0.623       |0.635       |0.629      |
 |PRON     |14       |1.000       |0.929       |0.963      |
 |PRT      |45       |1.000       |0.933       |0.966      |
 |PRT+PRT  |2        |0.286       |1.000       |0.444      |
 |QP       |26       |0.650       |0.500       |0.565      |
 |S        |587      |0.704       |0.814       |0.755      |
 |SBAR     |25       |0.667       |0.400       |0.500      |
 |VERB     |283      |0.790       |0.813       |0.801      |
 |VP       |399      |0.663       |0.677       |0.670      |
 |VP+VERB  |15       |0.294       |0.333       |0.312      |
 +---------+---------+------------+------------+-----------+
 |total    |4664     |0.742       |0.742       |0.742      |
 +---------+---------+------------+------------+-----------+
	</pre>

Note: the program may run multi-hours even much longer.