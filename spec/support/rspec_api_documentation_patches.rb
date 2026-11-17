# frozen_string_literal: true

# Patches for rspec_api_documentation 6.1.0, which is unmaintained upstream.
# These replace the SchoolKeep fork we used to pin.
#
# Remove this file once doc generation moves off rspec_api_documentation.

require 'stringio'
require 'rspec_api_documentation'

unless Gem.loaded_specs['rspec_api_documentation'].version == Gem::Version.new('6.1.0')
  raise 'rspec_api_documentation version changed; re-check spec/support/rspec_api_documentation_patches.rb'
end

module RspecApiDocumentationPatches
  # Rack 3.1 made env['rack.input'] optional, so requests without a body
  # leave it nil and the original code calls nil.rewind.
  module ReadRequestBody
    private

    def read_request_body
      input = last_request.env['rack.input'] || StringIO.new
      input.rewind
      input.read
    end
  end

  # File.exists? was removed in Ruby 3.2.
  module ClearDocs
    def clear_docs(docs_dir)
      FileUtils.rm_rf(docs_dir, secure: true)
      FileUtils.mkdir_p(docs_dir)
    end
  end
end

RspecApiDocumentation::ClientBase.prepend(RspecApiDocumentationPatches::ReadRequestBody)
RspecApiDocumentation::Writers::Writer.singleton_class.prepend(RspecApiDocumentationPatches::ClearDocs)
