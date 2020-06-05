require "dotenv/load"

require "fileutils"
require "csv"
require "json"
require "slugify"
require "haml"
require "tilt"
require "csv"
require "google/apis/sheets_v4"
require "googleauth"

BUILD_DIR = "dist"
FileUtils.rm_rf(BUILD_DIR) if Dir.exist?(BUILD_DIR)
Dir.mkdir(BUILD_DIR)

SPREADSHEET_ID = ENV.fetch("SPREADSHEET_ID")

service = Google::Apis::SheetsV4::SheetsService.new
service.client_options.application_name = "dxw Glossary"
service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
  json_key_io: StringIO.new(ENV.fetch("GOOGLE_CLIENT_SECRET")),
  scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
)

spreadsheet_id = SPREADSHEET_ID
range = "Glossary!A2:E"
response = service.get_spreadsheet_values spreadsheet_id, range

letters = []
glossary_entries = []
acronyms = []

response.values.each do |entry|
  unless entry[1].nil?

    letters = letters | [entry[1][0,1].upcase]

    entry_slug = entry[1].slugify

    entry_aka = []

    unless entry[2].nil?

      entry_acronyms = entry[2].split(",").map(&:strip)

      entry_acronyms.each do |acronym|
        acronyms << {
          entry_slug: entry_slug,
          acronym: acronym,
          name: entry[1],
          has_description: !entry[4].nil?,
        }

        entry_aka << acronym
      end
    end

    unless entry[3].nil?

      entry_aka_list = entry[3].split(",").map(&:strip)

      entry_aka_list.each do |aka|
        entry_aka << aka

        glossary_entries << {
          name: aka,
          see: entry_slug,
          see_name: entry[1]
        }
      end

    end

    glossary_entries << {
      slug: entry_slug,
      name: entry[1],
      description: entry[4],
      aka: entry_aka
    }

  end
end

sorted_glossary = glossary_entries.sort_by { |k| k[:name] }
sorted_acronyms = acronyms.sort_by { |k| k[:acronym] }

# Render out the HTML
template = Tilt::HamlTemplate.new("pages.haml")
page = template.render(Object.new, letters: letters, entries: sorted_glossary, acronyms: sorted_acronyms)

File.open("#{BUILD_DIR}/index.html", "w") { |f| f.write(page) }

# Render out the acronyms JSON
rows_json = JSON.generate(sorted_acronyms)
File.open("#{BUILD_DIR}/acronyms.json", "w") { |f| f.write(rows_json) }

# Copy CSS
Dir.mkdir("#{BUILD_DIR}/assets") unless Dir.exist?("#{BUILD_DIR}/assets")
FileUtils.cp("assets/style.css", "#{BUILD_DIR}/assets")

# Copy health check
Dir.mkdir("#{BUILD_DIR}/check") unless Dir.exist?("#{BUILD_DIR}/check")
FileUtils.cp("check/index.html", "#{BUILD_DIR}/check")
