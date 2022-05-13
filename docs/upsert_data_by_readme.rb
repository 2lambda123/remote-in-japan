#!/usr/bin/env ruby

require 'pry' unless ENV['JEKYLL_ENV'] == 'production'
require 'kramdown'
require 'sanitize'

lang   = ARGV[0] || 'en'
readme = IO.readlines('../README.en.md')[8..-20] if lang == 'en'
readme = IO.readlines('../README.md')[10..-17]   if lang == 'ja'

readme.each_with_index do |line, index|
  next unless line.include? '|'
  cells = line.gsub('\|', '&#124;').split '|'

  name_and_link = Kramdown::Document.new(cells[1]).root.children[0].children[0]
  name  = name_and_link.children[0].value.strip
  link  = name_and_link.attr['href']
  id    = name.gsub(' ', '_')
    .gsub('&', 'and')
    .gsub('（', '(')
    .gsub('）', ')')
    .delete(".,").downcase

  full_description = Kramdown::Document.new(cells[2].strip).to_html.strip
  is_full_remote   = cells[3].include?('ok') ? 'full_remote' : ''

  # Generate a corresponding file by parsed-README data
  company = <<~COMPANY_PAGE
    ---
    layout: post
    lang: #{lang}
    permalink: /#{lang}/#{id}
    title: #{name}
    description: '#{Sanitize.clean(full_description)}'
    description_full: '#{full_description}'
    categories: #{is_full_remote}
    link: #{link}
    ---
  COMPANY_PAGE

  #company << "date: 2019-01-01 00:00:00 +0900\n" # Not being used
  #company << "by: John Doe\n"                    # Not being used
  #company << "image: ''\n"                       # Not being used

  IO.write("./#{lang}/_posts/2020-02-22-#{id}.md", company)
  puts "Upsert: ./#{lang}/_posts/2020-02-22-#{id}.md"
end
