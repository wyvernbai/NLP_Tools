# encoding: UTF-8
#

require "./loadmodel.rb"

ParserGraphNode = Struct.new(:nonterm, :prob, :result)

def build_parse_result head, son1, son2 = nil     #build parse result depended onto the head and two son node.
  result = ""
  if son2
    result = "[\"#{head}\", #{son1}, #{son2}]"
  else
    result = "[\"#{head}\", \"#{son1}\"]"
  end
  result
end

def init words, parser_graph, q_xw      #replace rare words with __RARE__
  words.each_with_index do |word, index|
    q_xw.each do |key, value|
      xw = key.split(/ /)
      if xw[1] == word
        parser_graph[index][index].store xw[0], [value, build_parse_result(xw[0], word)]
      end
    end

    if parser_graph[index][index].size == 0
      q_xw.each do |key, value|
        xw = key.split(/ /)
        if xw[1] == "_RARE_"
          parser_graph[index][index].store xw[0], [value, build_parse_result(xw[0], word)]
        end
      end
    end
  end
end

def ckyparser parser_graph, count_x, q_xy12, length
  (1..length - 1).each do |l|
    (0..length - 1 - l).each do |i|
      j = i + l

      ideal_s = -1
      ideal_head = nil
      ideal_prob = 0

      # the CKY algorithm
      (i..j-1).each do |s|
        if parser_graph[i][s].size != 0 && parser_graph[s + 1][j].size != 0 then
          parser_graph[i][s].each do |y1, y1_value|
            parser_graph[s + 1][j].each do |y2, y2_value|
              y1_y2_prob = y1_value[0] * y2_value[0]
              count_x.each_key do |x|
                key = "#{x} #{y1} #{y2}"
                if q_xy12.has_key? key then
                  value = q_xy12[key]
                  temp_value = value * y1_y2_prob
                  if parser_graph[i][j].has_key? x then
                    if parser_graph[i][j][x][0] < temp_value
                      parser_graph[i][j][x] = [temp_value, build_parse_result(x, y1_value[1], y2_value[1])]
                    end
                  else
                    parser_graph[i][j].store x, [temp_value, build_parse_result(x, y1_value[1], y2_value[1])]  #store the possible result into hashtable.
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  if parser_graph[0][length - 1].has_key? "S" then  #if has a root mode called "S"
    return parser_graph[0][length - 1]["S"][0], parser_graph[0][length - 1]["S"][1]
  else      # else: return the most possiblily result
    ideal_prob = 0
    ideal_result = ""
    parser_graph[0][length - 1].each_value do |value|
      if value[0] > ideal_prob then
        ideal_result = value[1]
        ideal_prob = value[0]
      end
    end
    return ideal_prob, ideal_result
  end
end

def pcfg setence, count_x, q_xy12, q_xw
  words = setence.split(/ /)
  length = words.size
  parser_graph = Array.new(length) {Array.new(length) {Hash.new}} # parser_graph is a n*n array. each node's data struct is a hash table
  init words, parser_graph, q_xw
  return ckyparser(parser_graph, count_x, q_xy12, length)
end

count_x, q_xy12, q_xw = loadmodel ARGV[0]

threads = []
MAX_SENTENCE_EACH_THREAD = 100
File.open(ARGV[2], "w") do |write_stream|
  setences = []
  File.read(ARGV[1]).each_line{|setence| setence[-1] = ""; setences << setence}
  last_group = setences.size % MAX_SENTENCE_EACH_THREAD
  (0..setences.size / MAX_SENTENCE_EACH_THREAD).each do |index|
    begin_index = index * MAX_SENTENCE_EACH_THREAD
    end_index = begin_index + MAX_SENTENCE_EACH_THREAD - 1
    end_index = begin_index + last_group - 1 if index == setences.size / MAX_SENTENCE_EACH_THREAD
    if end_index >= begin_index then
      threads << Thread.new do        #use multi-thread to improve CKY decode speed
        results = ""
        setences[begin_index..end_index].each_with_index do |setence, num|
          prob, parser_result = pcfg setence, count_x, q_xy12, q_xw
          puts setence
          puts "Thread#{Thread.current.object_id}\t#{num}"
          results += (parser_result + "\n")
        end
        results
      end
    end
  end
  
  threads.each do |t|
    write_stream.write t.value
  end
end

