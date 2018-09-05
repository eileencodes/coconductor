module Coconductor
  module ProjectFiles
    class ProjectFile < Licensee::ProjectFiles::ProjectFile
      def code_of_conduct
        matcher && matcher.match || CodeOfConduct.find('other')
      end

      undef_method :license
      undef_method :matched_license
      undef_method :copyright?
    end
  end
end
