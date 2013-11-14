$alpha_size = 3
# Counts the number of occences of each letter in a given string and 
# return an array of those counts
def lc (str)
	cnt = Array.new($alpha_size, 0)
	str = str.downcase.gsub(/\s+/, "")
	for x in str.each_byte
		cnt[x - 'a'.ord] += 1
	end
	cnt
end

#print the letter count, letter frequency, and numerical representation for every character in the string
def lc_out (str)
	str_len = str.length
	# get the count of each letter from the string
	cnt = lc(str)
	perc = Array.new($alpha_size, 0)
	# print out each letter and the number of occurences with its number eqivalent
	base = 97
	cnt.each_with_index do |l, i|
		letter = Integer(base) + i
		perc[i] = (l/str_len.to_f).round(5)
		puts "#{letter.chr} = #{l},\t#{perc[i]}\t#{i}" 
	end
	puts "index of coincidence #{ic(str)}"
end

# shift each letter in the string str the amount given in amt
def shift(str, amt)
	nstr = ""
	str = str.downcase.gsub(/\s+/, "")
	str.each_byte do |ch|
		ch -= 97
		ch = (ch+amt) % 3
		nstr += (ch + 97).chr
	end
	nstr
end

#find the IC of the given string and return it
def ic (str)
	str_len = str.length
	indc = 0
	base = 97
	for x in (0..25)
		char = (Integer(base)+x).chr
		ch_count = str.downcase.count(char)
		len = str_len.to_f
		indc += (((ch_count)*(ch_count-1))/((len)*(len-1)))
	end
	indc
end

#Find the IC of each column at different keyword widths
def ic_col (str)
	for l in (1..3)
		str_ary = Array.new(l, "")
		for i in (0..str.length - 1)
			str_ary[i%l] += str[i]
		end
		
		totic = 0
		for i in (0..l-1)
			indc = ic(str_ary[i])
			totic += indc
			puts "IC of col size #{l} at #{i} = #{indc}" 
		end
		puts "=======avg ic for col size #{l} = #{totic/l.to_f}"
	end
end

#Unused function
$prob = [0.082, 0.015, 0.028, 0.043, 0.127, 0.022, 0.020, 0.061, 0.070, 0.002, 0.008, 0.040, 0.024, 0.067, 0.075, 0.019, 0.001, 0.060, 0.063, 0.091, 0.028, 0.010, 0.023, 0.001, 0.020, 0.001]
def ic_M (str)
	for l in [6]
		str_ary = Array.new(l, "")
		for i in (0..str.length - 1)
			str_ary[i%l] += str[i]
		end
		puts str_ary

		for c in (0..l-1)
			outp = ""
			for g in (0..25)
				m = 0
				for i in (0..25)
					m += ($prob[i]*str_ary[c].count((97+g).chr))#fixme
				end
			end
			puts "Col #{c}\n#{outp}"
		end
	end
end

#Shifts the Vigenere Cipher in portions
def ic_shift(str)
	for l in [2]
		str_ary = Array.new(l, "")
		for i in (0..str.length - 1)
			str_ary[i%l] += str[i]
		end
		puts str_ary

		shifts = [0,2]
		for c in (0..l-1)
			str_ary[c] = shift(str_ary[c], shifts[c])
		end

		output = ""
		for i in (0..str_ary[0].length)
			for j in (0..l-1)
				if str_ary[j][i] != nil
					output+= str_ary[j][i]
				end
			end
		end
		puts output
	end
end


# get the string to decrypt from the user
str = gets

#call functions for testing and decrypting
lc_out(str)
ic_col(str)

ic_shift(str)
