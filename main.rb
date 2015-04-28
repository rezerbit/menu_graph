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




def create_text(menu)
  text = ''
  menu.childrens.each do |m|
    text += if m.childrens.empty? && m.level != 1
              "  " * m.level.to_i + "\"#{m.name}\" " + "[label=\"#{m.name}\"];\n"
            else
              "\n" +
              "  " * m.level.to_i + "subgraph cluster_#{m.id} {\n" +
              "  " * m.level.to_i + '  ' + "\"#{m.name}\" " + "[label=\"#{m.name}\"];\n" +
              create_text(m) +
              "  " * m.level.to_i + "}\n\n"
            end
  end
  text
end




def create_controllers(rows)
  controllers = []
  rows.each_with_index do |r, i|
    next if r[:controller].nil?
    contr = controllers.select { |c| c[:controller] == r[:controller] }.first
    if contr.nil?
      controllers << { controller: r[:controller], id: i + 1000, actions: [{ action: r[:action], name: r[:name] }] }
    else
      contr[:actions] << { action: r[:action], name: r[:name] }
    end
  end
  controllers
end

controllers = create_controllers(rows)
p controllers




def create_subgraph_controller(menu)
  text = ''
  menu.childrens.each do |m|
    text += if m.childrens.empty? && m.level != 1
              "  " * m.level.to_i + "\"#{m.name}\";\n"
            elsif m.childrens.empty? && m.level == 1
              "\n" +
              "  " * m.level.to_i + "subgraph cluster_#{m.id} {\n" +
              "  " * m.level.to_i + '  ' + "style=filled;\n" +
              "  " * m.level.to_i + '  ' + "fillcolor=azure2;\n" +
              "  " * m.level.to_i + '  ' + "color=azure4;\n" +
              "  " * m.level.to_i + '  ' + "node [style=filled,color=gray10, fillcolor=white, shape=box];\n" +

                  "  " * m.level.to_i + "\"#{m.name}\";\n" +
              create_subgraph_controller(m) +
              "  " * m.level.to_i + "}\n\n"
            else
              "\n" +

              "  " * m.level.to_i + "subgraph cluster_#{m.id} {\n" +
              "  " * m.level.to_i + '  ' + "style=filled;\n" +
              "  " * m.level.to_i + '  ' + "fillcolor=azure2;\n" +
              "  " * m.level.to_i + '  ' + "color=azure4;\n" +
              "  " * m.level.to_i + '  ' + "node [style=filled,color=gray10, fillcolor=white, shape=box];\n" +

              "  " * m.level.to_i + '  ' + "label=\"#{m.name}\";\n" +
              create_subgraph_controller(m) +
              "  " * m.level.to_i + "}\n\n"
            end
  end
  text
end




text = "digraph {\n" +
       "rank=same;" +
      "rankdir=RL; \n"

text += create_subgraph_controller(menu)

controllers.each do |c|
  text += "\n" +
          "subgraph cluster_#{c[:id]} {\n" +
          "label=\"#{c[:controller]}\";\n" +
      "style=filled;
  fillcolor=darkkhaki;
  color=darkolivegreen;
  node [style=filled,color=gray10, fillcolor=white];\n"


  c[:actions].each do |action|
    action[:action]
    text += "\"#{action[:name]}\" -> {\"#{c[:controller]}##{action[:action]}\" [label=#{action[:action]}]}\n"
  end

  text += "}\n\n"

end



text += '}'


File.open("generated_code.gv", 'w') {|f| f.write(text) }



`dot -Tpng ~/projects/menu_graph/generated_code.gv -o ~/projects/menu_graph/menu_graph.png > /dev/null`

