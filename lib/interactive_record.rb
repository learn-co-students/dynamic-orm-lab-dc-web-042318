require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = "pragma table_info('#{self.table_name}')"
        db_rows = DB[:conn].execute(sql)
        db_rows.map{|value| value["name"]}
    end

    def initialize(options = {})
        options.each do |key, value|
            self.send("#{key}=",value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        col_names = self.class.column_names
        col_names = col_names.slice(1..-1)
        col_names.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = "INSERT INTO #{self.class.table_name} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
        DB[:conn].execute(sql)
        sql = "SELECT last_insert_rowid() FROM #{self.class.table_name}"
        @id = DB[:conn].execute(sql)[0][0]
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
    end

    def self.find_by(attr)
        # binding.pry
        sql = "SELECT * FROM #{self.table_name} WHERE #{attr.keys[0].to_s} = '#{attr[attr.keys[0]]}'"
        DB[:conn].execute(sql)
    end
end