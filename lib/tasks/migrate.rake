
namespace :migrate do
  desc "Os arquivos são gerados na pasta do projeto /db/reverse_migrate"
  task :gerar => :environment   do
    Migrate.new(ENV['MODELO'].downcase)
  end
end
