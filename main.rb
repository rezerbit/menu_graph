require 'roo'

xlsx = Roo::Spreadsheet.open('menu.xlsx', extension: :xlsx)
sheet = xlsx.sheet(0)

rows = []
sheet.each(name: 'Элемент меню', controller: 'Controller', action: 'Action' ) do |hash|
  rows << hash
end

rows