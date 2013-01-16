# encoding: UTF-8

def loadmodel model_file
  count_x = {}
  count_xy12 = {}
  count_xy = {}

  File.open(model_file).each_line do |line|
    if line =~ /^(\d+) N[^ ]+ (.*)$/ then
      count_x.store $2, $1.to_i
    elsif line =~ /^(\d+) B[^ ]+ (.*)$/ then
      count_xy12.store $2, $1.to_i
    elsif line =~ /^(\d+) U[^ ]+ (.*)$/ then
      count_xy.store $2, $1.to_i
    else
      puts line
    end
  end

  p_xy12 = {}
  count_xy12.each do |key, value|
    x = key.split(/ /)[0]
    p_xy12.store key, value.to_f / count_x[x]     #compute q(x->y1y2)
  end

  p_xw = {}
  count_xy.each do |key, value|
    x = key.split(/ /)[0]
    p_xw.store key, value.to_f / count_x[x]     #compute q(x->w)
  end
  return count_x, p_xy12, p_xw
end
