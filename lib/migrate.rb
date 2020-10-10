class Migrate

  def initialize(nm_schema, projects = Rails.root)
    @nm_schema = nm_schema
    @projects = projects
    if @nm_schema.present?
      gerar
    else
      "Modelo não encontrado !!"
    end
  end

  def locate_class(path_arquivo)
    arq_class = File.open(path_arquivo, 'r').readlines
    locate_file = ''
    arq_class.each do |arquivo|
      if arquivo.split(' ')[0] == 'class'
        locate_file =arquivo
        break
      else
        locate_file =  nil
      end
    end
    locate_file
  end

  def gerar
    path = File.join(@projects, 'app', 'models', @nm_schema)
    files = Dir.glob("#{path}/*")
    path_saida = File.join(Rails.root, 'db', 'reverse_migrate')
    Dir.mkdir(path_saida, 0700) unless Dir.exist?(path_saida)
    nr_second = 0
    files.map do |file|
      begin
        arq_class = locate_class(file)
        if arq_class.present?
          arq_class = arq_class.split(' ')
          nm_classe = arq_class[1]
          colunas = eval("#{nm_classe}.columns")
          migrate = []
          migrate << "class Create#{nm_classe.gsub(/::/, '').pluralize} < ActiveRecord::Migration"
          migrate << "\tdef change"
          migrate << "\t\t unless table_exists?(#{nm_classe}.table_name)"
          migrate << "\t\t\tcreate_table #{nm_classe}.table_name do |t|"
          colunas.map do |coluna|
            c_migrate = []
            unless ['id', 'created_at', 'updated_at'].include? coluna.name
              c_migrate << "t.#{coluna.type.to_s} :#{coluna.name}"
              c_migrate << "null: #{coluna.null}" unless coluna.null
              c_migrate << "limit: #{coluna.limit}" if coluna.limit.present? && !%w(decimal integer boolean timestamp).include?(coluna.type.to_s)
              c_migrate << "precision: #{coluna.precision}" if coluna.precision.present? && !%w(boolean).include?(coluna.type.to_s)
              c_migrate << "scale: #{coluna.scale}" if coluna.scale.present? && !%w(boolean).include?(coluna.type.to_s)
              c_migrate << "default: #{coluna.default}" if coluna.default.present?
              c_migrate << "comment: '#{coluna.comment}'" if coluna.comment.present?
              migrate << "\t\t\t\t#{c_migrate.reject {|x| x.blank?}.join(', ')}"
            end
          end
          migrate << "\n\t\t\t\tt.timestamps"
          migrate << "\t\t\tend"
          migrate << "\t\tend"
          migrate << "\tend"
          migrate << "end"
          file_out = File.new("#{path_saida}/#{nm_arquivo(nm_classe, nr_second)}", 'w')
          nr_second += 1
          migrate.map do |m|
            file_out.puts "#{m}"
          end
          file_out.close
        end
      rescue Exception => e
        puts "Houve um erro: #{e}"
      end
    end

    puts 'Gerado com Sucesso'
  end

  def nm_arquivo(arquivo, nr_second)
    "#{(Time.now + nr_second.second).strftime("%Y%m%d%H%M%S")}_create_#{arquivo.gsub(/::/, '').pluralize.underscore}.rb"
  end

  def verifica_relacionamento(class_name, column_name)
    relation = ''
    eval("#{class_name}.reflect_on_all_associations").each do |association|
      next unless association.options[:foreign_key].to_s.eql?(column_name)
      next unless association.macro.to_s.eql?('belongs_to')
      classe = association.options[:class_name].try(:constantize)
      if classe
        relation += "foreign_key: { to_table: '#{classe.table_name.to_s.downcase}' }, "
        relation += "comment: 'Relaciona com a tabela #{classe.table_name.to_s.downcase}'"
      end
    end
    relation
  end
end
