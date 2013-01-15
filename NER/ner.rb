#!ruby -w
#encoding=utf-8
#
#   ruby ner.rb train_file test_file output-file(default:ner_dev_processed.hmmprediction)
#

require "./hmmlib.rb"

# replace rare word for different class
def word_replace word
  if word =~ /^[A-Z]*$/ then
   "_PROPER_"#proper names
  elsif word =~ /^[A-Z][a-z]*$/ then
    "_NAME_"
  elsif word =~ /^[A-Z|\.]*$/ then
    "_FNOCO_" #first name or companies
  elsif word =~ /^[0-9]*$/ then
    "_NUM_" #number
  else
    "_RARE_"
  end
end

def getTrigramProb count_y_y, count_y_y_y, yip0, yip1, yip2
  yip21 = "#{yip2} #{yip1}"
  yip210 = "#{yip2} #{yip1} #{yip0}"
  if count_y_y.has_key? yip21 then
    count_y21 = count_y_y[yip21]
  else
    return nil
  end
  
  count_y210 = count_y_y_y.has_key?(yip210) ? count_y_y_y[yip210] : 0
  count_y210.to_f / count_y21
end

def getEmission word, tag, count_y_x, count_y, count_x, word_frequence
  t_w = "#{tag} #{word}"
  if word_frequence[word] < 5 || !count_x.has_key?(word) then
    t_w = "#{tag} #{word_replace(word)}"
  end
  count_w_t = count_y_x.has_key?(t_w) ? count_y_x[t_w] : 0
  count_t = count_y[tag]
  count_w_t.to_f / count_t
end


INPUTFILE = ARGV[0]
word_frequence = {}
file_line = []

# compute word requence
File.read(INPUTFILE).each_line do |line|
  word_array = line.split(/ /)
  word = word_array[0]
  tag = word_array[1]
  if word_frequence.has_key? word then
    word_frequence[word] += 1
  else
    word_frequence.store word, 1
  end
  file_line << [word, tag]
end

# replace rare word with special word
File.open("ner_train_processed.dat", "w:utf-8") do |write_stream|
  file_line.each do |item|
    if item[0] == "\n" then
      write_stream.write "\n"
    else
      if word_frequence[item[0]] >= 5 then
        write_stream.write "#{item[0]} #{item[1]}"
      else
        write_stream.write "#{word_replace item[0]} #{item[1]}"
      end
    end
  end
end

# run script count_freqs.py
system("python count_freqs.py ner_train_processed.dat > ner_processed.count")

MODEL_FILE = "ner_processed.count"
TEST_FILE = ARGV[1]
OUTPUT_FILE = ARGV[2] ? ARGV[2] : "ner_dev_processed.hmmprediction"

count_x, count_y, count_y_x, count_y_y, count_y_y_y = loadmodel MODEL_FILE
word_frequence = wordcount TEST_FILE

File.open(OUTPUT_FILE, "w:utf-8") do |write_stream|
  File.read(TEST_FILE).split(/^$\n/).each do |setence|
    word_setence = setence.split(/\n/)
    predict_tagger = []
    word_setence.each_with_index do |word, index|
      if index - 2 < 0 then
        yip2 = "*"
      else
        yip2 = predict_tagger[index - 2][0]
      end

      if index - 1 < 0 then
        yip1 = "*"
      else
        yip1 = predict_tagger[index - 1][0]
      end

      possible_tagger = {}
      count_y.each_key do |possible_tag|
        e = getEmission word, possible_tag, count_y_x, count_y, count_x, word_frequence
        pi = getTrigramProb count_y_y, count_y_y_y, possible_tag, yip1, yip2
        next if pi == nil || pi == 0
        if index == 0 then
          possible_tagger.store possible_tag, e * pi
        else
          possible_tagger.store possible_tag, predict_tagger[index - 1][1] * e * pi
        end
      end
      predict_tagger << possible_tagger.max_by {|k,v| v}
      write_stream.write "#{word} #{predict_tagger[index][0]} #{Math.log(predict_tagger[index][1]).to_s}\n"
    end
    write_stream.write "\n"
  end
end

puts "Output file: #{OUTPUT_FILE}"
