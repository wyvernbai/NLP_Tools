# encoding: UTF-8
#

class IBMModel1
  attr_accessor :english_setence, :german_setence, :en_ge_pairs, :t, :total, :count, :word_list_en, :word_list_ge
  def initialize(english, german)
    @english_setence = []
    @german_setence = []
    @en_ge_pairs = {}
    @t = {}
    @total = Hash.new(0)
    @count = Hash.new(0)
    @word_list_en = {}
    @word_list_ge = {}

    line_num = 0
    File.open(english).each.zip(File.open(german)).each do |en_line, ge_line|
      print "#{line_num += 1} "
      @english_setence << (en_line.split(' ') << '')  #'' means NULL
      @german_setence << ge_line.split(' ')

      @english_setence[-1].each do |en_word|
        @en_ge_pairs.store(en_word, {}) unless @en_ge_pairs.has_key? en_word
        @german_setence[-1].each do |ge_word|
          @en_ge_pairs[en_word][ge_word] = true     #store possible en-ge pair into en_ge_pairs. let the value is true to improve compute speed.
#          if @en_ge_pairs[en_word].has_key? ge_word
#            @en_ge_pairs[en_word][ge_word] += 1
#          else
#            @en_ge_pairs[en_word].store ge_word, 1
#          end
        end
      end
    end

    @en_ge_pairs.each do |en_word, ge_words|
      @t[en_word] = Hash.new(0.0)
      ge_words.each do |ge_word, count|
        @t[en_word][ge_word] = 1.0 / @en_ge_pairs[en_word].size     # considered NULL
        @word_list_en[en_word] = true
        @word_list_ge[ge_word] = true
      end
    end
    puts "initialize ok"
  end

  def em_algorithm
    raise "Targe corpus cannot match origin corpus" if @english_setence.size != @german_setence.size
    @english_setence.each_with_index do |eng_setence, index|
      @german_setence[index].each do |ge_word|
        s_total = eng_setence.inject(0.0) {|s_total, item| s_total += @t[item][ge_word].to_f} #s-total(f) = sigma(t(f|e))
        eng_setence.each do |en_word|
          temp = @t[en_word][ge_word] / s_total
          #collect counts
          @count[en_word + "|" + ge_word] += temp
          @total[en_word] += temp
        end
      end
    end

    # estimate probabilities
    @t.each do |en_word, ge_words|
      ge_words.each_key do |ge_word|
        @t[en_word][ge_word] = @count[en_word + "|" + ge_word] / @total[en_word]
      end
    end
  end
end
