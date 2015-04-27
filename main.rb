require 'roo'

xlsx = Roo::Spreadsheet.open('menu.xlsx', extension: :xlsx)
p xlsx.info