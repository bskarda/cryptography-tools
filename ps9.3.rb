a = ""
for i in 1..100 do
  # apply function
  r = (2*i + 1) ** 2 + 7
  # check if power of 2
  if r & (r-1) == 0
    a = a + " #{i},"
  end
end
p "part a = #{a}"

b = ""
for i in 1..30 do
  # apply function
  r = 2 * i ** 2 + 1
  # check if power of 3
  while(r % 3 == 0)
    r /= 3
  end

  if r == 1
    b = b + " #{i},"
  end
end
p "part b = #{b}"
