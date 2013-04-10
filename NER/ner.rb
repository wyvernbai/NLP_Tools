#!ruby -w
#encoding=utf-8
#
#   ruby ner.rb train_file test_file output-file(default:ner_dev_processed.hmmprediction)
#

require "./hmmlib.rb"

# replace rare word for different class
def word_replace word, first_word
  if word =~ /^[A-Z]*$/ then
   "_PROPER_"#proper names
  elsif word =~ /^[A-Z|\.]*$/ then
    if first_word then
      "_FIRST_"
    else
      "_FNOCO_" #first name or companies
    end
  elsif word =~ /^[A-Z].+$/ then
    if first_word then
      "_FIRST_NAME_"
    else
      "_NAME_"
    end
  elsif word =~ /^[0-9|\-]*$/ then
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

def getEmission word, tag, count_y_x, count_y, count_x, word_frequence, first_word
  t_w = "#{tag} #{word}"
  if !count_x.has_key?(word) then
    t_w = "#{tag} #{word_replace(word, first_word)}"
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
first_word = true
File.open("ner_train_processed.dat", "w:utf-8") do |write_stream|
  file_line.each do |item|
    if item[0] == "\n" then
      write_stream.write "\n"
      first_word = true
    else
      if word_frequence[item[0]] >= 5 then
        write_stream.write "#{item[0]} #{item[1]}"
      else
        write_stream.write "#{word_replace item[0], first_word} #{item[1]}"
      end
      first_word = false
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
observ = {}

File.open(OUTPUT_FILE, "w:utf-8") do |write_stream|
  File.read(TEST_FILE).split(/^$\n/).each do |setence|
    pre_statuses = {["*", "*"] => [0, ["*", "*"], [0, 0]]}
    word_setence = setence.split(/\n/)
    word_setence.each_with_index do |word, index|
      first_word = false
      first_word = true if index == 0
      new_statuses = {}
      pre_statuses.each do |y12, prob2|

        count_y.each_key do |possible_ner|
          status = [y12[1], possible_ner]

          e = getEmission word, possible_ner, count_y_x, count_y, count_x, word_frequence, first_word
          pi = getTrigramProb count_y_y, count_y_y_y, possible_ner, y12[1], y12[0]
          next if pi == nil || pi == 0 || e == 0
          
          prob_newstatus = prob2[0] + Math.log(e) + Math.log(pi)
          
          if new_statuses.has_key? status
            if new_statuses[status][0] < prob_newstatus
              new_statuses[status][0] = prob_newstatus
              (new_statuses[status][1] = Array.new(prob2[1])) << possible_ner
              (new_statuses[status][2] = Array.new(prob2[2])) << prob_newstatus
            end
          else
            status_prob = Array.new(prob2[1])
            status_prob_list = Array.new(prob2[2])
            new_statuses[status] = [prob_newstatus, status_prob << possible_ner, status_prob_list << prob_newstatus]
          end
        end
      end
      pre_statuses = new_statuses
    end

    ner_result = []
    ner_result_prob = []
    ner_prob_max = -Float::MAX
    pre_statuses.each do |y12, prob2|

      pi = getTrigramProb count_y_y, count_y_y_y, "STOP", y12[1], y12[0]
      next if pi == nil || pi == 0

      cur_prob = prob2[0] + Math.log(pi)

      if cur_prob  > ner_prob_max
        ner_result = prob2[1]
        ner_result_prob = prob2[2]
        ner_prob_max = cur_prob
      end

    end

    word_setence.each_with_index do |word, index|
      write_stream.write "#{word} #{ner_result[index + 2]} #{ner_result_prob[index + 2].to_s}\n"
    end
    write_stream.write "\n"
  end
end

puts "Output file: #{OUTPUT_FILE}"
