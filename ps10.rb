# Substitution Permutation Cipher from Stinson 3.2
#
# All keys, plaintext, and ciphertext must be 4 byte hex strings
# Key schedule must be 8 byte hex string
# sbox values are a mapping between hex values
# permutations are an invertable lookup table of bit locations in the 4 byte sequence

require 'highline/import'

# get the plaintext to encode/decode from the user
pt = ask "Plaintext: "

# the key to be used in decryption
key = "3a94d63f"
#TODO fix following line. Reads input as unicode. Get as ascii.
#key = ask "Key: "

sbox_vals = {'0' => 'e', '1' => '4',  '2' => 'd',  '3' => '1',  '4' => '2',  '5' => 'f',  '6' => 'b',  '7' => '8',  '8' => '3',  '9' => 'a',  'a' => '6',  'b' => 'c',  'c' => '5',  'd' => '9',  'e' => '0',  'f' => '7'}

# lookup table for the permuation
$perm = [1,5,9,13,2,6,10,14,3,7,11,15,4,8,12,16]

# Flag included to check if in seciton of loop to permute
# only used in decryption
$permute = false

# check for the "-d" flag for decryption
$decrypt = false
if ARGV.include? "-d" 
  $decrypt = true
end

if ($decrypt)
  # reverse the key so that later the individual keys can be reversed to allow
  # the key schedule to be played back in reverse
  key = key.reverse
  sbox_vals = sbox_vals.invert
end

# pt = hex string
# perm = permutation array
def permute(pt, perm)
  # split the plaintext sting into an array of strings representing bits
  b = pt.hex.to_s(2).split(//)
  # pad the array with leading 0's
  while (b.length < 16)
    b.insert(0,"0")
  end
  # create the output ciphertext array of bits
  ct = []
  # for each bit set the ciphertext bit to the permuted value
  b.each_with_index { |d,i| ct[i] = b[perm[i] - 1] }
  # turn the array of strings back into a hex string
  return ct.join.to_i(2).to_s(16)
end

# pt = hex string
# sbox_vals = hash of pairings for the sbox
def sbox(pt, sbox_vals)
  # converts each of the values to the value it is mapped to in the sbox
  ary = pt.split(//).map { |i| sbox_vals[i]}
  return ary.join
end

# keynum = the position in the key schedule
# pt = hex string
# key = entire key schedule
#   reverse this if decrypting
def xor (keynum, pt, key)
  # get the individual key from the key schedule
  k = key[keynum,4]
  if $decrypt
    # reverse the reversed key to correct it
    k = k.reverse
    # run the key through the permputation if we are in the correct step
    if $permute
      k = permute(k, $perm)
    end
  end
  # xor the key and hex
  ret = k.hex ^ pt.hex
  # turn the number back into hex
  ret = ret.to_s(16)
  # pad the number with leading 0's
  while (ret.length < 4)
    ret.prepend("0")
  end
  return ret
end


# Cipher that follows the given steps
r = 0
ct = xor(r,pt,key)
p "first xor #{ct}"
while (r < 4) do
  r += 1
  if(r == 4)
    ct = sbox(ct, sbox_vals)
    p "last sbox #{ct}"
    ct = xor(r,ct,key)
    p "last xor #{ct}"
  else
    # set the permute flag, this is ignored if encrypting
    $permute = true
    ct = sbox(ct, sbox_vals)
    p "step #{r} sbox #{ct}"
    ct = permute(ct, $perm)
    p "step #{r} perm #{ct}"
    ct = xor(r,ct,key)
    p "step #{r} xor #{ct}"
    $permute = false
  end
end

p "CT = #{ct}"
