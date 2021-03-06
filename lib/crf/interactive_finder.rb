require 'crf/repetitions_list'
require 'ruby-progressbar'

module Crf
  #
  # This class finds the paths of all the repeated files inside the path passed as argument.
  # All files repeated have the same file_identifier and file_hash.
  #
  class InteractiveFinder < Crf::Finder
    #
    # Method that looks for the repeated files in the path specified when the object was created
    # showing progress bars.
    #
    def search_repeated_files
      all_paths = all_files(path)
      progressbar = ProgressBar.create(title: 'First run', total: all_paths.count,
                                       format: '%t: %c/%C %a |%B| %%%P')
      repetitions_list = first_run(progressbar)
      return repetitions_list.repetitions if repetitions_list.repetitions.empty? || @fast
      second_run(repetitions_list)
    end

    private

    #
    # This looks for the files with the same size only
    #
    def first_run(progressbar)
      repetitions_list = Crf::RepetitionsList.new
      all_files(path).each do |file_path|
        repetitions_list.add(file_identifier(file_path), file_path)
        progressbar.increment
      end
      repetitions_list
    end

    def second_run(repetitions_list)
      progressbar = ProgressBar.create(title: 'Second run', format: '%t: %c/%C %a |%B| %%%P',
                                       total: repetitions_list.total_repetitions)
      confirmed_repetitions_list = Crf::RepetitionsList.new
      repetitions_list.repetitions.values.each do |repeated_array|
        repeated_array.each do |file_path|
          confirmed_repetitions_list.add(file_hash(file_path), file_path)
          progressbar.increment
        end
      end
      confirmed_repetitions_list.repetitions
    end
  end
end
