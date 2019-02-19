# desc "Explaining what the task does"
# task :reverse_migration do
#   # Task goes here
# end
namespace :corrige do
  desc "Os arquivos são gerados na pasta do projeto /db/reverse_migrate"
  task :gerar, [:nm_modelo] do |t, args|
    p args[:nm_modelo]
    #Migrate.new(args[:nm_modelo])
  end
end
