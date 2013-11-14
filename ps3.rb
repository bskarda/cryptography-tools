$ary_size = 45

def lr(z)
	for i in (0..$ary_size)
		z[i+5] = (z[i]+z[i+1]) % 2
	end
	#puts z.join(" ")
	z
end

def period(z)
	ch = Array.new
	z.each_index do |i|
		if (i.between?(0,2))
			ch.push(z[i])
		elsif (ch == z[i,ch.length])
			return i
		else
			ch.push(z[i])
		end
	end
	"Not Found"
end

def all_lr()
	for i in (1..31)
		z = Array.new($ary_size + 5, 0)
		b = i.to_s(2).chars.map(&:to_i)
		b.each_index do |j|
			z[j] = b[j]
		end
		ret = lr(z)
		puts "For fill = #{i} period = #{period(ret)}"
	end
end

all_lr()
