#!ruby -w
#encoding=utf-8
#
#
# function that can be used in homework1
#


def hash_add! tables, item_key, item_value
  if tables.has_key? item_key then
    tables[item_key] += item_value
  else
    tables.store item_key, item_value
  end
end

def loadmodel modelname
  count_x = {}
  count_y = {}
  count_y_x = {}
  count_y_y = {}
  count_y_y_y = {}
  File.read(modelname).each_line do |line|
    line_array = line[0..-2].split(/ /)
    count = line_array[0].to_i
    if line_array[1] == "WORDTAG" then
      tag = line_array[2]
      word = line_array[3]
      hash_add! count_x, word, count
      hash_add! count_y, tag, count
      hash_add! count_y_x, "#{line_array[2]} #{line_array[3]}", count
    elsif line_array[1] == "2-GRAM" then
      hash_add! count_y_y, "#{line_array[2]} #{line_array[3]}", count
    elsif line_array[1] == "3-GRAM" then
      hash_add! count_y_y_y, "#{line_array[2]} #{line_array[3]} #{line_array[4]}", count
    end
  end

  return count_x, count_y, count_y_x, count_y_y, count_y_y_y
end

def wordcount testfile
  word_frequence = {}
  File.read(testfile).each_line do |line|
    if line != "\n" then
      hash_add! word_frequence, line[0..-2], 1
    end
  end
  word_frequence
end
