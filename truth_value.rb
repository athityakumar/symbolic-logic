def get_truth_value var

  if var == "T"
    var = true
  elsif var == "F"
    var = false
  else
    var = nil
  end

  return var

end

def put_truth_value var

  if var == true
    var = "T"
  elsif var == false
    var = "F"
  else
    var = "U"
  end

  return var

end

def operator_not val

  val = get_truth_value(val)
  (val.nil?) ? (return nil) : (return put_truth_value(!val))

end
  
def operator_and val1 , val2

  val1 , val2 = get_truth_value(val1) , get_truth_value(val2)
  res = put_truth_value(val1 && val2)
  return res

end

def operator_or val1 , val2

  val1 , val2 = get_truth_value(val1) , get_truth_value(val2)
  res = put_truth_value(val1 || val2)
  return res

end

def operator_if val1 , val2

  val1 , val2 = get_truth_value(val1) , get_truth_value(val2)
  if !val1 
    return "T"
  else
    return put_truth_value(val2)
  end

end                                               

def operator_iff val1 , val2

  val1 , val2 = get_truth_value(val1) , get_truth_value(val2)
  if !(val1.nil? || val2.nil?)
    return put_truth_value(val1 == val2)
  else
    return nil
  end

end


def is_operator char

  (["~",".","v",">","="].include? char) ? (return true) : (return false)  

end

def get_variables input

  var = {}
  input.split(",").each do |inp|
    inp = inp.split("=")
    var[inp[0]] = inp[1]
  end
  return var

end

def eval_statement string

  if string.length == 1
    return string[0]
  elsif string.length == 2
    return operator_not(string[1])
  else
    var1 ,var2 , operator = string[0] , string[2] , string[1]
    if operator == "."
      return operator_and(var1,var2)
    elsif operator == "v"
      return operator_or(var1,var2)
    elsif operator == ">"
      return operator_if(var1,var2)
    elsif operator == "="
      return operator_iff(var1,var2)  
    end
  end  
end

def get_index array , value

  index = 0

  for i in (0..array.count-1)
    if array[i] < value
      index = i
    end
  end

  return index

end

def order_by_syntax open_bracket , close_bracket

  hash = {}
  while open_bracket.count != 0 do
    key = close_bracket[0]
    index = get_index(open_bracket,key)
    value = open_bracket[index]
    hash[key] = value
    open_bracket.delete(value)
    close_bracket.delete(key)
  end

  return hash

end

def get_list_not statement

  list_not = []
  for i in (0..statement.length-2)
    if statement[i]=="~" && statement[i+1]!="("
      list_not.push(i)
    end
  end

  return list_not

end 

def get_list_left_right statement

  list_right , list_left = [] , [] , []
  for i in (0..statement.length-1)
    char = statement[i]   
    if char == "("
      list_left.push(i)  
    elsif char == ")"
      list_right.push(i)
    end
  end

  unless list_right.empty?
    bracket_hash = order_by_syntax(list_left,list_right)
    list_left , list_right = bracket_hash.values , bracket_hash.keys
  end  

  return list_left , list_right

end 

def apply_not statement

  list_not = get_list_not(statement)

  # Convert ~T -> F
  unless list_not.empty?
    while list_not.count != 0
      l = list_not[0]
      statement[l..l+1] = operator_not(statement[l+1])
      list_not = get_list_not(statement)
    end
  end

  return statement

end


def read_statement statement , variables

  # Convert A , B , C -> T , T , F
  for i in (0..statement.length-1)
    if variables.include? statement[i]
      statement[i] = variables[statement[i]]
    end
  end

  statement = apply_not(statement)
  list_left , list_right = get_list_left_right(statement)    

  unless list_left.empty?
    while !list_left.empty?
      l , r = list_left.first , list_right.first
      statement[l..r] = eval_statement(statement[l+1..r-1])
      statement = apply_not(statement)
      list_left , list_right = get_list_left_right(statement)      
    end
  end

  statement = eval_statement(statement)
  return statement

end

puts ""
puts "How many variables would you like to input?"
nInput = gets.chomp.to_i
input = []
puts ""
puts "Enter variables with syntax like 'A=T' or 'B=F'."

for i in (1..nInput)
  puts ""
  puts "Enter input variable ##{i} : "
  input.push(gets.chomp)
end

input = input.join(",")
puts ""
puts "How many truth functional propositions would you like to input?"
nStatement = gets.chomp.to_i
statements = [] 
puts ""
puts "Enter truth functional propositions with syntax like '((A.B)>C)vD' or '~B=~C'. \nOperators : ~ (NOT) , . (AND) , v (OR) , > (IF-THEN) , = (IFF)."

for i in (1..nStatement)
  puts ""
  puts "Enter truth functional proposition ##{i} : "
  stat = gets.chomp
  statements.push(stat)
end

variables , i = get_variables(input) , 1

puts ""
statements.each do |s|
  puts "Truth value of truth functional proposition ##{i} : #{read_statement(s,variables)}"
  i = i+1
end

puts ""