require 'csv'
require 'activerecord-import/base'
ActiveRecord::Import.require_adapter('postgresql')


def skills_from_csv(csv_path)
  skills = []

  CSV.foreach(csv_path, 'r:windows-1250') do |row|
    skills << row.first
  end

  skills
end

csv_file = Rails.root.join('data', 'skills_list_22-sep -2016.csv')
skills_from_file = skills_from_csv(csv_file)
skills = (skills_from_file - Skill.pluck(:skill)).map do |s|
  Skill.new(skill: s)
end

Skill.import(skills, validate: false)
