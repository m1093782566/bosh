require 'bosh/director/rendered_templates_writer'
require 'bosh/director/compressed_rendered_job_templates'

module Bosh::Director
  class RenderedTemplatesUploader
    def initialize(blobstore = App.instance.blobstores.blobstore)
      @blobstore = blobstore
    end

    def upload(rendered_job_templates)
      compressed_archive = CompressedRenderedJobTemplates.new(rendered_job_templates)
      @blobstore.create(compressed_archive.contents, 'fake-compressed-job-templates.tgz')
    end
  end
end
