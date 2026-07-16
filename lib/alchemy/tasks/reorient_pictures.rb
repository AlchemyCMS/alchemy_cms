# frozen_string_literal: true

require "alchemy/shell"

module Alchemy
  # Bakes the EXIF orientation into legacy picture masters.
  #
  # Masters uploaded before auto orientation landed still carry an EXIF
  # orientation tag. Clients honor it for the original image, but not once it is
  # converted to WebP, which renders such variants rotated in Chrome and Firefox.
  class ReorientPictures
    extend Shell

    # Also covers "" and "Undefined", i.e. no orientation tag at all.
    UPRIGHT_ORIENTATIONS = ["", "Undefined", "TopLeft"].freeze

    class << self
      def call(dry_run: false, picture_ids: nil)
        unless Alchemy.storage_adapter.dragonfly?
          log "Auto orientation only applies to the Dragonfly storage adapter", :skip
          return []
        end

        log "Dry run - no changes will be made", :message if dry_run

        affected = []
        skipped = 0
        # Dragonfly and ActiveJob log every shell command and enqueued job, which
        # floods the output. Silence them for the duration of the run.
        with_quiet_logging do
          # "." upright, "f" needs reorienting (report), "o" reoriented,
          # "s" master file missing.
          scope(picture_ids).find_each do |picture|
            next unless picture.has_convertible_format?

            if UPRIGHT_ORIENTATIONS.include?(orientation_of(picture))
              print_progress "."
              next
            end

            affected << picture.id
            reorient!(picture) unless dry_run
            print_progress(dry_run ? "f" : "o")
          rescue *Array(Alchemy.storage_adapter.rescuable_errors)
            affected.delete(picture.id)
            skipped += 1
            print_progress "s"
          end
        end
        finish_progress

        log "#{dry_run ? "Found" : "Reoriented"} #{affected.size} picture(s) that need reorienting"
        log "Skipped #{skipped} picture(s) whose master file is missing", :error if skipped.positive?
        if dry_run && affected.any?
          log "Reorient them with: rake alchemy:pictures:reorient PICTURE_IDS=#{affected.join(",")}"
        end
        affected
      end

      def report(picture_ids: nil)
        call(dry_run: true, picture_ids:)
      end

      private

      def scope(picture_ids)
        picture_ids.present? ? Alchemy::Picture.where(id: picture_ids) : Alchemy::Picture.all
      end

      def reorient!(picture)
        picture.image_file.auto_orient!
        # Saving the baked master rewrites the element and page caches that embed it.
        picture.save!
        # The variant signature does not change, so drop the stale variants
        # before regenerating them from the now upright master.
        picture.thumbs.destroy_all
        regenerate_variants(picture)
      end

      # Rerenders the frontend variants in the sizes the ingredients use, so the
      # corrected images are served right away instead of on first request.
      def regenerate_variants(picture)
        picture.related_ingredients.each do |ingredient|
          ingredient.picture_url
          ingredient.settings.fetch(:srcset, []).each { |src| ingredient.picture_url(src) }
        rescue => e
          log "Could not regenerate variants for ingredient ##{ingredient.id}: #{e.message}", :error
        end
      end

      def orientation_of(picture)
        picture.image_file.identify("-format '%[orientation]'").to_s.strip
      end

      def with_quiet_logging
        null_logger = ::Logger.new(IO::NULL)
        dragonfly_logger = ::Dragonfly.logger
        active_job_logger = ActiveJob::Base.logger
        ::Dragonfly.logger = null_logger
        ActiveJob::Base.logger = null_logger
        yield
      ensure
        ::Dragonfly.logger = dragonfly_logger
        ActiveJob::Base.logger = active_job_logger
      end

      def print_progress(char)
        return if Alchemy::Shell.silenced?

        print char
        $stdout.flush
      end

      def finish_progress
        puts unless Alchemy::Shell.silenced?
      end
    end
  end
end
