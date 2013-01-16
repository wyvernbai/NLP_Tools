# encoding: UTF-8

file_content = File.read(ARGV[0])
rare_words = []
words = []
file_content.scan (/\"([^\"]*?)\"\]/) {|word| words << word}
word_frequence = words.inject(Hash.new(0)) {|h,v| h[v] += 1; h}
word_frequence.each {|key, value| rare_words << key[0] if value < 5}
p rare_words
rare_words.each {|rare_word| file_content.gsub!(/\"#{Regexp.quote(rare_word)}\"\]/, '"_RARE_"]')}
File.open(ARGV[1], "w") {|write_steam| write_steam.write file_content}
