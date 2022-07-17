if ARGV.size != 1
  puts "Usage: <filename>"
  exit 1
end

array = [] of Int64

File.open(ARGV[0]) do |f|
  f.each_line do |line|
    array << line.to_i
  end
end

window = [] of Int64

(0..array.size).each do |i|
  if i + 2 < array.size
    window << array[i] + array[i + 1] + array[i + 2]
  end
end

c = 0
last = 100000000

window.each do |i|
  if i > last
    c += 1
  end
  last = i
end

puts c
