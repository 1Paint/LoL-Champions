def testing
  i = Hash.new
  i[:b] = 2
  
  def add_one
    i[:a] = 55
  end
  
  add_one
  
  puts i
end

testing