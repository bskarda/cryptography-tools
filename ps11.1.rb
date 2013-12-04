#!/usr/bin/ruby

# Calculate the GCD of two polynomials given arrays
# of their exponents where big has the larger degree
# than lit
def gcd(big, lit)
  quotients = []
  remainders = []
  begin
    t = Array.new(lit)
    quo = []
    begin
      # Calculate the exponent to multiply the divisor by
      dif = big[0]-lit[0]
      # add the exponent to the current quotient
      quo.push(dif)
      # multiply the divisor
      if(dif > 0)
        lit.map! {|n| n += dif}
      end
      # Find the terms that only exist in one polynomial
      big = (big - lit).concat(lit-big)
      # sort the exponents largest to smallest
      big = big.sort.reverse
      lit = Array.new(t)
    end while ((big.size != 0) && (big[0] >= lit[0]))
    # save the quotient and remainder
    quotients.push(quo)
    quo = []
    remainders.push(big)

    lit = Array.new(big)
    big = t
  end while lit[0] != 0
  return [lit,quotients,remainders]
end

# Calculate the inverse of a polynomial given the list
# of quotients from the division operation
def inverse(quotients)
  #first entry is ignored and the definition of 1 in the program is x
  #therefor we use 0 because it has the value of x^0 or 1
  aux = [[0],[0]]
  aux.push(quotients.first)

  i = 1
  while i < quotients.size do
    cur = quotients[i]
    last = aux.last
    # next value to be added to the auxilary values in aux
    aux_next = []
    # for each exponent in the current quotient
    cur.each do |c|
      # current value being computed to be added to aux_next
      aux_temp = []
      # for each value in the last aux add the exponents
      last.each do |l|
        aux_temp.push(l+c)
      end
      # xor the two arrays to get only the values that exist in one of them
      aux_next = aux_next + aux_temp - (aux_next & aux_temp)
    end
    # add in the aux value from the last round
    aux_next = aux_next + aux[i] - (aux_next & aux[i])
    aux.push(aux_next.sort.reverse)
    i += 1
  end
  return aux.last
end

b = [13,8,6,1,0]
l = [4,1,0]

result = gcd(b,l)
puts "results #{result}"
puts "GCD = #{result[0]}"
puts "g(x)= #{result[1].last}"
puts "calculating h(x)"
hx = inverse(result[1])  
puts "h(x)= #{hx}"
