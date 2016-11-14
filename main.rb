require 'bundler'
require 'csv'
Bundler.require(:default)


class CommitParser
  class << self

    def setup
      Gitlab.endpoint = 'http://<gitlab_domain>/api/v3'
      Gitlab.private_token = '<token>'
    end

    def get_projects_ids
      @@ids = Gitlab.search_projects('<group_owner_or_keyword>', {per_page: 999}).collect(&:id)
    end

    def dump_commits
      p_count = 0
      c_count = 0

      CSV.open("dump.csv", "wb") do |csv|
        csv << ["author", "day", "month", "year", "project"]

        @@ids.each do |id|
          puts "-- Processing #{Gitlab.project(id).name}"
          pname = Gitlab.project(id).name
          p_count += 1

          Gitlab.commits(id, per_page:9999).each do |commit|
            author = commit.author_name
            date   = Date.parse(commit.created_at)

            csv << [author, date.day, date.month, date.year, pname]
            c_count += 1
          end
        end
      end

      puts "-- Processed #{p_count} projects"
      puts "-- Processed #{c_count} commits"
    end
  end
end

CommitParser.setup
CommitParser.get_projects_ids
CommitParser.dump_commits
