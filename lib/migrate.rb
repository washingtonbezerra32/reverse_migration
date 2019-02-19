class Migrate


  def initialize(nm_modelo)
    @nm_modelo = nm_modelo
    if nm_modelo.present?
      gerar
    else
      "Modelo não encontrado !!"
    end
  end


  def gerar
    path = File.join(Rails.root, 'app', 'models', @nm_modelo)
    files = Dir.glob("#{path}/*")
    path_saida = File.join(Rails.root, 'db', 'reverse_migrate')
    Dir.mkdir(path_saida, 0700) unless Dir.exist?(path_saida)
    nr_second = 0
    files.map do |file|
      begin
        arq_class = File.open(file, 'r') { |f| f.readlines }[0].split(' ')
        if arq_class[0] == 'class'
          nm_classe = arq_class[1]
          colunas = eval("#{nm_classe}.columns")
          migrate = []
          migrate << "class Create#{nm_classe.gsub(/::/, '').pluralize} < ActiveRecord::Migration"
          migrate << "\tdef change"
          migrate << "\t\tcreate_table '#{eval("#{nm_classe}.table_name.downcase")}' do |t|"
          colunas.map do |coluna|
            c_migrate = []
            unless ['id', 'created_at', 'updated_at'].include? coluna.name
              c_migrate << "t.#{coluna.type.to_s} :#{coluna.name}"
              c_migrate << "null: #{coluna.null}"
              c_migrate << "limit: #{coluna.limit}" if coluna.limit.present?
              c_migrate << "precision: #{coluna.precision}" if coluna.precision.present?
              c_migrate << "scale: #{coluna.scale}" if coluna.scale.present?
              #c_migrate << "comment: '#{coluna.comment}'" if coluna.comment.present?
              migrate << "\t\t\t#{c_migrate * ', '}"
            end
          end
          migrate << "\t\t\tt.timestamps null: false"
          migrate << "\t\tend"
          migrate << "\tend"
          migrate << "end"

          file_out = File.new("#{path_saida}/#{nm_arquivo(nm_classe, nr_second)}", 'w')
          nr_second += 1
          migrate.map do |m|
            file_out.puts m
          end
          file_out.close
        end
      rescue Exception => e
      end
    end
    # path_out = File.join(path_saida, 'modelo_saida.txt')
    # file_out = File.new(path_out, 'w')
    # conteudos.map do |conteudo|
    #   file_out.puts conteudo
    # end
    # file_out.close
    #puts "#{path_out} => Gerado com Sucesso"
  end


  def nm_arquivo(arquivo, nr_second)
    "#{(Time.now + nr_second.second).strftime("%Y%m%d%H%M%S")}_create_#{arquivo.gsub(/::/, '').pluralize.underscore}.rb"
  end


end
