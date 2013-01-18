# encoding: UTF-8
#
require "../ibmmodel2.rb"
require "zlib"

class IBMModel2
  def get_align iter, setence_num
    (0..iter-1).each {|index| em_algorithm; puts "EM iteration #{index} done!"}
    (0..setence_num - 1).each do |index|
      e_setence = @e_setences[index]
      f_setence = @f_setences[index]
      e_length = e_setence.size
      f_length = f_setence.size
      e_setence.each do |word|
        print "#{word} "
      end
      print "\n"
      f_setence.each do |word|
        print "#{word} "
      end
      print "\n"
      pred_a = []

      f_setence.each_with_index do |f_word, f_index|
        maxProb = -1
        max_index = 0
        e_setence.each_with_index do |e_word, e_index|
          temp = @q[e_index]["#{f_index}|#{e_length}|#{f_length}"] * @t[e_word][f_word]
          if temp >= maxProb
            maxProb = temp
            max_index = e_index
          end
        end
        pred_a << max_index   # for each word get its most possible translate word.
        #puts "[#{f_word}, #{e_setence[max_index]}](#{f_index} <---> #{max_index}):\t#{maxProb}"
      end
      #puts "==========="
      p pred_a
      puts ""
    end
  end
end

ibmmodel2 = IBMModel2.new(ARGV[0], ARGV[1])
ibmmodel2.get_align ARGV[2].to_i, ARGV[3].to_i
marshal_dump = Marshal.dump(ibmmodel2)
file = Zlib::GzipWriter.new(File.new("ibmmodel2.model", 'w'))
file.write marshal_dump   #write model
file.close
