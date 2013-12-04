#!/usr/bin/ruby

require 'matrix'

pt = "01 23 45 67 89 AB CD EF 12 34 56 78 9A BC DE F0"
k  = "2B 7E 15 16 28 AE D2 A6 AB F7 15 88 09 CF 4F 3C"

puts "Plaintext: #{pt}"
puts "Key : #{k}"

# Transform the given values into a more useable Matrix format
$state = Matrix.columns(pt.split(' ').each_slice(4).to_a)
$state = $state.map {|b| b.hex}
$key = Matrix.columns(k.split(' ').each_slice(4).to_a)
$key = $key.map {|b| b.hex}
#sbox to be populated later
$sbox = [0x63,0x7c]

def shift_rows
  row_array = $state.to_a
  for i in 1..3 do 
    row_array[i].rotate!(i)
  end
  $state = Matrix.rows(row_array)
end

def mix_columns
  # Fast method for computation with xors
  # array of state columns
  t_state = $state.transpose.to_a
  # for each column in state
  for i in 0..3
    r = t_state[i]
    a = [] #copy of r
    b = [] #2*a
    h = 0; #flag for highest order bit in r[c]
    for c in 0..3 do
      a[c] = r[c]
      # set the bit mask based on the high bit
      if r[c][7] == 1
        h = 0xff 
      else
        h = 0
      end
      # Mulitply by 2
      b[c] = r[c] << 1
      # divide by the galois field
      b[c] ^= 0x1b & h
    end
    # Calculate each byte
    r[0] = (b[0] ^ a[3] ^ a[2] ^ b[1] ^ a[1]) % 256
    r[1] = (b[1] ^ a[0] ^ a[3] ^ b[2] ^ a[2]) % 256
    r[2] = (b[2] ^ a[1] ^ a[0] ^ b[3] ^ a[3]) % 256
    r[3] = (b[3] ^ a[2] ^ a[1] ^ b[0] ^ a[0]) % 256
  end
  # Load columnwise becuse of the transposition
  $state = Matrix.columns(t_state)
end

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

# Generate the entire sbox for use later
def gen_sbox
  # the base polynomial for the field
  base = [8,4,3,1,0]
  #TODO fix for 0 and 1
  for i in 2..255 do
    # Create array of bits for given number
    # This will represent some polynomial
    bit_array = i.to_s(2).split(//)
    # Create array for exponents
    exp_array = []
    bit_array = bit_array.reverse

    # Transform bit array into exponent array
    for j in 0..7 do
      if bit_array[j]
        bit_array[j] = bit_array[j].to_i
        if bit_array[j] == 1
          exp_array.push(j)
        end
      end
    end
    exp_array = exp_array.sort.reverse
    
    # Calculate the gcd and inverse of the poly
    field_inv = gcd(base,exp_array)

    exp_array = inverse(field_inv[1])

    # Transform the exponent array back into a bit array
    for j in 0..7 do
      if exp_array.include?(j)
        bit_array[j] = 1
      else
        bit_array[j] = 0
      end
    end

    m = Matrix[[1,0,0,0,1,1,1,1],
               [1,1,0,0,0,1,1,1],
               [1,1,1,0,0,0,1,1],
               [1,1,1,1,0,0,0,1],
               [1,1,1,1,1,0,0,0],
               [0,1,1,1,1,1,0,0],
               [0,0,1,1,1,1,1,0],
               [0,0,0,1,1,1,1,1]]
    # Multiply the bit array as a column against the above matrix
    col_vec = Matrix.column_vector(bit_array)
    res1= m*col_vec
    # add in the static vector
    t = Matrix.column_vector([1,1,0,0,0,1,1,0])
    res2= res1+t
    # Put every bit back in 0-1
    res2 = res2.to_a.flatten
    res2.map! { |num|
      num = num % 2
    }
    #reverse the array to put the bits back in the right order
    res2.reverse!

    $sbox[i] = res2.join.to_i(2)
  end
end

# Compute the entire key schedule
def key_expansion
  $key_schedule = []
  #Move the given key into the key schedule
  for i in 0..3 do
    $key_schedule.push($key.column(i).to_a)
  end

  # the static values to add to each 4th key column
  # they are equivalent to x^(index+1)
  rcon = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1b, 0x36]
  # Calculate the rest of the key columns for 10 more rounds
  for i in 4..43 do
    nkey = [] # the next key being computed
    if i % 4 != 0
      #w(i) = w(i-4) + w(i-1)
      for j in 0..3 do
        nkey[j] = ($key_schedule[i-4][j] ^ $key_schedule[i-1][j]) 
      end
    else
      nkey = Array.new($key_schedule[i-1])
      #w(i-1) shift once than s-box each element
      nkey = nkey.rotate
      for j in 0..3 do
        nkey[j] = $sbox[nkey[j]]
        if j == 0
          #w(i-1)[0] + x^((i-4)/4)
          nkey[j] = nkey[j] ^ rcon[(i-4)/4]
        end

        #w(i) = w(i-4) + w(i-1)
        nkey[j] = nkey[j] ^ $key_schedule[i-4][j]
      end
    end
    $key_schedule.push(nkey)
  end
end

# Adds the corrosponding byte of the round key to each
# byte in the state matrix
def add_round_key(round)
  t_state = $state.to_a
  #Cycle through the rows
  for i in 0..3
    #Cycle through the columns
    for j in 0..3
      t_state[j][i] = t_state[j][i] ^ $key_schedule[4*round + i][ j]
    end
  end
  $state = Matrix.rows(t_state)
end

# Run each byte of the state matrix through the sbox
def sub_bytes
  $state = $state.map { |b| b = $sbox[b]}
end

# Helper to print out the state in a nice format
def print_state
  for i in [0] do
    str = ""
    for j in 0..3 do
      for k in 0..3 do
        str += $state[k,4*i+j].to_s(16)
        str += " "
      end
      str += "\t"
    end
    puts "#{str}"
  end
end

# Helper to print out the key schedule in a nice format
def print_key_schedule
  puts "Key Schedule:"
  for i in 0..10 do
    str = ""
    for j in 0..3 do
      for k in 0..3 do
        str += $key_schedule[4*i+j][k].to_s(16)
        str += " "
      end
      str += "\t"
    end
    puts "Key #{i} #{str}"
  end
end


def encrypt
  puts "Initial Round"
  add_round_key(0)
  puts "Add Round Key 0"
  print_state

  for i in (1..9) do
    puts "Round #{i}"
    sub_bytes
    puts "Sub Bytes"
    print_state

    shift_rows
    puts "Shift Rows"
    print_state

    mix_columns
    puts "Mix Columns"
    print_state

    add_round_key(i)
    puts "Add Round Key #{i}"
    print_state
  end

  puts "Final Round"
  sub_bytes
  puts "Sub Bytes"
  print_state

  shift_rows
  puts "Shift Rows"
  print_state

  add_round_key(10)
  puts "Add Round Key 10"
  print_state
end

#Generate the sbox and encrypt the message
gen_sbox
key_expansion

print_key_schedule

encrypt

puts "Ciphertext:"
print_state
