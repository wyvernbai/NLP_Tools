# encoding: UTF-8
#
require "#{File.dirname(__FILE__)}/ibmmodel1.rb"

class IBMModel2
  def initialize e_file, f_file

    #carry over t(f|e) from model 1
    ibmmodel1 = IBMModel1.new e_file, f_file
    (0..9).each {|i| ibmmodel1.em_algorithm}

    @t = ibmmodel1.t
    @e_setences = ibmmodel1.english_setence
    @f_setences = ibmmodel1.german_setence
    @e_f_pairs = ibmmodel1.en_ge_pairs
    @wordlist_e = ibmmodel1.word_list_en
    @wordlist_f = ibmmodel1.word_list_ge
    @q = {}
    @total = Hash.new(0)
    @count = Hash.new(0)
    @total_a = Hash.new(0)
    @count_a = Hash.new(0)

    @f_setences.each_with_index do |f_setence, index|
      e_setence = @e_setences[index]
      e_setence.each_with_index do |e_word, e_index|
        f_setence.each_with_index do |f_word, f_index|
          @q[e_index] = Hash.new(0.0) if @q[e_index].nil?
          @q[e_index]["#{f_index}|#{e_setence.size}|#{f_setence.size}"] = 1.0/(e_setence.size) # Because the last item of e_setence is NULL, let l = truly e_setence length + 1, q(j|i, l, m) = 1 / l
        end
      end
    end
  end

  def em_algorithm
    @e_setences.each_with_index do |e_setence, index|
      f_setence = @f_setences[index]
      f_setence.each_with_index do |f_word, f_index|
        key = "#{f_index}|#{e_setence.size}|#{f_setence.size}"
        s_total = 0.0
        e_setence.each_with_index { |e_word, e_index| s_total += @q[e_index][key] * @t[e_word][f_word]} # compute normalizetion
        e_setence.each_with_index do |e_word, e_index|    #collect counts
          temp = @q[e_index][key] * @t[e_word][f_word]
          @count[e_word + "|" + f_word] += temp
          @total[e_word] += temp
          @count_a["#{e_index}|#{key}"] += temp
          @total_a[key] += temp
        end
      end
    end

    # estimate probabilities
    @t.each do |e_word, f_words|
      f_words.each_key do |f_word|
        @t[e_word][f_word] = @count[e_word + "|" + f_word] / @total[e_word]
      end
    end

    @q.each do |e_index, f_indexs|
      f_indexs.each_key do |key|
        @q[e_index][key] = @count_a["#{e_index}|#{key}"] / @total_a[key]
      end
    end
  end
end
