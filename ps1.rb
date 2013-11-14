# Counts the number of occences of each letter in a given string and 
# return an array of those counts
def lc (str)
	cnt = Array.new(26, 0)
	str = str.downcase.gsub(/\s+/, "")
	for x in str.each_byte
		cnt[x - 'a'.ord] += 1
	end
	cnt
end

# the parameter a must be the inverse of a in the encypt function
def affine_decrypt(str, a, b)
	nstr = ""
	str = str.downcase.gsub(/\s+/, "")
	str.each_byte do |ch|
		ch -= 96
		ch = a*(ch-b) % 26
		nstr += (ch + 96).chr
	end
	puts nstr
end

# shift each letter in the string str the amount given in amt
def shift(str, amt)
	nstr = ""
	str = str.downcase.gsub(/\s+/, "")
	str.each_byte do |ch|
		ch -= 97
		ch = (ch+amt) % 26
		nstr += (ch + 97).chr
	end
	puts nstr
end

# get the string to decrypt from the user
str = gets
# get the count of each letter from the string
cnt = lc(str)
# print out each letter and the number of occurences with its number eqivalent
base = 97
cnt.each_with_index do |l, i|
	letter = Integer(base) + i
	puts "#{letter.chr} = #{l},\t#{i+1}" 
end

puts str.downcase.gsub(/\s+/, "")

# Test every shift possible
for a in 1..25
	shift(str,a)
end

# Brute force the affine cipher
p "Brute force"
for a in [1,9,21,15,19,23,25]
	for b in 0..25
		puts "a = #{a}, b = #{b}"
		affine_decrypt(str,a,b)
	end
end
