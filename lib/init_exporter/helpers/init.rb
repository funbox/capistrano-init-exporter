require 'init_exporter/helpers/init/upstart_backend'
require 'init_exporter/helpers/init/systemd_backend'

module InitExporter
  module Helpers
    module Init
      module_function

      def detect_backend(ssh)
        if ssh.test 'which', 'systemctl'
          InitExporter::Helpers::Init::SystemdBackend.new(ssh)
        elsif ssh.test 'which', 'initctl'
          InitExporter::Helpers::Init::UpstartBackend.new(ssh)
        else
          raise 'No init system found (both systemctl and initctl are not found in path)'
        end
      end

      def application_init_name(application, role)
        suffix = role.to_s == 'all' ? '' : "_#{role}"

        application.tr('-', '_').gsub(/\W/, '') + suffix
      end

      def init_job_name(application, role)
        init_job_prefix + application_init_name(application, role)
      end

      def all_procfiles
        @all_procfiles ||= begin
          list_procfiles.map do |path|
            stage, role = extract_stage_and_role(path)
            {stage: stage, role: role, path: path}
          end
        end
      end

      def known_procfiles
        all_procfiles.reject do |p|
          p[:stage] == :unknown || p[:role] == :unknown
        end
      end

      def procfile_exists?(stage, role)
        all_procfiles.find { |p| p[:stage] == stage && p[:role] == role }
      end

      def procfiles_for(stage)
        known_procfiles.select { |p| p[:stage] == stage }
      end

      def init_roles
        known_procfiles.map { |p| p[:role] }.uniq
      end

      protected

      def list_procfiles
        paths = []
        on release_roles :all do
          within release_path do
            paths = procfile_paths('config/init') + procfile_paths('config/upstart')
            break
          end
        end
        paths
      end

      def procfile_paths(root)
        capture(:find, root, '-type f', '-name "Procfile.*"', '2>/dev/null').lines.map(&:strip)
      rescue SSHKit::Command::Failed
        []
      end

      def extract_stage_and_role(procfile_path)
        case procfile_path
        when %r{\Aconfig/(?:init|upstart)/Procfile\.(\w+)\z}
          [Regexp.last_match(1), :all]
        when %r{\Aconfig/(?:init|upstart)/Procfile\.(\w+)\.(\w+)\z}
          [Regexp.last_match(2), Regexp.last_match(1)]
        when %r{\Aconfig/(?:init|upstart)/(\w+)/Procfile\.(\w+)\z}
          [Regexp.last_match(1), Regexp.last_match(2)]
        else
          [:unknown, :unknown]
        end.map(&:to_sym)
      end

      def init_job_prefix
        config = nil
        on release_roles :all do
          config = capture(:cat, '/etc/init-exporter.conf').split("\n").map(&:strip)
        end
        get_prefix(config)
      end

      COMMENT_SYMBOL = '#'.freeze
      SECTION_SYMBOL = '['.freeze
      DELIMITER      = ':'.freeze
      MAIN_SECTION   = '[main]'.freeze
      PREFIX_KEY     = 'prefix'.freeze

      def get_prefix(config_lines)
        main_section = false
        prefix = nil
        config_lines.each do |line|
          next if line == '' || line[0] == COMMENT_SYMBOL
          if line[0] == SECTION_SYMBOL
            main_section = (line == MAIN_SECTION)
            next
          end
          next unless main_section
          key, value = line.split(DELIMITER)
          next unless key == PREFIX_KEY
          prefix = value.strip!
          break
        end
        prefix
      end
    end
  end
end
