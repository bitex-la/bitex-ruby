module Bitex
  module JsonApi
    # By configuring your web POS you get a user friendly page where either you or your customers can create new payments at
    # will.
    #
    # They just need to specify an amount and currency to quote, and a reference for the payment so you know where it's from.
    # The amount and reference can be pre-configured in the URL.
    # Your Self Service POS is the most frictionless way to start accepting payments with bitex.
    #
    # You can also accept donations via the self service pos, we have a special URL that shows the standard POS but calls the
    # payment a 'Donation' which is friendlier for your donors. This is just cosmetic, there's no internal distinction between
    # payments and donations in your bitex payments dashboard.
    #
    # Configures your Web POS in a url of your choice. You should set all fields for the first time so that your POS is enabled.
    # After the initial setup you can change each field independently by only posting the field you wish to change.
    class Pos < Base
      def self.resource_path
        'merchants/pos'
      end

      def self.type
        'pos'
      end

      # POST /api/merchants/pos
      #
      # This endpoint should be use both for creating and updating the POS and it includes all default configurations for the
      # payments to be received.
      #
      # @param [String|Float] keep: The bitcoin percentage to keep instead of settling to USD for payments created in the self.
      #   Defaults to 0, which means you won't keep any bitcoin.
      #   service POS.
      # @param [String] logo: Public URL of your logo.
      #   We reccommend your logo to be at least 200px in height and no more than 300px in width.
      #   It should look good in a Bitex blue background. Also, try to keep the file-size as small as possible otherwise it may
      #   slow down your POS loading time.
      # @param [String] name: Your business name.
      # @param [String] site: .Your website URL. A link to it will be shown in your self service point of sale.
      # @param [String] slug: Last part of your POS URL. Lowercase letters, numbers and dashes only.
      #   Must not be taken by someone else.
      #   You can check if it already exists visiting https://bitex.la/pos/your_desired_name.
      #
      # @return [Pos]
      def self.create(keep: 0, logo:, name:, site:, slug:)
        raise InvalidArgument unless valid_keep?(keep) && valid_slug?(slug)

        private_request do
          super(merchant_keep: keep, merchant_logo: logo, merchant_name: name, merchant_site: site, merchant_slug: slug)
        end
      end

      # @param [Float] merchant_keep. values: 0..+
      #
      # @return [Boolean]
      def self.valid_keep?(merchant_keep)
        !merchant_keep.negative?
      end

      # @param [String] merchant_slug.
      #
      # @return [Boolean] true if all characters are lowercase.
      def self.valid_slug?(merchant_slug)
        (merchant_slug =~ /[A-Z]/).nil?
      end

      private_class_method :valid_keep?, :valid_slug?
    end
  end
end
