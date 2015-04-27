class MenuTree

  attr_accessor :childrens, :name, :level, :controller, :action, :id, :parent_id

  def initialize(attr={})
    @name = attr[:name]
    @level = attr[:level]
    @controller = attr[:controller]
    @action = attr[:action]
    @id = attr[:id]
    @parent_id = attr[:parent_id]

    @childrens = []
  end
end