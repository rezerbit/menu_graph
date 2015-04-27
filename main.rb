require 'roo'
require '~/projects/menu_graph/menu_tree.rb'
require '~/projects/menu_graph/subgraph_tree.rb'


# include 'MenuTree'

xlsx = Roo::Spreadsheet.open('menu.xlsx', extension: :xlsx)
sheet = xlsx.sheet(0)

rows = []
sheet.each(name: 'Элемент меню', level: 'Уровень вложенности', controller: 'Controller', action: 'Action' ) do |hash|
  hash[:name].gsub!("\n", '')
  rows << hash
end

rows.shift # delete header of sheet


# Add id, parent_id

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


menu = MenuTree.new(name: 'root', id: 0)

rows.each_with_index do |r, i|

  if i == 0
    @last_node_level_0 = menu
  end

  node = MenuTree.new(r)
  if r[:level] == menu.level
    instance_variable_get("@last_node_level_#{node.level.to_i - 1}").childrens << node
  else
    instance_variable_get("@last_node_level_#{node.level.to_i - 1}").childrens << node
  end

  instance_variable_set("@last_node_level_#{node.level.to_i}", node)
end


p '---'

p menu.childrens.map(&:name)








subgraph_tree = SubgraphTree.new(label: 'root')



def create_subgraph_tree(menu, subgraph_tree)
  menu.childrens.each do |m|
    s = SubgraphTree.new(label: m.name, id: m.id, parent_id: m.parent_id)
    subgraph_tree.childrens << s
    create_subgraph_tree(m, s)
  end
  subgraph_tree
end

# p create_subgraph_tree(menu, subgraph_tree).childrens[0].childrens.map(&:label)




def create_text(menu)
  text = ''
  menu.childrens.each do |m|
    text += if m.childrens.empty? && m.level != 1
              "  " * m.level.to_i + "\"#{m.name}\";\n"
            else
              "\n" +
              "  " * m.level.to_i + "subgraph cluster_#{m.id} {\n" +
              "  " * m.level.to_i + '  ' + "label=\"#{m.name}\";\n" +
              create_text(m) +
              "  " * m.level.to_i + "}\n\n"
            end
  end
  text
end

text = "digraph {\n"
text += create_text(menu)
text += '}'
File.open("generated_code.gv", 'w') {|f| f.write(text) }


`dot -Tpng -Tgif ~/projects/menu_graph/generated_code.gv -o ~/projects/menu_graph/menu_graph.png > /dev/null`