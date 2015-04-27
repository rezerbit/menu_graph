require 'roo'
require '~/projects/menu_graph/menu_tree.rb'


# include 'MenuTree'

xlsx = Roo::Spreadsheet.open('menu.xlsx', extension: :xlsx)
sheet = xlsx.sheet(0)

rows = []
sheet.each(name: 'Элемент меню', level: 'Уровень вложенности', controller: 'Controller', action: 'Action' ) do |hash|
  rows << hash
end

rows.shift # delete header of sheet


# Add id, parent_id

# root_node = MenuTree.new(name: 'root', id: 0)

rows.each_with_index do |r, i|
  r[:id] = i + 1
  r[:parent_id] = if r[:level] == 1
                    0
                  else

                    instance_variable_get("@last_row_id_with_level_#{r[:level].to_i - 1}")
                  end
  instance_variable_set("@last_row_id_with_level_#{r[:level].to_i}", r[:id])


end

puts 'Added id, parent_id'




menu_tree = MenuTree.new(name: 'root', id: 0)

cur_node = menu_tree

rows.each do |r|
  if cur_node.level == r[:level]
    cur_node
  else
    new_cur_node = MenuTree.new(r)
    cur_node.children << new_cur_node
  end

  cur_node = new_cur_node


  # node = MenuTree.new(r)
  # menu_tree.children << node
  #
  # id += 1



  # i = 1
  # loop do
  #   menu_tree.children << MenuTree.new(r) if r[:level] == i
  #   if
  # end

end


code = rows

File.open("generated_code.gv", 'w') {|f| f.write(code) }

