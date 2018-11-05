module Bitex
  module JsonApi
    class WithdrawalInstruction < Base
      # GET /api/withdrawal_instructions
      #
      # These instructions are created along with the Cash Withdrawal if it does not exist previously.
      #
      # @return [Array<WithdrawalInstruction>].
      def self.all
        private_request { super }
      end

      # POST /api/withdrawal_instructions
      #
      # There are 3 withdrawal methdos allowed: 'domestic_bank', 'international_bank' and 'third_party'.
      #
      # With each one, the body should have different fields:
      #   Domestic bank requires these fields:
      #     account_type, address, bank, bank_account_number, cbu, city, country, cuit, currency, further_instructions, name &
      #     phone.
      #   International bank requires these fields:
      #     account_type, address, bank, bank_account_number, bank_address, bank_country, bank_city, bank_postal_code,
      #     bank_swift, city, country, currency, further_instructions, name, phone & postal_code.
      #   Third party requires these fields:
      #     city, country, currency, further_instructions, name & phone.
      #
      # Some fields only accept certain values:
      #   account_type: checking or savings
      #   country: AR, CL, PY, UY or OTHER
      #   currency: The values accepted are valid codes from ISO 4217
      #     For country == AR only ARS and USD are accepted
      #     For country == CL only CLP is accepted
      #     For country == PY only PYG is accepted
      #     For country == UY only UYU is accepted
      #   bank has restricted values when using domestic_bank method
      #     For country == AR value should be one of:
      #       ['bapro', 'galicia', 'nacion', 'icbc', 'citibank', 'bbva', 'cordoba', 'supervielle', 'ciudad', 'patagonia',
      #       'hipotecario', 'san_juan', 'tucuman', 'rosario', 'santander', 'chubut', 'santa_cruz', 'la_pampa', 'corrientes',
      #       'neuquen', 'interfinanzas', 'hsbc', 'credicoop', 'banco_de_valores', 'roela', 'mariva', 'itau', 'america',
      #       'paribas', 'tierra_del_fuego', 'uruguay', 'saenz', 'meridian', 'macro', 'comafi', 'inversion', 'piano', 'julio',
      #       'rioja', 'del_sol', 'chaco', 'voii', 'formosa', 'cmf', 'santiago_del_estero', 'bind', 'santa_fe', 'masventas',
      #       'entre_rios', 'columbia', 'bica', 'coinag', 'comercio', 'finansur', 'wilobank', 'otro'].
      #     For country == CL value should be one of:
      #       ['bco_chile', 'bco_int', 'bco_estado', 'scotia_chile', 'credito_chile', 'corpbanca', 'bice', 'hsbc_ch',
      #        'santander_ch', 'itau_chile', 'tokio', 'security', 'falabella', 'deutsche', 'ripley', 'rabobank', 'consorcio',
      #        'penta', 'paris', 'bbva_ch', 'desarrollo', 'coopeuch'].
      #
      # **************************************************************************************************************************
      # * Important note:                                                                                                        *
      # *  Provide all the information that is required for the applicable regulations. Some values might be accepted by the API *
      # *  but the withdrawal will be rejected afterwards in case there is an issue (such as missing or incorrect data).         *
      # *  Also remember that we can only process withdrawals to bank accounts belonging to the same holder as the Bitex account *
      # **************************************************************************************************************************
      #
      # @return WithdrawalInstruction
      def self.create(label:, payment_method:, payment_body:)
        raise PaymentError unless valid_payment?(payment_method, payment_body)

        private_request { super(label: label, body: payment_body.merge(payment_method: payment_method)) }
      end

      # DELETE /api/withdrawal_instructions/:id
      #
      # @param [String|Integer] id.
      #
      # @return [Boolean]
      def destroy
        private_request { super }
      end

      # Check if body and method are valids.
      #
      # @param [String] method. Payment method name: [domestic_bank, international_bank, third_party].
      # @param [Hash] body. Payment body.
      #
      # @return [Boolean]
      def self.valid_payment?(method, body)
        valid_method?(method) && valid_body?(method, body.keys)
      end

      # Chek if method name is valid on accepted names.
      #
      # @param [String] method. Payment method name.
      #
      # @return [Boolean]
      def self.valid_method?(method)
        %w[domestic_bank international_bank third_party].include?(method)
      end

      # Check if body payment has valid structure.
      #
      # @param [String] payment_method.
      # @param [Array<String>] payment_body_keys.
      #
      # @return [Boolean]
      def self.valid_body?(payment_method, payment_body_keys)
        send("#{payment_method}_body").all? { |payment_key| payment_body_keys.include?(payment_key) }
      end

      # @return [Array<String>] body keys for a domestic bank payment method.
      def self.domestic_bank_body
        shared_body_bank + %w[cbu country cuit currency]
      end

      # @return [Array<String>] body keys for an international bank payment method.
      def self.international_bank_body
        shared_body_bank + %w[bank_address bank_city bank_country bank_postal_code bank_swift postal_code]
      end

      # @return [Array<String>] body keys for an third party payment method.
      def self.third_party_body
        shared_body
      end

      # @return [Array<String>] shared body keys for banks.
      def self.shared_body_bank
        shared_body + %w[account_type address bank bank_account_number]
      end

      # @return [Array<String>] shared body keys for all payment methods.
      def self.shared_body
        %w[name city further_instructions phone]
      end

      private_class_method :valid_payment?, :valid_method?, :valid_body?, :domestic_bank_body, :international_bank_body,
        :third_party_body, :shared_body_bank, :shared_body
    end
  end
end
