module Tzukuri

  class DiagAnalyser
    attr_accessor :num_users, :blocks; :entries

    def initialize()
      # p 'STARTING ANALYSER'
      # t1 = Time.now
      @path = Rails.root.join('diagnostics')
      @all_files = Dir[ File.join(@path, '**', '*') ].reject { |p| File.directory? p }

    end

    def parallel
      Parallel.each(@files, progress: "Parallel") do |file|
        scan_file(file)
      end
    end

    def non_parallel
      progress_options = {
        format: '%t |%E | %B | %a',
        title: 'Non-Parallel',
        total: @files.count
      }
      progress_bar = ProgressBar.create(progress_options)

      @files.each do |file|
        scan_file(file)
        progress_bar.increment
      end
    end

    private

    def scan_file(file)
      file_blocks = blocks_from_file(file)

      file_blocks.each do |block|
        block.entries.each do |entry|
        end
      end
    end

    def blocks_from_file(file)
      bytes = IO.binread(file)
      io = StringIO.new(bytes)
      blocks = []

      until io.eof?
        begin
            blocks << Tzukuri::Block.new(io)
        rescue
            # ignore invalid blocks
        end
      end

      return blocks
    end

  end
end
