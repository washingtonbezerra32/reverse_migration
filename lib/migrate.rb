class Migrate

  def self.gerar
    path = File.join(Rails.root, 'app', 'models', 'catalogo')
    files = Dir.glob("#{path}/*")
    conteudos = []

    files.map do |file|
      # begin
        arq_class = File.open(file, 'r') {|f| f.readlines}[0].split(' ')
        if arq_class[0] == 'class'
          colunas = eval("#{arq_class[1]}.columns")
          migrate = []
          conteudos << "-----------------------------------------------------------------------------"
          migrate << "create_table '#{colunas.first.table_name}' do |t|"
          colunas.map do |coluna|
            c_migrate = []
            c_migrate << "t.#{coluna.type.to_s} :#{coluna.name}"
            c_migrate << "null: #{coluna.null}"
            c_migrate << "limit: #{coluna.limit}" if coluna.limit.present?
            c_migrate << "precision: #{coluna.precision}" if coluna.precision.present?
            c_migrate << "scale: #{coluna.scale}" if coluna.scale.present?
            c_migrate << "comment: '#{coluna.comment}'" if coluna.comment.present?
            migrate << "#{c_migrate * ', '}"
          end
          migrate << 'end'
          conteudos += migrate
          conteudos << "-----------------------------------------------------------------------------"
        end

      # rescue Exception => e
      # end

    end


    path_out = File.join(Rails.root, 'docs', 'modelo_saida.txt')
    file_out = File.new(path_out, 'w')
    conteudos.map do |conteudo|
      file_out.puts conteudo
    end
    file_out.close

    puts "#{path_out} => Gerado com Sucesso"
  end


end
